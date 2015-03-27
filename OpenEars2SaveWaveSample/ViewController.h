//
//  ViewController.h
//  OpenEars2SaveWaveSample
//
//  Created by usadaxue on 15/1/23.
//  Copyright (c) 2015年 mojifan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <OpenEars/OEEventsObserver.h>
@interface ViewController : UIViewController<AVAudioPlayerDelegate,OEEventsObserverDelegate>

@property (nonatomic, strong) OEEventsObserver *openEarsEventsObserver;
@end

