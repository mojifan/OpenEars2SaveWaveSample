//
//  OEContinuousModel+SaveWave.m
//  OpenEars2SaveWaveSample
//
//  Created by usadaxue on 15/1/23.
//  Copyright (c) 2015年 mojifan. All rights reserved.
//

#import "OEContinuousModel+SaveWave.h"

@implementation OEContinuousModel (SaveWave)

- (void) processBuffer:(NSData *)buffer {
    if(self.pocketSphinxDecoder == NULL || _stopping) return; // If we ever get here without a started pocketSphinxDecoder we have nothing to do here. We're going to be extremely careful not to do stuff with a pocketsphinx we've released.
    
    if(!_stopping && self.thereIsALanguageModelChangeRequest)[self validateAndPerformLanguageModelChange]; // If there is a request to change models, go away and do that first.
    
    if(self.requestToResume) { // If we're returning from a suspension, flush everything and reset so we don't get hypotheses which began before the suspension after it is over.
        self.requestToResume = FALSE;
        [self performSingularStopForDecoder:self.pocketSphinxDecoder];
        [self resetForNewUtteranceWithContextString:@"of resuming after an interruption"];
    }
    
    if(!_stopping && self.utteranceState == kUtteranceStateUnstarted) { // We only start the utterance if this is the first opportunity to do so.
        
        if ([self startUtterance] < 0) {
            [self announceSetupFailureForReason:@"Initial start of utterance failed."];
            return;
        } else {
            self.utteranceState = kUtteranceStateStarted;
        }
    }
    
    if(!_stopping) {
        [self processRaw:buffer];
        self.speechFramesFound = [self getInSpeech];
    }
    if (!_stopping && self.speechFramesFound && !self.speechAlreadyInProgress) { // Possibility 1: we have just found the beginning of speech.
        self.speechAlreadyInProgress = TRUE;
        self.stuckUtterance = [NSDate timeIntervalSinceReferenceDate];
        [self announceSpeechDetection]; // We have speech if we get here.
        
    }
    
    BOOL exitEarly = FALSE;
    
    if(!_stopping && self.speechFramesFound && self.speechAlreadyInProgress) { // Possibility 2: this is more of ongoing speech.
        if(self.outputAudio){
            [[NSNotificationCenter defaultCenter]postNotificationName:@"AvailableBuffer" object:nil userInfo:@{@"Buffer":buffer}];
        }
        
        if(([NSDate timeIntervalSinceReferenceDate] - self.stuckUtterance) > 25.0) { // If this is a stuck recognition, provide the possibility to end the utterance.
            if([self openEarsLoggingIsOn] || [self verbosePocketsphinxIsOn])NSLog(@"An utterance appears to be stuck in listening mode. Exiting stuck utterance.");
            self.stuckUtterance = [NSDate timeIntervalSinceReferenceDate];
            self.speechFramesFound = FALSE;
            
            exitEarly = TRUE;
        }
    }
    
    if (!_stopping && ((!self.speechFramesFound && self.speechAlreadyInProgress) || (exitEarly))) { // Possibility 3: has completed.
        self.speechAlreadyInProgress = FALSE;
        [self announceSpeechCompleted];
        [self endUtterance];
        
        self.utteranceState = kUtteranceStateEnded;
        if(!exitEarly)[self getAndReturnHypothesisForDecoder:self.pocketSphinxDecoder]; // Get hyp but not if the utterance is stuck
        
        if(!_stopping) {
            if ([self startUtterance] < 0) { // We know that kUtteranceState is ended here, we don't have to check.
                [self announceSetupFailureForReason:@"Resumption of starting utterance after a previous successful start failed."];
                return;
            }
        }
        
        self.utteranceState = kUtteranceStateStarted;
        self.stuckUtterance = [NSDate timeIntervalSinceReferenceDate];
    }
}


@end
