//
//  AuthController.m
//  iSeller
//
//  Created by Чина on 27.12.12.
//  Copyright (c) 2012 CloudTeam. All rights reserved.
//

#import "AuthController.h"
#import "Profile.h"
#import "Advertisement.h"
#import "CGSocialManager.h"
#import "SignUpController.h"
#import <MBProgressHUD.h>
#import "NSString+Extensions.h"
#import "CGSocialManager+VKcom.h"
#import "PassManageController.h"
#import "LoaderView.h"
#import "CGAlertView.h"
#import "TutorialController.h"
#import "LocationManager.h"
#import "NSDate+Extensions.h"

#define kOrTag 540
#define kLblEmailTag 541
#define kFieldEmailTag 542
#define kLblPassTag 543
#define kFieldPassTag 544
#define kFieldsTag 545
#define kFieldsDevider 546
#define kBtnSignIn 547
#define kSignUp 548
#define kForgotPassTag 549

@implementation AuthController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessTokenReceived:) name:CHINAS_NOTIFICATION_SOCIAL_ACCESS_TOKEN_RECEIVED object:[CGSocialManager sharedSocialManager]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setLabelsInBtn];
    
    [self.loginTextField setDelegate:self];
    [self.passTextField setDelegate:self];
    self.forgotPasswordButton.titleLabel.font = [UIFont fontWithName:@"Lobster 1.4" size:17];
    self.signUpButton.titleLabel.font = [UIFont fontWithName:@"Lobster 1.4" size:17];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"navbar_bg_main.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:swipeGesture];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHINAS_NOTIFICATION_SOCIAL_ACCESS_TOKEN_RECEIVED object:[CGSocialManager sharedSocialManager]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessTokenReceived:) name:CHINAS_NOTIFICATION_SOCIAL_ACCESS_TOKEN_RECEIVED object:[CGSocialManager sharedSocialManager]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vkWillShowWindow:) name:PAULS_NOTIFICATION_VK_WILL_SHOW_WINDOW object:[CGSocialManager sharedSocialManager]];
    
    /*
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"tutorialIsAlreadyShowed"])
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"tutorialIsAlreadyShowed"]||[[[NSUserDefaults standardUserDefaults] objectForKey:@"tutorialIsAlreadyShowed"] isEqualToNumber:@NO])
    {
        [self performSegueWithIdentifier:kSegueFromAuthToTutorial sender:nil];
        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"tutorialIsAlreadyShowed"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
     */
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:kSegueFromAuthToTutorial])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needAuthWithSocial:) name:CHINAS_NOTIFICATION_NEED_AUTH_WITH_SOCIAL object:segue.destinationViewController];
        [(TutorialController*)segue.destinationViewController setIsFirstPresentTutorial:YES];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHINAS_NOTIFICATION_SOCIAL_ACCESS_TOKEN_RECEIVED object:[CGSocialManager sharedSocialManager]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAULS_NOTIFICATION_VK_WILL_SHOW_WINDOW object:[CGSocialManager sharedSocialManager]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)auth:(id)sender {
        
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Authorization" withAction:@"Basic authorization button pressed" withLabel:[NSString stringWithFormat:@"(%@) %@", [[NSDate date] dateToUTCWithFormat:nil], [NSStringFromClass([self class]) substringToIndex:NSStringFromClass([self class]).length-10]] withValue:nil];
    
    [self dissmissKeyboard:nil];
    
    if(![self.loginTextField.text isValidEmail] || !self.passTextField.text.length)
    {
        [self showWarningHUD];
        return;
    }
    
    [self showHUDForWaiting];
    
    [[Profile sharedProfile] authorizeUserWithLogin:self.loginTextField.text andPassword:self.passTextField.text success:^{
        [self dismissViewControllerAnimated:YES completion:^{
            [[MBProgressHUD HUDForView:self.view] hide:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_NEED_UPDATE_FEED_DATA_SOURCE object:self];
            
        }];
    
    } failure:^(NSError *error) {
        [[MBProgressHUD HUDForView:self.view] hide:YES];

        NSLog(@"%@",error);
    }];
}

-(void)showWarningHUD
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setMode:MBProgressHUDModeCustomView];
    [hud setCustomView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]]];
    [hud setLabelText:NSLocalizedString(@"Fill in all fields...", nil)];
    [hud setAnimationType:MBProgressHUDAnimationFade];
    [hud setRemoveFromSuperViewOnHide:YES];
    [hud hide:YES afterDelay:1.0f];
    [hud setMargin:10];
}

- (void)dissmissKeyboard:(UIGestureRecognizer*)gesture
{
    [self.passTextField resignFirstResponder];
    [self.loginTextField resignFirstResponder];
    [UIView animateWithDuration:0.3f animations:^{
        [self.view setCenter:CGPointMake(self.view.center.x, 230 + (IS_IPHONE5 ? 44 : 0))];
    }];
    
        
}

