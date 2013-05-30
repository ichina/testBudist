//
//  Profile.m
//  iSeller
//
//  Created by Paul Semionov on 09.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "Profile.h"
#import "HTTPClient.h"
#import "PlainAuthenticationBuilder.h"
#import "TokenAuthenticationBuilder.h"
#import "FBAuthenticationBuilder.h"
#import "SignUpBuilder.h"
#import "PutProfileBuilder.h"
#import "NSString+Extensions.h"
#import "AddDeviceBuilder.h"
#import "RemoveDeviceBuilder.h"
#import "RestorePasswordBuilder.h"
#import "EmailConfirmationBuilder.h"
#import "BalanceBuilder.h"
#import "MessageStateBuilder.h"

#import "NSDate+Extensions.h"

#import "CGSocialManager.h"

@interface Profile()

@property (nonatomic, retain) NSMutableDictionary *failedSelector;

@end

@implementation Profile

@synthesize avatarImage;
@synthesize vkToken = _vkToken;
@synthesize tempToken = _tempToken;
@synthesize confirmed;
@synthesize balance;

@synthesize failedSelector = _failedSelector;

@synthesize name = _name;
@synthesize deviceToken = _deviceToken;
@synthesize authProviders;
#pragma mark Singleton methods

static Profile *instance_;
static int messagesCountObservanceContext;

+ (Profile *)sharedProfile {
    @synchronized(self) {
        if( instance_ == nil ) {
            instance_ = [[self alloc] init];
        }
    }
    
    return instance_;
}

- (id)init {
    self = [super init];
    instance_ = self;
    
    KeychainItemWrapper *keyChainMainToken = [[KeychainItemWrapper alloc] initWithIdentifier:@"iSeller" accessGroup:nil];
    
    self.token = [keyChainMainToken objectForKey:(__bridge id)kSecValueData];
    
    KeychainItemWrapper *keyChainURItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"iSellerUR" accessGroup:nil];
        
    if(self.token.length == 0 && [[keyChainURItem objectForKey:(__bridge id)kSecValueData] length] == 0) {
        
        self.tempToken = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
        
        KeychainItemWrapper *keyChainURItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"iSellerUR" accessGroup:nil];
        [keyChainURItem setObject:@"iSellerUR" forKey:(__bridge id)kSecAttrService];
        [keyChainURItem setObject:self.tempToken forKey:(__bridge id)kSecValueData];
                
    }else if(self.token.length == 0 && [[keyChainURItem objectForKey:(__bridge id)kSecValueData] length] > 0) {
        
        self.tempToken = [keyChainURItem objectForKey:(__bridge id)kSecValueData];
        
    }
    
    KeychainItemWrapper *keyChainVKToken = [[KeychainItemWrapper alloc] initWithIdentifier:@"iSellerVK" accessGroup:nil];
    
    self.vkToken = [[keyChainVKToken objectForKey:(__bridge id)kSecValueData] length] > 0 ? [keyChainVKToken objectForKey:(__bridge id)kSecValueData] : nil;
    
    /*
    if([self hasToken])
    {
        //типа туториал уже был показан (для случая когда приложение установили, прудварительно удалив, ведь токен сохранился в keychain)
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"tutorialIsAlreadyShowed"];
            [[NSUserDefaults standardUserDefaults] synchronize];
    }
    */
    
    [super addObserver:self forKeyPath:@"messagesCount" options:0 context:&messagesCountObservanceContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifierDidReceived:) name:@"DidReceiveMessage" object:[[UIApplication sharedApplication] delegate]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    
    messagesStateTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(checkMessagesState) userInfo:nil repeats:YES];
    
    self.failedSelector = [NSMutableDictionary dictionary];
    
    self.avatarImage = [UIImage imageNamed:@"smile.png"];
    
    if([self hasToken]) {
        
        self.name = [[NSUserDefaults standardUserDefaults] objectForKey:self.token];
        
    }
    
    return self;
}

- (BOOL)isMyId:(NSNumber *)identifier{
    
    return identifier.intValue == self.identifier.intValue ;
    
}

- (BOOL)hasToken {
    
    NSLog(@"Has token: %@, %@", self.token.length ? @"YES" : @"NO", self.token);
    
    return self.token && (self.token.length > 0) ? YES : NO;
    
}

- (BOOL)isConfirmed {
    
    return [confirmed boolValue];
    
}

