//
//  AlarmController.m
//  testBudist
//
//  Created by Чингис on 02.06.13.
//  Copyright (c) 2013 Чингис. All rights reserved.
//

#import "AlarmController.h"


@implementation AlarmController
@synthesize alarm;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"back_dark1_pattern.png"]];
    [self.loaderPlayView setDelegate:self];
    
    //буддист
    self.budistFlagView.image = [UIImage imageNamed:[alarm.budist.countryPrefix lowercaseString]];
    [self.budistAvatarView setImageWithURL:[NSURL URLWithString:alarm.budist.avatar] placeholderfileName:[(NSString*)alarm.budist.sex isEqualToString:@"1"]? @"profile_placeholder_boy_1.png": @"profile_placeholder_girl_1.png"];
    self.lblBudistCountry.text = alarm.budist.region;
    self.lblBudistName.text = alarm.budist.name;
    
    NSLog(@"%@",alarm.sleepy.avatar);
    //соня
    self.sleepyFlagView.image = [UIImage imageNamed:[alarm.sleepy.countryPrefix lowercaseString]];
    [self.sleepyAvatarView setImageWithURL:[NSURL URLWithString:alarm.sleepy.avatar] placeholderfileName:[(NSString*)alarm.sleepy.sex isEqualToString:@"1"]? @"profile_placeholder_boy_1.png": @"profile_placeholder_girl_1.png"];
    self.lblSleepyCountry.text = alarm.sleepy.region;
    self.lblSleepyName.text = alarm.sleepy.name;
    
    //закругляю углы
    self.budistAvatarView.layer.cornerRadius = 5;
    self.budistAvatarView.clipsToBounds = YES;
    self.sleepyAvatarView.layer.cornerRadius = 5;
    self.sleepyAvatarView.clipsToBounds = YES;
    
    [self loadAudio];
    
    [self.audioSlider setThumbImage:[UIImage imageNamed:@"slider.png"] forState:UIControlStateNormal];
    UIImage *sliderLeftTrackImage = [[UIImage imageNamed: @"slider_blue.png"] stretchableImageWithLeftCapWidth: 4 topCapHeight: 0];
    UIImage *sliderRightTrackImage = [[UIImage imageNamed: @"slider_grey.png"] stretchableImageWithLeftCapWidth: 4 topCapHeight: 0];
    [self.audioSlider setMinimumTrackImage: sliderLeftTrackImage forState: UIControlStateNormal];
    [self.audioSlider setMaximumTrackImage: sliderRightTrackImage forState: UIControlStateNormal];
}

-(void)loadAudio
{
    [alarm loadAudioWithProgress:^(float progress) {
        [self.loaderPlayView setProgress:progress];
    } success:^(id object) {
        
        NSError *error = nil;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData:object
                                                         error:&error];
        self.audioPlayer.delegate = self;
    } failure:^(id object, NSError *error) {
        
    }];
}

-(void)loaderPlayBtnDidClicked
{
    if (self.isPlaying)
    {
        // Music is currently playing
        [self.loaderPlayView.loadingBtn setImage:[UIImage imageNamed:@"audio03.png"] forState:UIControlStateNormal];
        [self.audioPlayer pause];
        self.isPlaying = NO;
    } else
    {
        // Music is currenty paused/stopped
        [self.audioPlayer play];
        self.isPlaying = YES;
        [self.loaderPlayView.loadingBtn setImage:[UIImage imageNamed:@"audio04.png"] forState:UIControlStateNormal];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(updateTime)
                                                    userInfo:nil
                                                     repeats:YES];
    }

}

- (void)updateTime {
    
    NSTimeInterval currentTime = self.audioPlayer.currentTime;
    CGFloat progress = currentTime/self.audioPlayer.duration;
    self.audioSlider.value = progress;
    
}
-(void)changeCurrentTime
{
    [self.audioPlayer setCurrentTime:self.audioPlayer.duration*self.audioSlider.value];
}
- (IBAction)sliderDidTouchUp:(id)sender {
    [self changeCurrentTime];
}
- (IBAction)sliderDidTouchUpOutside:(id)sender {
    [self changeCurrentTime];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self loaderPlayBtnDidClicked];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setLblBudistName:nil];
    [self setBudistAvatarView:nil];
    [self setBudistFlagView:nil];
    [self setLoaderPlayView:nil];
    [self setAudioSlider:nil];
    [super viewDidUnload];
}
- (IBAction)dissmissClicked:(id)sender {
    [self.audioPlayer stop];
    [self.timer invalidate];
    
    [self dismissModalViewControllerAnimated:YES];
}
@end