- (void)swipeHandler:(UITapGestureRecognizer *)gesture {
    
    UINavigationController *_navigationController = (UINavigationController *)[(TabBarController *)self.parentViewController.presentingViewController selectedViewController];
    
    BaseController *_viewController = [[(UINavigationController *)[(TabBarController *)self.parentViewController.presentingViewController selectedViewController] viewControllers] lastObject];
        
    if(_navigationController && [_navigationController.viewControllers containsObject:_viewController] && [[_navigationController.viewControllers objectAtIndex:0] isEqual:_viewController]) {
        
        if(_viewController.skipAuth) {
        
            [(TabBarController *)self.parentViewController.presentingViewController returnToPreviousTab];
            
        }else{
            
            [(TabBarController *)self.parentViewController.presentingViewController tabBar:[(TabBarController *)self.parentViewController.presentingViewController tabBar] didSelectItem:[[(TabBarController *)self.parentViewController.presentingViewController tabBar].items objectAtIndex:0]];
            [(TabBarController *)self.parentViewController.presentingViewController setSelectedIndex:0];
            
        }
        
    }else if(_navigationController && [_navigationController.viewControllers containsObject:_viewController] && ![[_navigationController.viewControllers objectAtIndex:0] isEqual:_viewController]) {
        
        [_navigationController popViewControllerAnimated:YES];
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_NEED_UPDATE_FEED_DATA_SOURCE object:self];

    [self dismissModalViewControllerAnimated:YES];
    
}

#pragma TextFieldDelegateMethods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.passTextField)
    {
        [self auth:nil];
        [textField resignFirstResponder];
        return YES;
    
    }else{
        [self.passTextField becomeFirstResponder];
        return NO;
    
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3f animations:^{
        [self.view setCenter:CGPointMake(self.view.center.x, textField == self.loginTextField ? 100 : 60)];
    }];
}

- (IBAction)signUp:(id)sender {
    
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Authorization" withAction:@"Register button pressed" withLabel:[NSString stringWithFormat:@"(%@) %@", [[NSDate date] dateToUTCWithFormat:nil], [NSStringFromClass([self class]) substringToIndex:NSStringFromClass([self class]).length-10]] withValue:nil];
    
    [self performSegueWithIdentifier:@"kSEGUE_TO_SIGN_UP" sender:nil];
    //SignUpController* signUpController = [self.storyboard instantiateViewControllerWithIdentifier:@"SignUpController"];
    //[self.navigationController pushViewController:signUpController animated:YES];
}


-(void)setLabelsInBtn
{
    UILabel* lblSignIn = [[UILabel alloc] initWithFrame:CGRectMake(42, 16, 227, 21)];
    lblSignIn.text = NSLocalizedString(@"Sign In", nil);
    lblSignIn.textColor = [UIColor whiteColor];
    lblSignIn.shadowColor = [UIColor blackColor];
    lblSignIn.textAlignment = NSTextAlignmentCenter;
    lblSignIn.shadowOffset = CGSizeMake(0, 1);
    lblSignIn.backgroundColor = [UIColor clearColor];
    lblSignIn.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0f];
    [self.authButton addSubview:lblSignIn];
    
    UILabel* lblEmail = [[UILabel alloc] initWithFrame:CGRectMake(27, 267, 50, 21)];
    lblEmail.text = @"Email";
    lblEmail.textColor = [UIColor whiteColor];
    lblEmail.backgroundColor = [UIColor clearColor];
    lblEmail.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0f];
    [self.view addSubview:lblEmail];
    
    UILabel* lblPass = [[UILabel alloc] initWithFrame:CGRectMake(27, 307, 87, 21)];
    lblPass.text = NSLocalizedString(@"Password", nil);
    lblPass.textColor = [UIColor whiteColor];
    lblPass.backgroundColor = [UIColor clearColor];
    lblPass.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0f];
    [self.view addSubview:lblPass];
    
