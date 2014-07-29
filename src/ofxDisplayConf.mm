#include "ofxDisplayConf.h"

#define MAX_DISPLAYS 32

extern "C"
{
    void CGSGetCurrentDisplayMode(CGDirectDisplayID display, int *modeNum);
    void CGSConfigureDisplayMode(CGDisplayConfigRef config, CGDirectDisplayID display, int modeNum);
    void CGSGetNumberOfDisplayModes(CGDirectDisplayID display, int *nModes);
    void CGSGetDisplayModeDescriptionOfLength(CGDirectDisplayID display, int idx, CGSDisplayMode *mode, int length);
};

int ofxDisplayConf::getMainDisplayID()
{
    CGDirectDisplayID displayID = CGMainDisplayID();
    return displayID;
}

int ofxDisplayConf::getBuiltinDisplayID()
{
    vector<int> onlineDisplayIDs = getOnlineDisplayIDs();
    for (auto odid : onlineDisplayIDs)
    {
        if (CGDisplayIsBuiltin(odid))
        {
            return odid;
        }
    }
    
    ofLog() << "no builtin display!!";
    return -1;
}

// online = active, mirrored, or sleeping
vector<int> ofxDisplayConf::getOnlineDisplayIDs()
{
    CGDisplayCount displayCount;
    CGDirectDisplayID onlineDisplayIDs[MAX_DISPLAYS];
    CGGetOnlineDisplayList(MAX_DISPLAYS, onlineDisplayIDs, &displayCount);
    
    vector<int> rtn;
    for (int i = 0; i < displayCount; i++)
    {
        rtn.push_back(onlineDisplayIDs[i]);
    }
    return rtn;
}

// active = drawable
vector<int> ofxDisplayConf::getActiveDisplayIDs()
{
    CGDisplayCount displayCount;
    CGDirectDisplayID onlineDisplayIDs[MAX_DISPLAYS];
    CGGetActiveDisplayList(MAX_DISPLAYS, onlineDisplayIDs, &displayCount);
    
    vector<int> rtn;
    for (int i = 0; i < displayCount; i++)
    {
        rtn.push_back(onlineDisplayIDs[i]);
    }
    return rtn;
}

void ofxDisplayConf::enumerateAllDisplayMode()
{
    vector<int> displayIDs = getOnlineDisplayIDs();
    int numberOfDisplayModes;
    for (auto did : displayIDs)
    {
        CGSGetNumberOfDisplayModes(did, &numberOfDisplayModes);

        ofLog() << "begin displayID " << did;
        for (int i = 0; i < numberOfDisplayModes; i++)
        {
            CGSDisplayMode mode;
            CGSGetDisplayModeDescriptionOfLength(did, i, &mode, sizeof(mode));
            mode.dump();
        }
        ofLog() << "end displayID " << did;
        ofLog() << "";
    }
}

/*
 Assume you already know the display mode (see enumerateAllDisplayMode)
 
 Display Modes??
 => standard properties — resolution (width and height in pixels), bits per pixel, and refresh rate
    optional properties — pixel stretching to fill the screen
 */
void ofxDisplayConf::setDisplayMode(int displayID, int displayMode)
{
    CGDisplayConfigRef config;
	CGBeginDisplayConfiguration(&config);
	CGSConfigureDisplayMode(config, displayID, displayMode);
	CGCompleteDisplayConfiguration(config, kCGConfigurePermanently);
}

vector<CGSDisplayMode> ofxDisplayConf::getDisplayModes(int displayID)
{
    int numberOfDisplayModes;
    CGSGetNumberOfDisplayModes(displayID, &numberOfDisplayModes);
 
    vector<CGSDisplayMode> modes;
    for (int i = 0; i < numberOfDisplayModes; i++)
    {
        CGSDisplayMode mode;
        CGSGetDisplayModeDescriptionOfLength(displayID, i, &mode, sizeof(mode));
        modes.push_back(mode);
    }
    return modes;
}

int ofxDisplayConf::getCurrentDsiplayMode(int displayID)
{
    int currentDisplayModeNumber;
    CGSGetCurrentDisplayMode(displayID, &currentDisplayModeNumber);
    return currentDisplayModeNumber;
}

DisplayArrangement ofxDisplayConf::getDisplayArrangement(int displayID)
{
    DisplayArrangement dispArgmt;
    dispArgmt.displayID = displayID;
    dispArgmt.orig.x = CGRectGetMinX(CGDisplayBounds(displayID));
    dispArgmt.orig.y = CGRectGetMinY(CGDisplayBounds(displayID));
    dispArgmt.width = CGDisplayBounds(displayID).size.width;
    dispArgmt.height = CGDisplayBounds(displayID).size.height;
    return dispArgmt;
}

/*
 a display is the main display by setting its origin to (0,0).
 */
void ofxDisplayConf::setMainDisplay(int displayID)
{
    if (displayID == getMainDisplayID())
    {
        return;
    }
    
    if (!ofContains(getActiveDisplayIDs(), displayID) ||
        !ofContains(getOnlineDisplayIDs(), displayID))
    {
        ofLogError() << "setMainDisplay():: no such display!!";
        return;
    }
    
	float deltaX = -CGRectGetMinX(CGDisplayBounds(displayID));
    float deltaY = -CGRectGetMinY(CGDisplayBounds(displayID));

    CGDisplayConfigRef config;
    CGBeginDisplayConfiguration(&config);
    
    vector<int> onlineDisplayIDs = getOnlineDisplayIDs();
    for (auto ondid : onlineDisplayIDs)
    {
        CGConfigureDisplayOrigin(config, ondid,
                                 CGRectGetMinX(CGDisplayBounds(ondid)) + deltaX,
                                 CGRectGetMinY(CGDisplayBounds(ondid)) + deltaY);
    }
    
    CGCompleteDisplayConfiguration(config, kCGConfigureForSession);
}

