//
//  Message.m
//  iSeller
//
//  Created by Чина on 17.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "Message.h"
#import "Profile.h"
#import "PostMessageBuilder.h"
#import "DialogBuilder.h"

@implementation Message
@synthesize identifier,body,name,incoming,isFresh,createdAt;
+ (NSMutableArray*)convertArray:(NSArray*)_array
{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:[(NSArray*)_array count]];
    
    for(NSDictionary* dict in _array)
    {
        Message* ad = [[Message alloc] initWithContents:dict];
        //[array insertObject:ad atIndex:0];
        [array addObject:ad];
    }
    return array;
}

+ (void)getMessagesWithUID:(NSString*)uid adID:(NSString*)adid lastIdentifier:(NSString *)lastIdentifier firstIdentifier:(NSString *)firstIdentifier success:(AdvertisementsSuccessBlock)_success failure:(AdvertisementsFailureBlock)_failure
{
    NSDictionary *params = @{
    @"user"   : uid,
    @"id"     : adid,
    @"before" : lastIdentifier ? lastIdentifier : @"",
    @"after"  : firstIdentifier ? firstIdentifier : @"",
    @"token"  : [[Profile sharedProfile] token]
    };
    
    KIMutableURLRequest* request = [DialogBuilder buildRequestWithParameters:params];
    
    [self executeRequest:request progress:nil success:^(id object) {
        
        NSMutableArray* array = [self convertArray:object];
        
        if(_success)
            _success(array);
        
    } failure:^(id object, NSError *error) {
        if (_failure)
            _failure(object, error);
    }];
}

+ (void)postMessage:(NSString *)_message withIdentifier:(NSString *)_identifier toUserWithIdentifier:(NSString *)_userid success:(SuccessBlock)_success failure:(FailureBlock)_failure {
    
    NSDictionary *parameters = @{
    @"user" : _userid,
    @"id" : _identifier,
    @"message[body]" : _message,
    @"token": [Profile sharedProfile].token
    };
    
    KIMutableURLRequest* request = [PostMessageBuilder buildRequestWithParameters:parameters];
    
    [self executeRequest:request progress:nil success:^(id object) {
        
        if(_success)
            _success(object);
        
    } failure:^(id object, NSError *error) {
        if (_failure)
            _failure(object, error);
    }];
}

+ (void)getMessagesWithUID:(NSString*)uid adID:(NSString*)adid lastIdentifier:(NSString *)lastIdentifier success:(AdvertisementsSuccessBlock)_success failure:(AdvertisementsFailureBlock)_failure
{
    [self getMessagesWithUID:uid adID:adid lastIdentifier:lastIdentifier firstIdentifier:@"" success:^(NSArray *ads) {
        _success(ads);
    } failure:^(NSDictionary *dict, NSError *error) {
        _failure(dict,error);
    }];
}
+ (void)getMessagesWithUID:(NSString*)uid adID:(NSString*)adid firstIdentifier:(NSString *)firstIdentifier success:(AdvertisementsSuccessBlock)_success failure:(AdvertisementsFailureBlock)_failure
{
    [self getMessagesWithUID:uid adID:adid lastIdentifier:@"" firstIdentifier:firstIdentifier success:^(NSArray *ads) {
        _success(ads);
    } failure:^(NSDictionary *dict, NSError *error) {
        _failure(dict,error);
    }];
}


@end