//    if(IS_IPHONE5)
//    {
//        [[self.view viewWithTag:101] setCenter:CGPointMake([self.view viewWithTag:101].center.x, [self.view viewWithTag:101].center.y+20.0f)];
//        for(UIView* view in self.view.subviews)
//        {
//            if(view.tag!=100 && view.tag!=101)
//                [view setCenter:CGPointMake(view.center.x, view.center.y+44.0f)];
//        }
//    }
    
    [fieldsBGView setFrame:CGRectInset(fieldsBGView.frame, -5, -5)];
    [fieldsBGView setImage:[[UIImage imageNamed:@"profile_alone.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)]];
    
    [self.authButton setBackgroundImage:[[UIImage imageNamed:@"auth_sign_in.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)] forState:UIControlStateNormal];
    [self.authButton setBackgroundImage:[[UIImage imageNamed:@"auth_sign_in_sel.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)] forState:UIControlStateHighlighted];
    
    if(IS_IPHONE5) {
        
        CGRect frame = self.forgotPasswordButton.frame;
        
        frame.origin.y = 511;
        
        [self.forgotPasswordButton setFrame:frame];
        
        frame = self.signUpButton.frame;
        
        frame.origin.y = 511;
        
        [self.signUpButton setFrame:frame];
        
    }
    
}

-(IBAction)authWithFB:(id)sender
{
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Authorization" withAction:@"Facebook authorization button pressed" withLabel:[NSString stringWithFormat:@"(%@) %@", [[NSDate date] dateToUTCWithFormat:nil], [NSStringFromClass([self class]) substringToIndex:NSStringFromClass([self class]).length-10]] withValue:nil];

    
    [self showHUDForWaiting];
    
    [[CGSocialManager sharedSocialManager] authWithFacebook];
}

- (IBAction)authWithVK:(id)sender {
    
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Authorization" withAction:@"Vkontake authorization button pressed" withLabel:[NSString stringWithFormat:@"(%@) %@", [[NSDate date] dateToUTCWithFormat:nil], [NSStringFromClass([self class]) substringToIndex:NSStringFromClass([self class]).length-10]] withValue:nil];
    
    [self showHUDForWaiting];
    
    [[CGSocialManager sharedSocialManager] authWithVKForView:self.view.window reauthorize:NO notification:nil];
}

- (IBAction)goToInfo:(id)sender {
}

- (IBAction)goToForgotPass:(id)sender {
    
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Authorization" withAction:@"Forgot password button pressed" withLabel:[NSString stringWithFormat:@"(%@) %@", [[NSDate date] dateToUTCWithFormat:nil], [NSStringFromClass([self class]) substringToIndex:NSStringFromClass([self class]).length-10]] withValue:nil];
    
    PassManageController* passController = [self.storyboard instantiateViewControllerWithIdentifier:@"PassManageController"];
    passController.isForgotPassMode = YES;
    passController.skipAuth = YES;
    [self.navigationController pushViewController:passController animated:YES];
    
}

- (IBAction)backgroundTapped:(id)sender {
    [self dissmissKeyboard:nil];
}

-(void)accessTokenReceived:(NSNotification*) notification
{
    
    if([[notification.userInfo objectForKey:@"provider"] isEqualToString:@"vk"] && ![MBProgressHUD HUDForView:self.view]) {
    
        [self showHUDForWaiting];
        
    }
    
    [[Profile sharedProfile] authorizeUserWithSocialToken:notification.userInfo[@"token"] provider:notification.userInfo[@"provider"] success:^{
        [self dismissViewControllerAnimated:YES completion:^{
            [MBProgressHUD HUDForView:self.view];
            [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_NEED_UPDATE_FEED_DATA_SOURCE object:self];
            
        }];
    } failure:^(NSError *error) {
        [MBProgressHUD HUDForView:self.view];

    }];
}

- (void)vkWillShowWindow:(NSNotification *)notification{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}

-(void)hudDidTapped:(UITapGestureRecognizer*)gesture
{
    MBProgressHUD* progressHUD = (MBProgressHUD*)gesture.view;
    [progressHUD hide:YES];
    [Profile cancelLastRequest];
}


-(void)showHUDForWaiting
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setSquare:YES];
    [hud setMinSize:CGSizeMake(126, 126)];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[LoaderView alloc] initWithMode:loaderViewModeIndeterminate];
    [(LoaderView*)hud.customView startAnimating];
    [(LoaderView*)hud.customView setProgress:0];
    hud.labelText = NSLocalizedString(@"Waiting...", nil);
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hudDidTapped:)];
    [tapGesture setNumberOfTapsRequired:2];
    [hud addGestureRecognizer:tapGesture];
}

- (void)viewDidUnload {
    fieldsBGView = nil;
    [super viewDidUnload];
}

-(void)needAuthWithSocial:(NSNotification*) notification
{
    if(notification.userInfo)
    {
        if([notification.userInfo[@"provider"] isEqualToString:@"fb"])
            [self authWithFB:nil];
        else if ([notification.userInfo[@"provider"] isEqualToString:@"vk"])
            [self authWithVK:nil];
        else if ([notification.userInfo[@"provider"] isEqualToString:@"own"])
            [self signUp:nil];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHINAS_NOTIFICATION_NEED_AUTH_WITH_SOCIAL object:notification.object];
}

- (BOOL)shouldAutorotate {
    return NO;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}
@end
