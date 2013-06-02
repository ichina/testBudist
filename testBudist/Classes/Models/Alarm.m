//
//  Alarm.m
//  testBudist
//
//  Created by Чингис on 02.06.13.
//  Copyright (c) 2013 Чингис. All rights reserved.
//

#import "Alarm.h"
#import "AlarmsListBuilder.h"
#import "HTTPClient.h"

@implementation Alarm

@synthesize identifier;
@synthesize audio;
@synthesize dateTime;
@synthesize plays;
@synthesize rating;
@synthesize comments;

@synthesize budist;
@synthesize sleepy;

-(NSString*)audio
{
    return [NSString stringWithFormat:@"http://budist-records.s3.amazonaws.com/%@",audio];
}

+ (NSMutableArray*)convertArray:(NSArray*)_array
{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:[(NSArray*)_array count]];
    
    for(NSDictionary* dict in _array)
    {
        Alarm* alarm = [[Alarm alloc] initWithContents:dict];
        [array addObject:alarm];
    }
    return array;
}

+ (void)getAlarmsWithSuccess:(AlarmsSuccessBlock)_success failure:(AlarmsFailureBlock)_failure{
    
    NSDictionary* parameters = @{@"type":@"best",
                                 @"now":[self dateWithCurentTimeZone],
                                 @"offset":@"0",
                                 @"limit":@"100"};
    
    //по-хорошему Builder составляет запрос с параметрами, но у меня он не расчитан составлять body в json формат
    KIMutableURLRequest *request = [AlarmsListBuilder buildRequestWithParameters:@{}];
    //поэтому заполняю body в ручную без всякой валидации
    request.HTTPBody = [parameters JSONData];
    
    [Alarm executeRequest:request progress:nil success:^(id object) {
        
        NSDictionary* dict = (NSDictionary*)object;
        if(dict && dict[@"result"] && dict[@"result"][@"items"])
        {
            if(_success) {
                
                _success([self convertArray:dict[@"result"][@"items"] ]);
                
            }
        }
        else
        {
            if(_failure)
                _failure(nil,nil);
        }
    } failure:^(id object, NSError *error) {
        if(_failure)
            _failure(nil,error);
    }];
    
    
}

-(void)loadAudioWithProgress:(ProgressBlock)_progress success:(SuccessBlock)_success failure:(FailureBlock)_failure
{
    KIMutableURLRequest *request = [KIMutableURLRequest requestWithURL:[NSURL URLWithString:self.audio]];
    
    [Alarm executeRequest:request progress:^(float progress) {
        if(_progress)
            _progress(progress);
    } success:^(id object) {
        if(_success)
            _success(object);
    } failure:^(id object, NSError *error) {
        if(_failure)
            _failure(object,error);
    }];
}
//по хорошему эту функцию нада в категорию(((
+ (NSString *)dateWithCurentTimeZone {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone :[NSTimeZone localTimeZone]];
    
    // utc format
    return [dateFormatter stringFromDate:[NSDate date]];
}

@end
