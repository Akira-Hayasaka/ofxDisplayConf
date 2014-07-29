//
//  ofxDisplayConf.h
//  emptyExample
//
//  Created by Akira on 2014/07/25.
//
//

#ifndef emptyExample_ofxDisplayConf_h
#define emptyExample_ofxDisplayConf_h

#include "ofMain.h"

// CoreGraphics DisplayMode struct used in private APIs
typedef struct
{
    uint32_t modeNumber;
    uint32_t flags;
    uint32_t width;
    uint32_t height;
    uint32_t depth;
    uint8_t unknown[170];
    uint16_t freq;
    uint8_t more_unknown[16];
    float density;
    
    void dump()
    {
        ofLog() << "modeNumber = " << modeNumber;
        ofLog() << "flags = " << flags;
        ofLog() << "width = " << width;
        ofLog() << "height = " << height;
        ofLog() << "depth = " << depth;
        ofLog() << "freq = " << freq;
        ofLog() << "density = " << density;
    }
}
CGSDisplayMode;

typedef struct
{
    int displayID;
    ofPoint orig;
    float width;
    float height;
    
    void dump()
    {
        ofLog() << "displayID = " << displayID;
        ofLog() << "orig = " << orig;
        ofLog() << "width = " << width;
        ofLog() << "height = " << height;
    }
}
DisplayArrangement;

class ofxDisplayConf
{
public:
    
    int getMainDisplayID();
    int getBuiltinDisplayID();
    vector<int> getOnlineDisplayIDs();
    vector<int> getActiveDisplayIDs();
    void enumerateAllDisplayMode();
    void setDisplayMode(int displayID, int displayMode);
    vector<CGSDisplayMode> getDisplayModes(int displayID);
    int getCurrentDsiplayMode(int displayID);
    DisplayArrangement getDisplayArrangement(int displayID);
    void setMainDisplay(int displayID);
    void setMirrorOn(vector<int> mirrorOnDisplayIDs = vector<int>());
    void setMirrorOff(vector<int> mirrorOffDisplayIDs = vector<int>());
    void arrangeDisplaysLeftToRight();
    void arrangeDisplaysRightToLeft();
    void arrangeDisplaysTopToBottom();
    void arrangeDisplaysBottomToTop();
    void arrangeDisplay(int diplayID, ofPoint pos); //<= advanced!
    
};

#endif
