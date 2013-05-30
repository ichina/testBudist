//
//  BaseController.m
//  iSeller
//
//  Created by Чина on 27.12.12.
//  Copyright (c) 2012 CloudTeam. All rights reserved.
//

#import "BaseController.h"

#import "Profile.h"

#import "ErrorHandler.h"

#import "NSDate+Extensions.h"

#import "NSString+Extensions.h"

#import "LocationManager.h"

#define kSegueToAuth @"SEGUE_TO_AUTH"

#define kAuthControllerIdentifier @"AuthController"

@interface BaseController ()

@end

@implementation BaseController

@synthesize skipAuth;

+ (void)initialize {
    
    //GAI INITIALIZATION
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        [GAI sharedInstance].trackUncaughtExceptions = YES;
        [GAI sharedInstance].dispatchInterval = 120; //seconds
        [GAI sharedInstance].debug = NO;
        id newTracker = [[GAI sharedInstance] trackerWithTrackingId:GA_ID];
        [newTracker setSampleRate:100.0f];
        
        [self sendLifetimeSession];
        
        [self archiveInstallDate];
        
    });
        
}

+ (void)archiveInstallDate {
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"GAInstallSended"]) {
        
        NSString *date = [[NSDate date] dateToUTCWithFormat:@"dd.MM.yyyy"];
        
        [[GAI sharedInstance].defaultTracker setCustom:1 dimension:date];
        
        KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"iSellerURDate" accessGroup:nil];
        [keychainItem setObject:@"iSellerURDate" forKey:(__bridge id)kSecAttrService];
        [keychainItem setObject:date forKey:(__bridge id)kSecValueData];
        
        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"GAInstallSended"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

+ (void)sendLifetimeSession {
    
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"iSellerURDate" accessGroup:nil];
    
    NSString *installDateString = [keychainItem objectForKey:(__bridge id)kSecValueData];
    
    NSDate *installDate = [installDateString dateValueWithFormat:@"dd.MM.yyyy"];
    
    NSDateComponents *components;
    
    if(installDate) {
    
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
        components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                               fromDate:installDate
                                                 toDate:[NSDate date]
                                                options:0];
        
    }
    
    [[GAI sharedInstance].defaultTracker setCustom:3 dimension:[NSString stringWithFormat:@"%i", components ? components.day : 0]];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self authorize:YES block:nil];
    
    if(self.navigationItem)
    {
        self.navigationItem.title = NSLocalizedString([NSStringFromClass([self class]) substringToIndex:NSStringFromClass([self class]).length-10], nil);//[NSStringFromClass([self class]) substringToIndex:NSStringFromClass([self class]).length-10];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needAuthorize:) name:CHINAS_NOTIFICATION_NEED_TO_PRESENT_AUTH_CONTROLLER object:[ErrorHandler sharedHandler]];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    if(self.navigationItem)
    {
        self.navigationItem.title = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHINAS_NOTIFICATION_NEED_TO_PRESENT_AUTH_CONTROLLER object:[ErrorHandler sharedHandler]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.trackedViewName = [NSStringFromClass([self class]) substringToIndex:NSStringFromClass([self class]).length-10];
    
    [self.tracker trackView:self.trackedViewName];
    
    if(self.navigationItem)
    {
        self.navigationItem.title = [NSStringFromClass([self class]) substringToIndex:NSStringFromClass([self class]).length-10];
        [self.navigationItem.backBarButtonItem setTitle:@"Back"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)needAuthorize:(NSNotification*) notification
{
    [self authorize:YES block:notification.userInfo[@"block"]];
}

- (void)authorizeWithAlert:(BOOL)needAlert animated:(BOOL)animated block:(block)_block {
    
    [LocationManager sharedManager];
    
    if(self.skipAuth) {
        
        return;
        
    }
    
    if([Profile sharedProfile].identifier) {
                
        if(_block) {
            
            _block();
            
        }else if(!_block && self.successBlock){
            
            self.successBlock();
            self.successBlock = nil;
            
        }
        
        return;
        
    }
    
    if(![[Profile sharedProfile] hasToken]) {
        
        CGAlertView *alert = [[CGAlertView alloc] initWithTitle:NSLocalizedString(@"iSeller", nil) message:NSLocalizedString(@"SignInPrompt", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:@"OK", nil];
        
        [alert setTag:animated];
        
        if(needAlert) {
        
            [alert show];
            
        }else{
            
            [self alertView:alert clickedButtonAtIndex:1];
            
        }
        
    }else{
        
        [[Profile sharedProfile] authorizeUserWithTokenSuccess:^{
            
            if(_block) {
                
                _block();
                
            }else if(!_block && self.successBlock){
                
                self.successBlock();
                self.successBlock = nil;
                
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_NEED_UPDATE_FEED_DATA_SOURCE object:self];
        } failure:^(NSError *error) {
            if(error.code != -1001 && (error.code != -1009 && ![Profile sharedProfile].hasToken)) {
                [Profile sharedProfile].token = nil;
                [self authorizeWithAlert:needAlert animated:animated block:_block];
            }
        }];
        
    }
    
}

- (void)authorize:(BOOL)animated block:(block)_block
{
    [self authorizeWithAlert:YES animated:animated block:_block];
}

- (BOOL)isAuthorized {
    
    return [[Profile sharedProfile] hasToken];
    
}

- (BOOL)shouldAutorotate {
    return NO;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}
- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;//Which is actually a default value
}

- (void)alertView:(CGAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            
            if(self.navigationController && [self.navigationController.viewControllers containsObject:self] && [[self.navigationController.viewControllers objectAtIndex:0] isEqual:self]) {
                
                if(self.skipAuth) {
                
                    [(TabBarController *)self.tabBarController returnToPreviousTab];
                    
                }else{
                    
                    [self.tabBarController tabBar:self.tabBarController.tabBar didSelectItem:[self.tabBarController.tabBar.items objectAtIndex:0]];
                    [self.tabBarController setSelectedIndex:0];
                    
                    
                }
                
            }else if(self.navigationController && [self.navigationController.viewControllers containsObject:self] && ![[self.navigationController.viewControllers objectAtIndex:0] isEqual:self]) {
                
                [self.navigationController popViewControllerAnimated:YES];
                
            }
            
            break;
        case 1:
            
            if(!alertView.tag)
                [self presentModalViewController:[self.storyboard instantiateViewControllerWithIdentifier:kAuthControllerIdentifier] animated:alertView.tag];
            else
            {
                // Avoid Unbalanced calls to begin/end appearance transitions
                
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
                
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    
                    [self presentModalViewController:[self.storyboard instantiateViewControllerWithIdentifier:kAuthControllerIdentifier] animated:alertView.tag];
                });
            }
            
            break;
            
        default:
            break;
    }
    
}

- (void)sendEventWithCategory:(NSString *)_category action:(NSString *)_action label:(NSString *)_label value:(NSNumber *)_value {
    
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:_category withAction:_action withLabel:[NSString stringWithFormat:@"(%@) %@", [[NSDate date] dateToUTCWithFormat:nil], [NSStringFromClass([self class]) substringToIndex:NSStringFromClass([self class]).length-10]] withValue:_value];
        
}


@end
