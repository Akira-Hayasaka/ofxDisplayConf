#include "ofApp.h"

void ofApp::setup()
{
    ofBackground(ofColor::white);
    ofSetWindowShape(450, 280);
    
    initialDispModeOfMain = dispConf.getCurrentDsiplayMode(dispConf.getMainDisplayID());
    bMirror = false;
    
    ofLog() << "online displays";
    vector<int> dispIDs = dispConf.getOnlineDisplayIDs();
    for (auto did : dispIDs)
    {
        ofLog() << "id = " << did;
    }
}

void ofApp::draw()
{
    ofDrawBitmapStringHighlight("press 'm' to toggle mirrorring", 10, 20);
    ofDrawBitmapStringHighlight("press 'p' to change primary/main display", 10, 45);
    ofDrawBitmapStringHighlight("press 'l' to arrange display left to right", 10, 70);
    ofDrawBitmapStringHighlight("press 'r' to arrange display right to left", 10, 95);
    ofDrawBitmapStringHighlight("press 't' to arrange display top to bottom", 10, 120);
    ofDrawBitmapStringHighlight("press 'b' to arrange display bottom to top", 10, 145);
    ofDrawBitmapStringHighlight("press 's' to shuffle display mode of main", 10, 170);
    ofDrawBitmapStringHighlight("press 'q' to restore display mode of main", 10, 195);
    ofDrawBitmapStringHighlight("press '1' to open display preference 'display' tab", 10, 220);
    ofDrawBitmapStringHighlight("press '2' to open display preference 'arrangement' tab", 10, 245);
    ofDrawBitmapStringHighlight("press '3' to open display preference 'color' tab", 10, 270);
}

void ofApp::keyPressed(int key)
{
    if (key == 'm')
    {
        if (bMirror)
        {
            dispConf.setMirrorOff();
            bMirror = false;
        }
        else
        {
            dispConf.setMirrorOn();
            bMirror = true;
        }
    }
    else if (key == 'p')
    {
        vector<int> activeDisplayIDs = dispConf.getActiveDisplayIDs();
        int mainDisplayID = dispConf.getMainDisplayID();
        vector<int> activeWOMain;
        for (auto aid : activeDisplayIDs)
        {
            if (aid != mainDisplayID)
            {
                activeWOMain.push_back(aid);
            }
        }
        if (activeWOMain.size())
        {
            dispConf.setDisplayMode(dispConf.getMainDisplayID(), initialDispModeOfMain);
            
            ofRandomize(activeWOMain);
            dispConf.setMainDisplay(activeWOMain.front());
            
            initialDispModeOfMain = dispConf.getCurrentDsiplayMode(dispConf.getMainDisplayID());
        }
    }
    else if (key == 'l')
    {
        dispConf.arrangeDisplaysLeftToRight();
    }
    else if (key == 'r')
    {
        dispConf.arrangeDisplaysRightToLeft();
    }
    else if (key == 't')
    {
        dispConf.arrangeDisplaysTopToBottom();
    }
    else if (key == 'b')
    {
        dispConf.arrangeDisplaysBottomToTop();
    }
    else if (key == 's')
    {
        vector<CGSDisplayMode> modes = dispConf.getDisplayModes(dispConf.getMainDisplayID());
        vector<int> rdmMode;
        for (auto mode : modes)
        {
            if (mode.modeNumber != initialDispModeOfMain)
            {
                rdmMode.push_back(mode.modeNumber);
            }
        }
        if (rdmMode.size())
        {
            ofRandomize(rdmMode);
            dispConf.setDisplayMode(dispConf.getMainDisplayID(), rdmMode.front());
        }
    }
    else if (key == 'q')
    {
        dispConf.setDisplayMode(dispConf.getMainDisplayID(), initialDispModeOfMain);
    }
    else if (key == '1')
    {
        dispConf.openPrefDisplayTab();
    }
    else if (key == '2')
    {
        dispConf.openPrefArrangeTab();
    }
    else if (key == '3')
    {
        dispConf.openPrefColorTab();
    }
}



void ofApp::exit()
{
    dispConf.setDisplayMode(dispConf.getMainDisplayID(), initialDispModeOfMain);
}

void ofApp::update(){}
void ofApp::keyReleased(int key){}
void ofApp::mouseMoved(int x, int y){}
void ofApp::mouseDragged(int x, int y, int button){}
void ofApp::mousePressed(int x, int y, int button){}
void ofApp::mouseReleased(int x, int y, int button){}
void ofApp::windowResized(int w, int h){}
void ofApp::gotMessage(ofMessage msg){}
void ofApp::dragEvent(ofDragInfo dragInfo){}