//
//  Alarm.h
//  testBudist
//
//  Created by Чингис on 02.06.13.
//  Copyright (c) 2013 Чингис. All rights reserved.
//

#import "Model.h"
#import "User.h"

@interface Alarm : Model
@property(nonatomic, strong) NSNumber* identifier;
@property(nonatomic, strong) NSString* audio;
@property(nonatomic, strong) NSString* dateTime;
@property(nonatomic, strong) NSNumber* plays;
@property(nonatomic, strong) NSString* rating;
@property(nonatomic, strong) NSNumber* comments;

@property(nonatomic, strong) User* budist;
@property(nonatomic, strong) User* sleepy;

typedef void(^AlarmsSuccessBlock)(NSArray *alarms);
typedef void(^AlarmSuccessBlock)(Alarm *alarm);

typedef void(^AlarmsFailureBlock)(NSDictionary *dict, NSError *error);
-(NSString*)audio;

+ (void)getAlarmsWithSuccess:(AlarmsSuccessBlock)_success failure:(AlarmsFailureBlock)_failure;

-(void)loadAudioWithProgress:(ProgressBlock)_progress success:(SuccessBlock)_success failure:(FailureBlock)_failure;
@end