- (void)authorizeUserWithLogin:(NSString *)login andPassword:(NSString *)password success:(AuthBlockSuccess)_success failure:(AuthBlockFailure)_failure{
    
    NSDictionary* parameters = @{@"email" : login,
    @"password" : password};

    KIMutableURLRequest *request = [PlainAuthenticationBuilder buildRequestWithParameters:parameters];
            
    [Profile executeRequest:request progress:nil success:^(id object) {
        [self fillWithContents:object];
        NSLog(@"%@",object[@"token"]);
        [self archiveToken:self.token];
        
        if(_success) {
            
            _success();
            
        }
        
        if(self.deviceToken)
        {
            [self addDeviceToProfile:self.deviceToken success:^{
                
            } failure:^(NSError *error) {
                                
            }];
        }
        
        [self loadProfileImage];
        [[HTTPClient sharedClient] setAuthorizationHeaderWithToken:object[@"token"]];
        
    } failure:^(id object, NSError *error) {
        _failure(error);
    }];
    
}

- (void)authorizeUserWithTokenSuccess:(AuthBlockSuccess)_success failure:(AuthBlockFailure)_failure {

    NSDictionary* parameters = @{
    @"token" : self.token
    };
    
    KIMutableURLRequest *request = [TokenAuthenticationBuilder buildRequestWithParameters:parameters];
        
    __weak __typeof(&*self)weakSelf = self;
    
    SEL cmd = _cmd;

    [Profile executeRequest:request progress:nil success:^(id object) {
        [self fillWithContents:object];
        NSLog(@"%@",object[@"token"]);
        [self archiveToken:self.token];
        
        if(_success) {
            
            _success();
            
        }
        
        if(NSSelectorFromString([weakSelf.failedSelector valueForKey:@"sel"]) == cmd) {
            
            [weakSelf.failedSelector removeAllObjects];
            
        }
        
        if(self.deviceToken)
        {
            [self addDeviceToProfile:self.deviceToken success:^{

            } failure:^(NSError *error) {
                
            }];
        }
        [self loadProfileImage];
        [[HTTPClient sharedClient] setAuthorizationHeaderWithToken:object[@"token"]];
        
        
        
    } failure:^(id object, NSError *error) {
                
        if(_failure) {
            
            _failure(error);
            
        }
        
        [weakSelf.failedSelector setObject:NSStringFromSelector(cmd) forKey:@"sel"];
        [weakSelf.failedSelector setObject:_success forKey:@"arg1"];
        [weakSelf.failedSelector setObject:_failure forKey:@"arg2"];
        
    }];
    
}

