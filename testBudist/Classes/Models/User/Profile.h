//
//  Profile.h
//  iSeller
//
//  Created by Paul Semionov on 09.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "User.h"

#import "KeychainItemWrapper.h"

@interface Profile : User
{
    NSTimer* messagesStateTimer;
}
typedef void (^AuthBlockSuccess)(void);
typedef void (^AuthBlockFailure)(NSError* error);

@property (nonatomic, retain) UIImage *avatarImage;
@property (nonatomic, strong) NSNumber* deviceID;

@property(nonatomic, strong) NSNumber* balance;

@property (nonatomic, strong) NSString* vkToken;

@property (nonatomic, strong) NSString *tempToken;

@property (nonatomic, strong) NSArray* authProviders;

@property (nonatomic, retain) NSNumber *confirmed;

@property (nonatomic, retain) NSNumber *currentPrice;


+ (Profile *)sharedProfile;

- (BOOL)isMyId:(NSNumber*)identifier;
- (BOOL)hasToken;
- (BOOL)isConfirmed;

- (void)logout;

- (void)authorizeUserWithTokenSuccess:(AuthBlockSuccess)_success failure:(AuthBlockFailure)_failure;
- (void)authorizeUserWithLogin:(NSString *)login andPassword:(NSString *)password success:(AuthBlockSuccess)_success failure:(AuthBlockFailure)_failure;
- (void)authorizeUserWithSocialToken:(NSString*)token provider:(NSString*)provider success:(AuthBlockSuccess)_success failure:(AuthBlockFailure)_failure;
- (void)signUpWithEmail:(NSString*) email name:(NSString*)name pass:(NSString *) password success:(AuthBlockSuccess)_success failure:(AuthBlockFailure)_failure;
- (void)updateProfileWithParams:(NSDictionary *)params progress:(ProgressBlock)_progress success:(AuthBlockSuccess)_success failure:(AuthBlockFailure)_failure;
- (void)sendConfirmationWithProgress:(ProgressBlock)_progress success:(AuthBlockSuccess)_success failure:(AuthBlockFailure)_failure;
- (void)getBalanceWithSuccess:(AuthBlockSuccess)_success failure:(AuthBlockFailure)_failure;


-(void) removeDeviceFromProfileWithSuccess:(AuthBlockSuccess)_success failure:(AuthBlockFailure)_failure;

-(void)restorePassword:(NSString* ) email withSuccess:(AuthBlockSuccess)_success failure:(AuthBlockFailure)_failure;

+(void)getVKFriends:(NSURL* )url success:(void(^)(NSDictionary* s))_success failure:(void(^)(NSDictionary* dict,NSError* s))_failure;

-(void)checkMessagesStateAfterUpdateDialogs; //вызывается из дата сорса диалогов

-(BOOL)vkAttached;
-(BOOL)fbAttached;

@end