void ofxDisplayConf::setMirrorOn(vector<int> mirrorOnDisplayIDs)
{
    CGDisplayConfigRef config;
    CGBeginDisplayConfiguration(&config);
    
    if (!mirrorOnDisplayIDs.size())
    {
        vector<int> activeDisplayIDs = getActiveDisplayIDs();
        int mainDisplayID = getMainDisplayID();
        for (auto adid : activeDisplayIDs)
        {
            if (adid != mainDisplayID)
            {
                CGConfigureDisplayMirrorOfDisplay(config, adid, mainDisplayID);
            }
        }
    }
    else
    {
        for (auto did : mirrorOnDisplayIDs)
        {
            int mainDisplayID = getMainDisplayID();
            if (did != mainDisplayID)
            {
                CGConfigureDisplayMirrorOfDisplay(config, did, mainDisplayID);
            }
        }
    }
    
    CGCompleteDisplayConfiguration(config, kCGConfigureForSession);
}

void ofxDisplayConf::setMirrorOff(vector<int> mirrorOffDisplayIDs)
{
    CGDisplayConfigRef config;
    CGBeginDisplayConfiguration(&config);
    
    if (!mirrorOffDisplayIDs.size())
    {
        vector<int> onlineDisplayIDs = getOnlineDisplayIDs();
        int mainDisplayID = getMainDisplayID();
        for (auto ondid : onlineDisplayIDs)
        {
            if (ondid != mainDisplayID)
            {
                CGConfigureDisplayMirrorOfDisplay(config, ondid, kCGNullDirectDisplay);
            }
        }
    }
    else
    {
        for (auto did : mirrorOffDisplayIDs)
        {
            int mainDisplayID = getMainDisplayID();
            if (did != mainDisplayID)
            {
                CGConfigureDisplayMirrorOfDisplay(config, did, kCGNullDirectDisplay);
            }
        }
    }
    
    CGCompleteDisplayConfiguration(config, kCGConfigureForSession);
}

/*
 e.g. 1 main display & 3 other displays => main/other1/other2/other3
 */
void ofxDisplayConf::arrangeDisplaysLeftToRight()
{
    float xpos = 0;
    xpos += CGDisplayBounds(getMainDisplayID()).size.width;
    
    CGDisplayConfigRef config;
    CGBeginDisplayConfiguration(&config);
    
    vector<int> activeDisplayIDs = getActiveDisplayIDs();
    for (auto adid : activeDisplayIDs)
    {
        if (adid != getMainDisplayID())
        {
            CGConfigureDisplayOrigin(config, adid,
                                     xpos, 0);
            xpos += CGDisplayBounds(adid).size.width;
        }
    }
    
    CGCompleteDisplayConfiguration(config, kCGConfigureForSession);
}

/*
 e.g. 1 main display & 3 other displays => other1/other2/other3/main
 */
void ofxDisplayConf::arrangeDisplaysRightToLeft()
{
    float xpos = 0;
    
    CGDisplayConfigRef config;
    CGBeginDisplayConfiguration(&config);
    
    vector<int> activeDisplayIDs = getActiveDisplayIDs();
    for (auto adid : activeDisplayIDs)
    {
        if (adid != getMainDisplayID())
        {
            xpos -= CGDisplayBounds(adid).size.width;            
            CGConfigureDisplayOrigin(config, adid,
                                     xpos, 0);
        }
    }
    
    CGCompleteDisplayConfiguration(config, kCGConfigureForSession);
}

/*
 e.g. 1 main display & 3 other displays =>
        main/
        other1/
        other2/
        other3
 */
void ofxDisplayConf::arrangeDisplaysTopToBottom()
{
    float ypos = 0;
    ypos += CGDisplayBounds(getMainDisplayID()).size.height;
    
    CGDisplayConfigRef config;
    CGBeginDisplayConfiguration(&config);
    
    vector<int> activeDisplayIDs = getActiveDisplayIDs();
    for (auto adid : activeDisplayIDs)
    {
        if (adid != getMainDisplayID())
        {
            CGConfigureDisplayOrigin(config, adid,
                                     0, ypos);
            ypos += CGDisplayBounds(adid).size.height;
        }
    }
    
    CGCompleteDisplayConfiguration(config, kCGConfigureForSession);
}

/*
 e.g. 1 main display & 3 other displays =>
        other1/
        other2/
        other3/
        main
 */
void ofxDisplayConf::arrangeDisplaysBottomToTop()
{
    float ypos = 0;
    
    CGDisplayConfigRef config;
    CGBeginDisplayConfiguration(&config);
    
    vector<int> activeDisplayIDs = getActiveDisplayIDs();
    for (auto adid : activeDisplayIDs)
    {
        if (adid != getMainDisplayID())
        {
            ypos -= CGDisplayBounds(adid).size.height;
            CGConfigureDisplayOrigin(config, adid,
                                     0, ypos);
        }
    }
    
    CGCompleteDisplayConfiguration(config, kCGConfigureForSession);
}

void arrangeDisplay(int diplayID, ofPoint pos)
{
    CGDisplayConfigRef config;
    CGBeginDisplayConfiguration(&config);
    
    CGConfigureDisplayOrigin(config, diplayID, pos.x, pos.y);
    
    CGCompleteDisplayConfiguration(config, kCGConfigureForSession);
}