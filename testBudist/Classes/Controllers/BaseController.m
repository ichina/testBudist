//
//  BaseController.m
//  iSeller
//
//  Created by Чина on 27.12.12.
//  Copyright (c) 2012 CloudTeam. All rights reserved.
//

#import "BaseController.h"

#import "ErrorHandler.h"

#import "NSString+Extensions.h"

#import "LocationManager.h"

#define kSegueToAuth @"SEGUE_TO_AUTH"

#define kAuthControllerIdentifier @"AuthController"

@interface BaseController ()

@end

@implementation BaseController

@synthesize skipAuth;

- (void)viewDidLoad
{
    [super viewDidLoad];
}


-(void)needAuthorize:(NSNotification*) notification
{
    [self authorize:YES];
}

- (void)authorize:(BOOL) animated
{
    if(!animated)
    {
        [self presentModalViewController:[self.storyboard instantiateViewControllerWithIdentifier:kAuthControllerIdentifier] animated:animated];   
    }
    else
    {
        // Avoid Unbalanced calls to begin/end appearance transitions
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
        
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [self presentModalViewController:[self.storyboard instantiateViewControllerWithIdentifier:kAuthControllerIdentifier] animated:animated];
        });
    }
    
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


@end