- (void)authorizeUserWithSocialToken:(NSString*)token provider:(NSString*)provider success:(AuthBlockSuccess)_success failure:(AuthBlockFailure)_failure
{
    NSMutableDictionary* parameters = [@{
    @"provider" : provider,
    @"code" : token} mutableCopy];
    
    if(self.token && self.token.length>0)
        [parameters setObject:self.token forKey:@"token"];
    
    KIMutableURLRequest *request = [FBAuthenticationBuilder buildRequestWithParameters:parameters];
        
    [Profile executeRequest:request progress:nil success:^(id object) {
        [self fillWithContents:object];
        NSLog(@"%@",object[@"token"]);
        
        if(_success) {
            
            _success();
            
        }
        
        if(self.deviceToken)
        {
            [self addDeviceToProfile:self.deviceToken success:^{
                
            } failure:^(NSError *error) {
                NSLog(@"%@",error);
            }];
        }
        
        [self archiveToken:self.token];
        [self loadProfileImage];
        [[HTTPClient sharedClient] setAuthorizationHeaderWithToken:object[@"token"]];
        
    } failure:^(id object, NSError *error) {
        
        if([error.localizedDescription containsString:@"got 409"])
        {
            [[[CGAlertView alloc] initWithTitle:NSLocalizedString(provider, nil) message:NSLocalizedString(@"This email is already attached to another account", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }
        
        if(_failure) {
            
            _failure(error);
            
        }
                
    }];
}

- (void)signUpWithEmail:(NSString*) email name:(NSString*)name pass:(NSString *) password success:(AuthBlockSuccess)_success failure:(AuthBlockFailure)_failure
{
    NSDictionary* parameters = @{
    @"user[email]" : email,
    @"user[name]" : name,
    @"user[password]" : password,
    @"user[device]" : @"ios"};
    
    KIMutableURLRequest *request = [SignUpBuilder buildRequestWithParameters:parameters];
    
    [Profile executeRequest:request progress:nil success:^(id object) {
        [self fillWithContents:object];
        
        if(_success) {
            
            _success();
            
        }
        
        if(self.deviceToken)
        {
            [self addDeviceToProfile:self.deviceToken success:^{
                
            } failure:^(NSError *error) {
                
            }];
        }
        [self loadProfileImage];
        [self archiveToken:self.token];
        [[HTTPClient sharedClient] setAuthorizationHeaderWithToken:object[@"token"]];
        
        
        
    } failure:^(id object, NSError *error) {
        
        if(_failure) {
            
            _failure(error);
            
        }
    }];
}

- (void)sendConfirmationWithProgress:(ProgressBlock)_progress success:(AuthBlockSuccess)_success failure:(AuthBlockFailure)_failure {
    
    NSDictionary* parameters = @{@"token" : self.token};
    
    KIMutableURLRequest *request = [EmailConfirmationBuilder buildRequestWithParameters:parameters];
    
    [Profile executeRequest:request progress:nil success:^(id object) {
                
        if(_success) {
            
            _success();
            
        }
        
    } failure:^(id object, NSError *error) {
        
        if(_failure) {
            
            _failure(error);
            
        }
    }];

    
}

- (void)getBalanceWithSuccess:(AuthBlockSuccess)_success failure:(AuthBlockFailure)_failure {
    
    NSDictionary* parameters = @{@"token" : self.token};
    
    KIMutableURLRequest *request = [BalanceBuilder buildRequestWithParameters:parameters];
    
    [Profile executeRequest:request progress:nil success:^(id object) {
        
        [self fillWithContents:object];
                
        if(_success) {
            
            _success();
            
        }
        
    } failure:^(id object, NSError *error) {
        
        if(_failure) {
            
            _failure(error);
            
        }
    }];
    
}

- (void)logout {
    
    NSArray *profileOperations = [Profile getOperationsWithTag:NSStringFromClass([self class])];
    
    for(HTTPRequestOperation *operation in profileOperations) {
        
        [Profile cancelOperation:operation];
        
    }
    
    [self removeDeviceFromProfileWithSuccess:nil failure:nil];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:self.token];
    
    self.token = nil;
    
    self.identifier = nil;
        
    KeychainItemWrapper *keyChainMainToken = [[KeychainItemWrapper alloc] initWithIdentifier:@"iSeller" accessGroup:nil];
    
    [keyChainMainToken resetKeychainItem];
    
    KeychainItemWrapper *keyChainVKToken = [[KeychainItemWrapper alloc] initWithIdentifier:@"iSellerVK" accessGroup:nil];
    
    [keyChainVKToken resetKeychainItem];
    
    [[CGSocialManager sharedSocialManager] closeSession];
}

- (void)archiveToken:(NSString *)_token {
    
    KeychainItemWrapper *keyChainMainToken = [[KeychainItemWrapper alloc] initWithIdentifier:@"iSeller" accessGroup:nil];
    [keyChainMainToken setObject:@"iSeller" forKey:(__bridge id)kSecAttrService];
    [keyChainMainToken setObject:_token forKey:(__bridge id)kSecValueData];
}

- (void)setVkToken:(NSString *)vkToken {
    
    _vkToken = vkToken;

    if(vkToken) {
        
        KeychainItemWrapper *keyChainVKToken = [[KeychainItemWrapper alloc] initWithIdentifier:@"iSellerVK" accessGroup:nil];
        [keyChainVKToken setObject:@"iSellerVK" forKey:(__bridge id)kSecAttrService];
        [keyChainVKToken setObject:vkToken forKey:(__bridge id)kSecValueData];
        
    }else{
        
        KeychainItemWrapper *keyChainVKToken = [[KeychainItemWrapper alloc] initWithIdentifier:@"iSellerVK" accessGroup:nil];
        
        [keyChainVKToken resetKeychainItem];
        
    }    
}

- (void)loadProfileImage {
    
    if(!self.avatar || self.avatar.length == 0) {
        
        self.avatarImage = [UIImage imageNamed:@"smile.png"];
        
        return;
        
    }
        
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.avatar]];
    
    AFHTTPRequestOperation *operation = [[HTTPClient sharedClient] HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
       
        self.avatarImage = [UIImage imageWithData:responseObject];
       
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       
        self.avatarImage = [UIImage imageNamed:@"smile.png"];
        
        NSLog(@"Error, while loading profile image: %@", [error localizedDescription]);
       
    }];
    
    [operation start];
}

