//
//  AppDelegate.m
//  iSeller
//
//  Created by  on 26.12.12.
//  Copyright (c) 2012 CloudTeam. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK.h>
#import "CGStatusBar.h"
#import "NSString+Extensions.h"
#import "Profile.h"
#import "TabBarController.h"
#import <AudioToolbox/AudioToolbox.h>

#import <Appirater.h>

@implementation AppDelegate

@synthesize isBackGroundState;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Appirater setAppId:@"621353672"];
    [Appirater setDaysUntilPrompt:3];
    [Appirater setUsesUntilPrompt:10];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:3];
    //[Appirater setDebug:YES];
    
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound |UIRemoteNotificationTypeAlert)];
    
//    NSMutableDictionary *lo = [NSMutableDictionary dictionary];
//    
//    [lo setObject:[NSURL URLWithString:@"iseller://?ad=2"] forKey:UIApplicationLaunchOptionsURLKey];
    
    if(launchOptions)
        [self settingLaunchOption:[launchOptions mutableCopy]];
    
    [Appirater appLaunched:YES];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
        
    NSString *URLString = [url absoluteString];
    
    NSRange range = NSMakeRange(0, 11);
    
    NSString *argString = [URLString substringWithRange:range];
    
    NSArray *arguments = [argString componentsSeparatedByString:@";"];
    
    NSString *adId = @"";
    
    for(NSString *argument in arguments) {
        
        if([argument hasPrefix:@"ad"]) {
            
            adId = [[argument componentsSeparatedByString:@"="] lastObject];
            
        }
        
    }
    
    if(adId.length > 0) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EnteredFromSite" object:adId];
        
        [[[UIAlertView alloc] initWithTitle:@"asd" message:@"asdasda" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        
    }
    
    return YES;
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    isBackGroundState = YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [Appirater appEnteredForeground:YES];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ApplicationDidBecomeActive" object:nil];
    
    // We need to properly handle activation of the application with regards to SSO
    // (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    [FBSession.activeSession handleDidBecomeActive];
    
    isBackGroundState = NO;
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [FBSession.activeSession close];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBSession.activeSession handleOpenURL:url];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    /*
    NSString *tokenString = [NSMutableString stringWithString:
                             [[deviceToken description] uppercaseString]];
    
    tokenString = [[tokenString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"DID_REGISTER DEVICE_TOKEN: %@", tokenString);
    */
    const char *data = [deviceToken bytes];
    NSMutableString* token = [NSMutableString string];
    for (int i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    
    if (token) {
        [[Profile sharedProfile] setDeviceToken:token];
    }
    
    [CGStatusBar sharedStatusBar];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    if([userInfo objectForKey:@"badge"])
        [UIApplication sharedApplication].applicationIconBadgeNumber = [[userInfo objectForKey:@"badge"] integerValue];
    
    // Постим уведомление о пуше.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveMessage" object:self userInfo:userInfo];
    
}

-(void)settingLaunchOption:(NSMutableDictionary*) launchOptions
{
    if(!launchOptions[@"UIApplicationLaunchOptionsRemoteNotificationKey"] && !launchOptions[UIApplicationLaunchOptionsURLKey]) {
        return;
    }else if(launchOptions[UIApplicationLaunchOptionsURLKey]){
        
        NSString *URLString = [launchOptions[UIApplicationLaunchOptionsURLKey] absoluteString];
        
        NSRange range = NSMakeRange([URLString rangeOfString:@"?"].location + 1, URLString.length - [URLString rangeOfString:@"?"].location - 1);
                
        NSString *argString = [URLString substringWithRange:range];
        
        NSArray *arguments = [argString componentsSeparatedByString:@";"];
        
        NSString *adId = @"";
        
        for(NSString *argument in arguments) {
            
            if([argument hasPrefix:@"ad"]) {
                
                adId = [[argument componentsSeparatedByString:@"="] lastObject];
                
            }
            
        }
            
        if(adId.length > 0) {
                        
            [[NSNotificationCenter defaultCenter] postNotificationName:@"EnteredFromSite" object:self userInfo:@{@"object": adId}];
            
        }
        
        return;
        
    }
    
    if(launchOptions[@"UIApplicationLaunchOptionsRemoteNotificationKey"][@"badge"])
        [UIApplication sharedApplication].applicationIconBadgeNumber = [launchOptions[@"UIApplicationLaunchOptionsRemoteNotificationKey"][@"badge"] integerValue];
        
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0f * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:launchOptions[@"UIApplicationLaunchOptionsRemoteNotificationKey"]];
        [userInfo setObject:@"1" forKey:@"isBackgroundState"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveMessage" object:self userInfo:userInfo];
    });
}
/*
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    NSLog(@"supportedInterfaceOrientationsForWindow");
    return  UIInterfaceOrientationMaskAllButUpsideDown;
}
*/

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window  // iOS 6
{
    return UIInterfaceOrientationMaskAll;
}

@end
