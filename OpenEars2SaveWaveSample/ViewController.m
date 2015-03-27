//
//  ViewController.m
//  OpenEars2SaveWaveSample
//
//  Created by usadaxue on 15/1/23.
//  Copyright (c) 2015年 mojifan. All rights reserved.
//

#import "ViewController.h"
#import <OpenEars/OEPocketsphinxController.h>
#import <OpenEars/OEAcousticModel.h>
#import "OEContinuousModel+SaveWave.h"
@interface ViewController (){
    NSMutableData *_audioBuffer;
    AVAudioPlayer *_audioPlayer;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //title label
    UILabel *titleLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, 50,CGRectGetWidth(self.view.frame), 30)];
    titleLbl.text=@"OpenEars2.x获取音频DEMO";
    [self.view addSubview:titleLbl];
    //start btn
    
    UIButton *startBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    startBtn.frame=CGRectMake(100, 100, 50, 30);
    [startBtn setTitle:@"开始" forState:UIControlStateNormal];
    startBtn.backgroundColor=[UIColor grayColor];
    [startBtn addTarget:self action:@selector(startBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startBtn];
    //end
    UIButton *endBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    endBtn.frame=CGRectMake(100, 200, 50, 30);
    [endBtn setTitle:@"结束" forState:UIControlStateNormal];
    endBtn.backgroundColor=[UIColor grayColor];
    [endBtn addTarget:self action:@selector(endBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:endBtn];
    
    
    //buffer通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(availableBuffer:) name:@"AvailableBuffer" object:nil];
    
    self.openEarsEventsObserver = [[OEEventsObserver alloc] init];
    self.openEarsEventsObserver.delegate = self;
}

-(void)startBtnClick:(id)sender{
    
    if(![OEPocketsphinxController sharedInstance].isListening) {
        //设置输出音频数据
        [[OEPocketsphinxController sharedInstance] setOutputAudio:YES];
        //[[OEPocketsphinxController sharedInstance] setVerbosePocketSphinx:YES];//输出详细信息
        [[OEPocketsphinxController sharedInstance]setReturnNullHypotheses:YES];//返回空数据
        [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil];
        [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:[[NSBundle mainBundle] pathForResource:@"4784" ofType:@"languagemodel"] dictionaryAtPath:[[NSBundle mainBundle] pathForResource:@"4784" ofType:@"dic"] acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:FALSE]; // Start speech recognition if we aren't already listening.
    }
}
-(void)endBtnClick:(id)sender{
    NSError *error = nil;
    if([OEPocketsphinxController sharedInstance].isListening) { // Stop if we are currently listening.
        error = [[OEPocketsphinxController sharedInstance] stopListening];
        if(error)NSLog(@"Error stopping listening in stopButtonAction: %@", error);
    }
}
#pragma mark -
#pragma mark OEEventsObserver delegate methods

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    
    NSLog(@"Local callback: The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID); // Log it.
    
    [[OEPocketsphinxController sharedInstance] suspendRecognition];//暂停
    //播放声音
    [self playAudio:[self mergeWavHeaderData:_audioBuffer]];
    _audioBuffer=nil;
    
}

#ifdef kGetNbest
- (void) pocketsphinxDidReceiveNBestHypothesisArray:(NSArray *)hypothesisArray { // Pocketsphinx has an n-best hypothesis dictionary.
    NSLog(@"Local callback:  hypothesisArray is %@",hypothesisArray);
}
#endif
// An optional delegate method of OEEventsObserver which informs that there was an interruption to the audio session (e.g. an incoming phone call).
- (void) audioSessionInterruptionDidBegin {
    NSLog(@"Local callback:  AudioSession interruption began."); // Log it.
    
}

// An optional delegate method of OEEventsObserver which informs that the interruption to the audio session ended.
- (void) audioSessionInterruptionDidEnd {
    NSLog(@"Local callback:  AudioSession interruption ended."); // Log it.
    
}

// An optional delegate method of OEEventsObserver which informs that the audio input became unavailable.
- (void) audioInputDidBecomeUnavailable {
    NSLog(@"Local callback:  The audio input has become unavailable"); // Log it.
    
}

// An optional delegate method of OEEventsObserver which informs that the unavailable audio input became available again.
- (void) audioInputDidBecomeAvailable {
    NSLog(@"Local callback: The audio input is available"); // Log it.
    
}
// An optional delegate method of OEEventsObserver which informs that there was a change to the audio route (e.g. headphones were plugged in or unplugged).
- (void) audioRouteDidChangeToRoute:(NSString *)newRoute {
    NSLog(@"Local callback: Audio route change. The new audio route is %@", newRoute); // Log it.
    
}

// An optional delegate method of OEEventsObserver which informs that the Pocketsphinx recognition loop has entered its actual loop.
// This might be useful in debugging a conflict between another sound class and Pocketsphinx.
- (void) pocketsphinxRecognitionLoopDidStart {
    
    NSLog(@"Local callback: Pocketsphinx started."); // Log it.
    
}

// An optional delegate method of OEEventsObserver which informs that Pocketsphinx is now listening for speech.
- (void) pocketsphinxDidStartListening {
    
    NSLog(@"Local callback: Pocketsphinx is now listening."); // Log it.
    
}

// An optional delegate method of OEEventsObserver which informs that Pocketsphinx detected speech and is starting to process it.
- (void) pocketsphinxDidDetectSpeech {
    NSLog(@"Local callback: Pocketsphinx has detected speech."); // Log it.
    
}

// An optional delegate method of OEEventsObserver which informs that Pocketsphinx detected a second of silence, indicating the end of an utterance.
// This was added because developers requested being able to time the recognition speed without the speech time. The processing time is the time between
// this method being called and the hypothesis being returned.
- (void) pocketsphinxDidDetectFinishedSpeech {
    NSLog(@"Local callback: Pocketsphinx has detected a second of silence, concluding an utterance."); // Log it.
    
}


// An optional delegate method of OEEventsObserver which informs that Pocketsphinx has exited its recognition loop, most
// likely in response to the OEPocketsphinxController being told to stop listening via the stopListening method.
- (void) pocketsphinxDidStopListening {
    NSLog(@"Local callback: Pocketsphinx has stopped listening."); // Log it.
    
}

// An optional delegate method of OEEventsObserver which informs that Pocketsphinx is still in its listening loop but it is not
// Going to react to speech until listening is resumed.  This can happen as a result of Flite speech being
// in progress on an audio route that doesn't support simultaneous Flite speech and Pocketsphinx recognition,
// or as a result of the OEPocketsphinxController being told to suspend recognition via the suspendRecognition method.
- (void) pocketsphinxDidSuspendRecognition {
    NSLog(@"Local callback: Pocketsphinx has suspended recognition."); // Log it.
    
}

// An optional delegate method of OEEventsObserver which informs that Pocketsphinx is still in its listening loop and after recognition
// having been suspended it is now resuming.  This can happen as a result of Flite speech completing
// on an audio route that doesn't support simultaneous Flite speech and Pocketsphinx recognition,
// or as a result of the OEPocketsphinxController being told to resume recognition via the resumeRecognition method.
- (void) pocketsphinxDidResumeRecognition {
    NSLog(@"Local callback: Pocketsphinx has resumed recognition."); // Log it.
    
}

// An optional delegate method which informs that Pocketsphinx switched over to a new language model at the given URL in the course of
// recognition. This does not imply that it is a valid file or that recognition will be successful using the file.
- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
    NSLog(@"Local callback: Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

// An optional delegate method of OEEventsObserver which informs that Flite is speaking, most likely to be useful if debugging a
// complex interaction between sound classes. You don't have to do anything yourself in order to prevent Pocketsphinx from listening to Flite talk and trying to recognize the speech.
- (void) fliteDidStartSpeaking {
    NSLog(@"Local callback: Flite has started speaking"); // Log it.
    
}

// An optional delegate method of OEEventsObserver which informs that Flite is finished speaking, most likely to be useful if debugging a
// complex interaction between sound classes.
- (void) fliteDidFinishSpeaking {
    NSLog(@"Local callback: Flite has finished speaking"); // Log it.
    
}

- (void) pocketSphinxContinuousSetupDidFailWithReason:(NSString *)reasonForFailure { // This can let you know that something went wrong with the recognition loop startup. Turn on [OELogging startOpenEarsLogging] to learn why.
    NSLog(@"Local callback: Setting up the continuous recognition loop has failed for the reason %@, please turn on [OELogging startOpenEarsLogging] to learn more.", reasonForFailure); // Log it.
    
}

- (void) pocketSphinxContinuousTeardownDidFailWithReason:(NSString *)reasonForFailure { // This can let you know that something went wrong with the recognition loop startup. Turn on [OELogging startOpenEarsLogging] to learn why.
    NSLog(@"Local callback: Tearing down the continuous recognition loop has failed for the reason %@, please turn on [OELogging startOpenEarsLogging] to learn more.", reasonForFailure); // Log it.
    
}

- (void) testRecognitionCompleted { // A test file which was submitted for direct recognition via the audio driver is done.
    NSLog(@"Local callback: A test file which was submitted for direct recognition via the audio driver is done."); // Log it.
    
    
}
/** Pocketsphinx couldn't start because it has no mic permissions (will only be returned on iOS7 or later).*/
- (void) pocketsphinxFailedNoMicPermissions {
    NSLog(@"Local callback: The user has never set mic permissions or denied permission to this app's mic, so listening will not start.");
    
}

/** The user prompt to get mic permissions, or a check of the mic permissions, has completed with a TRUE or a FALSE result  (will only be returned on iOS7 or later).*/
- (void) micPermissionCheckCompleted:(BOOL)result {
    NSLog(@"mic check completed with result :%i",result);
    
}

- (void) availableBuffer:(id)sender {
    NSLog(@"buffer received");
    NSDictionary *userInfo = (NSDictionary *)[sender userInfo];
    NSData *buffer = userInfo[@"Buffer"];
    if(_audioBuffer==nil){
        _audioBuffer=[[NSMutableData alloc]init];
    }
    [_audioBuffer appendData:buffer];
}

-(void)playAudio:(NSData *)audioData{
    
    NSError *error=nil;
    _audioPlayer=[[AVAudioPlayer alloc]initWithData:audioData error:&error];
    _audioPlayer.delegate=self;
    if(_audioPlayer!=nil){
        if([_audioPlayer prepareToPlay]&&[_audioPlayer play]){
            NSLog(@"success play");
        }else{
            NSLog(@"failed to play");
        }
    }else{
        NSLog(@"failed to instantiate");
    }
    
}
//添加wav头
-(NSMutableData *)mergeWavHeaderData:(NSMutableData *)data{
    
    long totalAudioLen = 0;
    long totalDataLen = 0;
    long longSampleRate = 16000;//11025.0
    int channels = 1;
    long byteRate = 16 * 16000 * channels/8;
    
    totalAudioLen=[data length];
    totalDataLen=totalAudioLen+44;
    
    
    Byte *header=(Byte *)malloc(44);
    header[0] = 'R'; // RIFF/WAVE header
    header[1] = 'I';
    header[2] = 'F';
    header[3] = 'F';
    header[4] = (Byte) (totalDataLen & 0xff);
    header[5] = (Byte) ((totalDataLen >> 8) & 0xff);
    header[6] = (Byte) ((totalDataLen >> 16) & 0xff);
    header[7] = (Byte) ((totalDataLen >> 24) & 0xff);
    header[8] = 'W';
    header[9] = 'A';
    header[10] = 'V';
    header[11] = 'E';
    header[12] = 'f'; // 'fmt ' chunk
    header[13] = 'm';
    header[14] = 't';
    header[15] = ' ';
    header[16] = 16; // 4 bytes: size of 'fmt ' chunk
    header[17] = 0;
    header[18] = 0;
    header[19] = 0;
    header[20] = 1; // format = 1
    header[21] = 0;
    header[22] = (Byte) channels;
    header[23] = 0;
    header[24] = (Byte) (longSampleRate & 0xff);
    header[25] = (Byte) ((longSampleRate >> 8) & 0xff);
    header[26] = (Byte) ((longSampleRate >> 16) & 0xff);
    header[27] = (Byte) ((longSampleRate >> 24) & 0xff);
    header[28] = (Byte) (byteRate & 0xff);
    header[29] = (Byte) ((byteRate >> 8) & 0xff);
    header[30] = (Byte) ((byteRate >> 16) & 0xff);
    header[31] = (Byte) ((byteRate >> 24) & 0xff);
    header[32] = (Byte) (2 * 8 / 8); // block align
    header[33] = 0;
    header[34] = 16; // bits per sample
    header[35] = 0;
    header[36] = 'd';
    header[37] = 'a';
    header[38] = 't';
    header[39] = 'a';
    header[40] = (Byte) (totalAudioLen & 0xff);
    header[41] = (Byte) ((totalAudioLen >> 8) & 0xff);
    header[42] = (Byte) ((totalAudioLen >> 16) & 0xff);
    header[43] = (Byte) ((totalAudioLen >> 24) & 0xff);
    
    NSData *headerData=[NSData dataWithBytes:header length:44];
    
    NSMutableData *soundData=[[NSMutableData alloc]init];
    [soundData appendData:[headerData subdataWithRange:NSMakeRange(0, 44)]];
    [soundData appendData:data];
    return soundData;
    
}
#pragma mark --avaudioplayer delegate

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"play finished-------------------------");
    [[OEPocketsphinxController sharedInstance]resumeRecognition];//恢复识别
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    NSLog(@"'decode error======================");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
