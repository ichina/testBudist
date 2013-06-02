//
//  AlarmController.h
//  testBudist
//
//  Created by Чингис on 02.06.13.
//  Copyright (c) 2013 Чингис. All rights reserved.
//

#import "BaseController.h"
#import "Alarm.h"
#import "LoaderPlayView.h"
#import <AVFoundation/AVFoundation.h>

@interface AlarmController : BaseController <LoaderPlayViewDelegate,AVAudioPlayerDelegate>

@property (nonatomic,strong) Alarm* alarm;

@property (weak, nonatomic) IBOutlet UILabel *lblBudistName;
@property (weak, nonatomic) IBOutlet UIImageView *budistAvatarView;
@property (weak, nonatomic) IBOutlet UIImageView *budistFlagView;
@property (weak, nonatomic) IBOutlet UILabel *lblBudistCountry;

@property (weak, nonatomic) IBOutlet UILabel *lblSleepyName;
@property (weak, nonatomic) IBOutlet UIImageView *sleepyAvatarView;
@property (weak, nonatomic) IBOutlet UIImageView *sleepyFlagView;
@property (weak, nonatomic) IBOutlet UILabel *lblSleepyCountry;

@property (weak, nonatomic) IBOutlet UISlider *audioSlider;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic, strong) NSTimer *timer;


@property (weak, nonatomic) IBOutlet LoaderPlayView *loaderPlayView;

- (IBAction)dissmissClicked:(id)sender;

@end
