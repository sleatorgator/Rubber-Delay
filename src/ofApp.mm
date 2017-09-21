
#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
    // BGG audio stuff
    
    int sr = 44100;
    int nbufs = 2; // you can use more for more processing but latency will suffer
    
    nchans = 2;
    framesize = 512;
    
    s_audio_outbuf = (short*)malloc(nchans*framesize*sizeof(short));
    s_audio_inbuf = (short*)malloc(nchans*framesize*sizeof(short));
   
    ofBackground(0, 0, 0);
    touched[0] = 0;
    
    // initialize RTcmix
    rtcmixmain();
    maxmsp_rtsetparams(sr, nchans, framesize, NULL, NULL);

    
//FOR AUDIO INPUT = nchans, 1, sr, framesize, nbufs...

    ofSoundStreamSetup(nchans, 0, sr, framesize, nbufs);
    ofSoundStreamStart();
    
    char *thescore = { " \
        wave = maketable(\"wave\", 1000, \"saw\") \
        xDown=0 \
        yDown=0 \
        bus_config(\"WAVETABLE\", \"aux 1 out\") \
        bus_config(\"MOOGVCF\", \"aux 1 in\", \"aux 2 out\") \
        bus_config(\"JDELAY\", \"aux 2 in\", \"aux 3 out\") \
        bus_config(\"DEL1\", \"aux 3 in\", \"out 0-1\") \
        "};
    parse_score(thescore, strlen(thescore));
}


void ofApp::audioReceived(float * input, int bufferSize, int nChannels) {
    for (int i = 0; i < framesize*nchans; i++) {
        // transfer to the short s_audio_inbuf (mono in, stereo to RTcmix)
        s_audio_inbuf[i*2] = (input[i]*32768.0);
        s_audio_inbuf[i*2+1] = (input[i]*32768.0);
    }
}


void ofApp::audioRequested(float * output, int bufferSize, int nChannels) {
    pullTraverse(NULL, s_audio_outbuf);
    
    for (int i = 0; i < framesize*nchans; i++)
        output[i] = (float)s_audio_outbuf[i]/32786.0; // transfer to the float *output buf
    
    
    if (check_bang() == 1) {
    }
    
    char *pbuf = get_print();
    char *pbufptr = pbuf;
    while (strlen(pbufptr) > 0) {
        ofLog() << pbufptr;
        pbufptr += (strlen(pbufptr) + 1);
    }
    reset_print();
}


//--------------------------------------------------------------
void ofApp::update(){
    
}

//--------------------------------------------------------------
void ofApp::draw(){
    
    if (touched[0] == 1) {
        ofSetColor(255, 0, 0);
        float x0 = x[0];
        float y0 = y[0];
        float x1 = x[1];
        float y1 = y[1];
        ofLine(x0, y0, x1, y1);}
}

//--------------------------------------------------------------
void ofApp::exit(){
    
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
   

        x[0] = touch.x;
        y[0] = touch.y;
    
    
    CFTimeInterval startTime = CACurrentMediaTime();
    
    char thescore[1024];
    
    sprintf(thescore, "time = %f \
            xDown = (%f*(9/320))+5 \
            yDown = ((568-%f)*(8/568))+4", startTime, touch.x, touch.y);
    
    parse_score(thescore, strlen(thescore));
    
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){
    
    x[1] = touch.x;
    y[1] = touch.y;


    
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    
    char thescore[1024];
    
    sprintf(thescore, "dur = %f-time \
            xUp = (%f*(9/320))+5 \
            yUp = ((568-%f)*(8/568))+4 \
            pEnv = maketable(\"line\", \"nonorm\", 1000, 0, cpsoct(yDown), dur, cpsoct(yUp)) \
            fEnv = maketable(\"line\", \"nonorm\", 1000, 0, cpsoct(xDown), dur, cpsoct(xUp)) \
            WAVETABLE(0, dur, 10000, pEnv, 0, wave) \
            MOOGVCF(0, 0, dur, 1, 0, 0.5, 0, fEnv, .25) \
            JDELAY(0, 0, dur, 4, dur, .8, (dur*20), 500, .5) \
            DEL1(0, 0, 7, 1.0, .01, 1.0) ", CACurrentMediaTime(), touch.x, touch.y);
    parse_score(thescore, strlen(thescore));
    
        touched[0] = 1;

}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::lostFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){
    
}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){
    
}

