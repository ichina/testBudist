//
//  AlarmsCell.m
//  testBudist
//
//  Created by Чингис on 02.06.13.
//  Copyright (c) 2013 Чингис. All rights reserved.
//

#import "AlarmsCell.h"
#import "Alarm.h"
@implementation AlarmsCell

-(void)setInfoWithAlarm:(Alarm*)alarm
{
    self.lblComments.text = [alarm.comments stringValue];
    self.lblPlays.text = [alarm.plays stringValue];
    self.lblNames.text = [NSString stringWithFormat:@"%@ -> %@",alarm.budist.name,alarm.sleepy.name];
    
    [self.budistFlagView setImage:[UIImage imageNamed:[alarm.budist.countryPrefix lowercaseString]]];
    [self.sleepyFlagView setImage:[UIImage imageNamed:[alarm.sleepy.countryPrefix lowercaseString]]];
    
}

@end
