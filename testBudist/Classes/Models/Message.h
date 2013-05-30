//
//  Message.h
//  iSeller
//
//  Created by Чина on 17.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "Model.h"
#import "Advertisement.h"

@interface Message : Model

@property(nonatomic, strong) NSNumber* identifier;
@property(nonatomic, strong) NSString* body;
@property(nonatomic, strong) NSNumber* incoming;
@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) NSString* createdAt;
@property(nonatomic, strong) NSNumber* isFresh;

+ (void)getMessagesWithUID:(NSString*)uid adID:(NSString*)adid lastIdentifier:(NSString *)lastIdentifier success:(AdvertisementsSuccessBlock)_success failure:(AdvertisementsFailureBlock)_failure;
+ (void)getMessagesWithUID:(NSString*)uid adID:(NSString*)adid firstIdentifier:(NSString *)firstIdentifier success:(AdvertisementsSuccessBlock)_success failure:(AdvertisementsFailureBlock)_failure;
+ (void)postMessage:(NSString *)_message withIdentifier:(NSString *)_identifier toUserWithIdentifier:(NSString *)_userid success:(SuccessBlock)_success failure:(FailureBlock)_failure;
@end