- (void)updateProfileWithParams:(NSDictionary *)params progress:(ProgressBlock)_progress success:(AuthBlockSuccess)_success failure:(AuthBlockFailure)_failure {
    NSDictionary* parameters = @{
    @"user" : params ? params : [NSNull null],
    @"token" : self.token
    };
    
    KIMutableURLRequest *request = [PutProfileBuilder buildRequestWithParameters:parameters];
    
    [Profile executeRequest:request progress:_progress success:^(id object) {
        //for(NSString * key in [params allKeys])
        //    [super setValue:params[key] forKey:[key camelize]];
        [self fillWithContents:parameters[@"user"]];
        [[HTTPClient sharedClient] setAuthorizationHeaderWithToken:object[@"token"]];
        
        if(_success) {
            
            _success();
            
        }
        
    } failure:^(id object, NSError *error) {
        
        if(_failure) {
            
            _failure(error);
            
        }
    }];

}

-(void) addDeviceToProfile:(NSString*) deviceToken success:(AuthBlockSuccess)_success failure:(AuthBlockFailure)_failure
{
    //NSLog(@"%@",self.devices);
    BOOL isAlreadyInProfile = NO;
    for(NSDictionary* device in self.devices)
    {
        if ([device[@"token"] isEqualToString:deviceToken] ) {
            isAlreadyInProfile = YES;
            self.deviceID = [NSNumber numberWithInt:[device[@"id"] longValue]];
            break;
        }
    }
    if(!isAlreadyInProfile)
    {
        NSDictionary* parameters = @{
        @"device_token" : deviceToken,
        @"device" : @"ios",
        @"token" : self.token
        };
        
        KIMutableURLRequest *request = [AddDeviceBuilder buildRequestWithParameters:parameters];
        [Profile executeRequest:request progress:nil success:^(id object) {
            [self fillWithContents:object];
            if(_success) {
                _success();
            }
            
        } failure:^(id object, NSError *error) {
            if(_failure) {
                _failure(error);
            }
        }];
    }
}

-(void) removeDeviceFromProfileWithSuccess:(AuthBlockSuccess)_success failure:(AuthBlockFailure)_failure
{
    NSDictionary* parameters = @{
    @"id" : [self.deviceID stringValue] ? [self.deviceID stringValue] : @"",
    @"token" : self.token?self.token : @""
    };
    
    KIMutableURLRequest *request = [RemoveDeviceBuilder buildRequestWithParameters:parameters];
    
    [Profile executeRequest:request progress:nil success:^(id object) {
        self.deviceID = nil;
        self.devices = nil;
        if(_success) {
            _success();
        }
        
    } failure:^(id object, NSError *error) {
        if(_failure) {
            _failure(error);
        }
    }];
    
}

