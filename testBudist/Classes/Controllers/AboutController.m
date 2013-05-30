//
//  AboutController.m
//  iSeller
//
//  Created by Paul Semionov on 19.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "AboutController.h"

#import "CustomCellForSelecting.h"

#import <Twitter/Twitter.h>

#import <DEFacebookComposeViewController.h>

#import <MessageUI/MFMailComposeViewController.h>

#import <Appirater.h>

#include <sys/utsname.h>

#define kCellTutorial 00
#define kCellSupport 10
#define kCellReview 20
#define kCellShareTwitter 21
#define kCellShareFacebook 22

@interface AboutController() <MFMailComposeViewControllerDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end

@implementation AboutController

@synthesize tableView = _tableView;

#pragma mark --
#pragma mark UIView Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.tabBarController setHidden:YES animated:YES];
    
}

- (void)viewDidLoad {
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:BG_IMAGE]]];
    
}

#pragma mark --
#pragma mark UITableView and datasource delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return 3;
            break;
        default:
            break;
    }
    
    return nil;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomCellForSelecting *cell = (CustomCellForSelecting *)[tableView dequeueReusableCellWithIdentifier:@"AboutCell"];
    
    [cell setTag:[[NSString stringWithFormat:@"%i%i", indexPath.section, indexPath.row] integerValue]];
    
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setProsition:tableView withIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [cell setAccessoryView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dialog_accessory.png"]]];
    
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    
    [cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"aboutCell%i%i.png", indexPath.section, indexPath.row]]];
    
    switch (cell.tag) {
        case kCellTutorial:
            cell.textLabel.text = NSLocalizedString(@"How iSeller works?", nil);
            break;
        case kCellSupport:
            cell.textLabel.text = NSLocalizedString(@"iSeller Support", nil);
            break;
        case kCellReview:
            cell.textLabel.text = NSLocalizedString(@"Rate in iTunes", nil);
            break;
        case kCellShareTwitter:
            cell.textLabel.text = NSLocalizedString(@"Share us on Twitter", nil);
            break;
        case kCellShareFacebook:
            cell.textLabel.text = NSLocalizedString(@"Share on Facebook", nil);
            break;
        default:
            break;
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomCellForSelecting *cell = (CustomCellForSelecting *)[tableView cellForRowAtIndexPath:indexPath];
    
    [self setModalPresentationStyle:UIModalTransitionStyleCoverVertical];
    
    switch (cell.tag) {
        case kCellTutorial:
            
            [self sendEventWithCategory:@"About" action:@"Tutorial button pressed" label:@"" value:nil];
            
            [self performSegueWithIdentifier:kSegueFromAboutToTutorial sender:nil];
            break;
        case kCellSupport: {
            
            [self sendEventWithCategory:@"About" action:@"Email support button pressed" label:@"" value:nil];
            
            if([MFMailComposeViewController canSendMail]) {
                
                [[UINavigationBar appearanceWhenContainedIn:[UINavigationController class], nil] setBackgroundImage:[[UIImage imageNamed:@"navbar_bg_main.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forBarMetrics:UIBarMetricsDefault];
            
                MFMailComposeViewController *mailComposeController = [MFMailComposeViewController new];
                
                [mailComposeController setMailComposeDelegate:self];
                
                [mailComposeController setToRecipients:@[@"support@iseller.pro"]];
                [mailComposeController setSubject:NSLocalizedString(@"iSeller Support", nil)];
                [mailComposeController setMessageBody:[NSString stringWithFormat:@"\n\n\n%@", [self generateDeviceInfo]] isHTML:NO];
                            
                [self presentModalViewController:mailComposeController animated:YES];
            
            }
            
            break;
        }
        case kCellReview:
            
            //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=621353672&mt=8"]];
            
            [self sendEventWithCategory:@"About" action:@"iTunes review button pressed" label:@"" value:nil];
            
            [[UINavigationBar appearanceWhenContainedIn:[UINavigationController class], nil] setBarStyle:UIBarStyleBlack];
            
            [Appirater rateApp];
            
            break;
        case kCellShareTwitter: {
            
            [self sendEventWithCategory:@"About" action:@"Twitter share button pressed" label:@"" value:nil];
            
            if([SLComposeViewController class] != nil) {
                
                SLComposeViewController *tweetComposeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                
                [tweetComposeController addURL:[NSURL URLWithString:@"https://itunes.apple.com/ru/app/iseller/621353672?mt=8"]];
                [tweetComposeController setInitialText:NSLocalizedString(@"I'm using iSeller for selling great things!",nil)];
                [tweetComposeController addImage:[UIImage imageNamed:@"Icon@2x.png"]];
                
                [tweetComposeController setCompletionHandler:^(SLComposeViewControllerResult result){
                    
                    switch (result) {
                        case SLComposeViewControllerResultCancelled:
                            break;
                            
                        case SLComposeViewControllerResultDone:
                            break;
                            
                        default:
                            break;
                    }
                    
                    [self dismissModalViewControllerAnimated:YES];
                    
                }];
                
                [self presentModalViewController:tweetComposeController animated:YES];
                
            }else{
                
                if([TWTweetComposeViewController canSendTweet]) {
                    
                    TWTweetComposeViewController *tweetComposeController = [[TWTweetComposeViewController alloc] init];
                    
                    [tweetComposeController addURL:[NSURL URLWithString:@"https://itunes.apple.com/ru/app/iseller/id621353672?mt=8"]];
                    [tweetComposeController setInitialText:NSLocalizedString(@"I'm using iSeller for selling great things!",nil)];
                    [tweetComposeController addImage:[UIImage imageNamed:@"Icon@2x.png"]];
                    
                    [tweetComposeController setCompletionHandler:^(TWTweetComposeViewControllerResult result){
                        
                        switch (result) {
                            case TWTweetComposeViewControllerResultCancelled:
                                break;
                                
                            case TWTweetComposeViewControllerResultDone:
                                break;
                                
                            default:
                                break;
                        }
                        
                        [self dismissModalViewControllerAnimated:YES];
                        
                    }];
                    
                    [self presentModalViewController:tweetComposeController animated:YES];
                    
                }else{
                    
                    CGAlertView *alert = [[CGAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"No Twitter accounts found in system.", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    
                }
                                
            }
            
            break;
        }
        case kCellShareFacebook: {
            
            [self sendEventWithCategory:@"About" action:@"Facebook share button pressed" label:@"" value:nil];
            
            DEFacebookComposeViewController *facebookComposeController = [DEFacebookComposeViewController new];
            
            [facebookComposeController addURL:[NSURL URLWithString:@"https://itunes.apple.com/ru/app/iseller/id621353672?mt=8"]];
            [facebookComposeController setInitialText:NSLocalizedString(@"I'm using iSeller for selling great things!",nil)];
            [facebookComposeController addImage:[UIImage imageNamed:@"Icon@2x.png"]];
            
            [facebookComposeController setCompletionHandler:^(DEFacebookComposeViewControllerResult result) {
                
                switch (result) {
                    case DEFacebookComposeViewControllerResultCancelled:
                        break;
                        
                    case DEFacebookComposeViewControllerResultDone:
                        break;
                        
                    default:
                        break;
                }
                
                [self dismissModalViewControllerAnimated:YES];
                
            }];
            
            [self presentModalViewController:facebookComposeController animated:YES];
            
            break;
        }
        default:
            break;
    }
    
}

#pragma mark --
#pragma mark MFMailComposeViewController delegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
        
    [self dismissViewControllerAnimated:YES completion:^{
        [[UINavigationBar appearanceWhenContainedIn:[UINavigationController class], nil] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    }];
    
}

#pragma mark --
#pragma mark Other

- (NSString *)generateDeviceInfo {
    
    struct utsname u;
    uname(&u);
    char *type = u.machine;
    
    return [NSString stringWithFormat:@"Device Info\n------\nSystem Name: %@\nSystem Version: %@\nModel: %@\nApp Version: %@\nBundle Code: %@", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion], [self deviceWithIdentifier:[NSString stringWithFormat:@"%s", type]], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
}

- (NSString *)deviceWithIdentifier:(NSString *)identifier {
    
    // iPhone
    if ([identifier isEqualToString:@"iPhone1,1"])      return @"iPhone 2G";
    if ([identifier isEqualToString:@"iPhone1,2"])      return @"iPhone 3G";
    if ([identifier hasPrefix:@"iPhone2"])              return @"iPhone 3Gs";
    if ([identifier hasPrefix:@"iPhone3,1"])            return @"iPhone 4 GSM";
    if ([identifier hasPrefix:@"iPhone3,2"])            return @"iPhone 4 CDMA";
    if ([identifier hasPrefix:@"iPhone4"])              return @"iPhone 4S";
    if ([identifier hasPrefix:@"iPhone5"])              return @"iPhone 5";
    
    // iPod
    if ([identifier hasPrefix:@"iPod1"])                return @"iPod Touch 1G";
    if ([identifier hasPrefix:@"iPod2"])                return @"iPod Touch 2G";
    if ([identifier hasPrefix:@"iPod3"])                return @"iPod Touch 3G";
    if ([identifier hasPrefix:@"iPod4"])                return @"iPod Touch 4";
    
    // iPad
    if ([identifier hasPrefix:@"iPad1"])                return @"iPad";
    if ([identifier hasPrefix:@"iPad2"])                return @"iPad 2";
    if ([identifier hasPrefix:@"iPad3"])                return @"iPad 3";
    if ([identifier hasPrefix:@"iPad4"])                return @"iPad 4";
    
    // Apple TV
    if ([identifier hasPrefix:@"AppleTV2"])             return @"Apple TV 2";
    if ([identifier hasPrefix:@"AppleTV3"])             return @"Apple TV 3";
    
    if ([identifier hasPrefix:@"iPhone"])               return @"Unknown iPhone";
    if ([identifier hasPrefix:@"iPod"])                 return @"Unknown iPod";
    if ([identifier hasPrefix:@"iPad"])                 return @"Unknown iPad";
    if ([identifier hasPrefix:@"AppleTV"])              return @"Unknown Apple TV";
    
    return nil;
    
}

@end
