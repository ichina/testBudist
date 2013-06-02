//
//  AlarmsCell.h
//  testBudist
//
//  Created by Чингис on 02.06.13.
//  Copyright (c) 2013 Чингис. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Alarm.h"

@interface AlarmsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblNames;
@property (weak, nonatomic) IBOutlet UILabel *lblPlays;
@property (weak, nonatomic) IBOutlet UILabel *lblComments;
@property (weak, nonatomic) IBOutlet UIImageView *budistFlagView;
@property (weak, nonatomic) IBOutlet UIImageView *sleepyFlagView;

-(void)setInfoWithAlarm:(Alarm*)alarm;

@end