-(void)restorePassword:(NSString* ) email withSuccess:(AuthBlockSuccess)_success failure:(AuthBlockFailure)_failure
{
    NSDictionary* parameters = @{
                                 @"email" : email ? email : @"",
                                 };
    
    KIMutableURLRequest *request = [RestorePasswordBuilder buildRequestWithParameters:parameters];
    
    [Profile executeRequest:request progress:nil success:^(id object) {
        self.deviceID = nil;
        self.devices = nil;
        if(_success) {
            _success();
        }
        
    } failure:^(id object, NSError *error) {
        if(_failure) {
            _failure(error);
        }
    }];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &messagesCountObservanceContext) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_UPDATE_BADGE_VALUE_FROM_PROFILE object:nil];
    } else {
        // not my observer callback
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - HANDLING ERROR
+ (void)operationError:(HTTPRequestOperation*)operation error:(NSError *)error
{
    NSLog(@"%d",operation.response.statusCode);
    switch (operation.response.statusCode) {
        case 400:
            NSLog(@"%@",operation.request.URL.path);
            if([operation.request.URL.path isEqualToString:@"/authentications"] && [[CGSocialManager sharedSocialManager] fbSessionIsActive])
            {
                NSLog(@"%@",[[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSUTF8StringEncoding]);
                [[CGSocialManager sharedSocialManager] renewSession];
                return;
            }
            break;
        case 401: {
            
            if([operation.request.URL.path isEqualToString:@"/profile/login"] && [operation.request.HTTPMethod isEqualToString:@"POST"]) {
                
                CGAlertView *alert = [[CGAlertView alloc] initWithTitle:@"Error" message:NSLocalizedString(@"Invalid email or password", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];

                return;
            }
        }
            break;
    }
    [super operationError:operation error:error];
}

#pragma mark - SOCIAL ATTACHING GETTERs 
-(BOOL)fbAttached
{
    if(authProviders)
        for(NSString* provider in authProviders)
            if([provider isEqualToString:@"fb"])
                return YES;
    return NO;
}

-(BOOL)vkAttached
{
    if(authProviders)
        for(NSString* provider in authProviders)
            if([provider isEqualToString:@"vk"])
                return YES;
    return NO;
}



+(void)getVKFriends:(NSURL* )url success:(void(^)(NSDictionary* s))_success failure:(void(^)(NSDictionary* dict,NSError* s))_failure
{
    KIMutableURLRequest* request = [[KIMutableURLRequest alloc] initWithURL:url];
    
    [self executeRequest:request progress:nil success:^(id object) {
        if(_success)
            _success(object);
        
    } failure:^(id object, NSError *error) {
        if (_failure)
            _failure(object, error);
    }];
}

-(void)checkMessagesState //метод вызывается таймером //при обновлении 
{
    if(self.token && self.token.length )
    {
        NSDictionary* parameters = @{
                                     @"token" : self.token
                                     };
        
        KIMutableURLRequest *request = [MessageStateBuilder buildRequestWithParameters:parameters];
        
        [Profile executeRequest:request progress:nil success:^(id object) {
            if([object isKindOfClass:[NSArray class]] && ([(NSArray*)object count] > 0) && [object[0] isKindOfClass:[NSDictionary class]])
            {
                if (object[0][@"count"])
                    self.messagesCount = object[0][@"count"];
                if ([object[0][@"count"] integerValue] > 0 && object[0][@"latest"])
                    [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_DIALOGS_CHECK_ACTUALLITY object:self userInfo:object[0]];
            }
        } failure:nil];
    }
    
    if(!messagesStateTimer)
    {
        messagesStateTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(checkMessagesState) userInfo:nil repeats:YES];
    }
}

-(void)checkMessagesStateAfterUpdateDialogs //вызывается из дата сорса диалогов
{
    if(messagesStateTimer)
    {
        [self checkMessagesState];
    }
}

-(void)notifierDidReceived:(NSNotification*)notification
{
    [messagesStateTimer invalidate];
    messagesStateTimer = nil;
    
    [self performSelector:@selector(checkMessagesState) withObject:nil afterDelay:300];
    
}

//проверка на то изменилась ли цена на поднятие в топ
-(void)checkPriceOfUpToTop
{
    if(![[NSUserDefaults standardUserDefaults] objectForKey:PRICE_OF_TOP_UP] && self.currentPrice)
    {
        [[NSUserDefaults standardUserDefaults] setObject:self.currentPrice forKey:PRICE_OF_TOP_UP];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    
    if(self.currentPrice && ![[[NSUserDefaults standardUserDefaults] objectForKey:PRICE_OF_TOP_UP] isEqualToNumber:self.currentPrice])
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:DONT_SHOW_ALERT_WITH_PRICE_OF_TOP];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)setName:(NSString *)name {
    
    _name = name;
    
    if(name && name.length > 0 && self.token && self.token.length > 0) {
    
        [[NSUserDefaults standardUserDefaults] setObject:name forKey:self.token];
        
    }
    
}

-(void)setDeviceToken:(NSString *)deviceToken
{
    
    
    if(self.token && self.token.length > 0 && deviceToken && deviceToken.length>0)
    {
        [[Profile sharedProfile] addDeviceToProfile:deviceToken success:^{
            
        } failure:^(NSError *error) {
            
        }];
    }
    
    _deviceToken = deviceToken;
}

- (void)networkChanged:(NSNotification *)notification {
    
    if([[notification.userInfo objectForKey:AFNetworkingReachabilityNotificationStatusItem] integerValue] == 0) {
        
        
        
    }else if([[notification.userInfo objectForKey:AFNetworkingReachabilityNotificationStatusItem] integerValue] == 1){
        
        if(self.failedSelector.allKeys.count > 0) {
                        
            NSMethodSignature * signature = [self.class instanceMethodSignatureForSelector:NSSelectorFromString([self.failedSelector objectForKey:@"sel"])];
            NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:signature];
            
            [invocation setTarget:self];
            
            [invocation setSelector:NSSelectorFromString([self.failedSelector objectForKey:@"sel"])];
            
            [self.failedSelector removeObjectForKey:@"sel"];
            
            for(int i = 0;i < self.failedSelector.allKeys.count - 1;i++) {
                
                __typeof(&*[self.failedSelector objectForKey:[NSString stringWithFormat:@"arg%i", i]])obj = [self.failedSelector objectForKey:[NSString stringWithFormat:@"arg%i", i]];
                
                [invocation setArgument:&obj atIndex:i + 2];
                
            }
            
            [invocation invoke];
                                    
        }
        
    }
    
}

@end
