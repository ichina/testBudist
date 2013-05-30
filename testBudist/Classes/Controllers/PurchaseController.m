//
//  PurchaseController.m
//  iSeller
//
//  Created by Чина on 24.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

// testuser: test1@cloudteam.pro
// pass: Cloudteam13

#import "PurchaseController.h"
#import "InAppPurchase.h"
#import "Payment.h"
#import "LoaderView.h"
#import "Profile.h"

@interface PurchaseController ()

@end

@implementation PurchaseController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [InAppPurchase sharedInstance];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paymentSuccessCompleted:) name:@"purchaseSuccessCompleted" object:[InAppPurchase sharedInstance]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paymentFailedCompleted:) name:@"purchaseFailedCompleted" object:[InAppPurchase sharedInstance]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paymentCancelledCompleted:) name:@"purchaseCancelledCompleted" object:[InAppPurchase sharedInstance]];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.imageView setImage:[[UIImage imageNamed:@"payCoinBtnsBg.png"] stretchableImageWithLeftCapWidth:20.0f topCapHeight:20.0f]];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:BG_IMAGE]]];
	// Do any additional setup after loading the view.
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [super viewDidUnload];
}
- (IBAction)purchase:(id)sender {
        
    [self sendEventWithCategory:@"Purchase" action:[NSString stringWithFormat:@"Purchase %@ coins button pressed", ((UIButton*)sender).tag-50 == 50 ? @"10" : ((UIButton*)sender).tag-50 == 51 ? @"30" : ((UIButton*)sender).tag-50 == 52 ? @"100" : ((UIButton*)sender).tag-50 == 53 ? @"300" : @"Unknown number"] label:@"" value:nil];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setSquare:YES];
    [hud setMinSize:CGSizeMake(126, 126)];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[LoaderView alloc] initWithMode:loaderViewModeIndeterminate];
    [(LoaderView*)hud.customView startAnimating];
    [(LoaderView*)hud.customView setProgress:0];
    [hud setLabelText:NSLocalizedString(@"Loading...", nil)];
    
    [[InAppPurchase sharedInstance] purchase:((UIButton*)sender).tag-50];
}

-(void)paymentSuccessCompleted:(NSNotification*) notification
{
    if(!notification.userInfo.allKeys.count)
        return;
    [Payment postReceipt:notification.userInfo[@"receipt"] success:^(id object) {
        NSLog(@"%@",object);
        
        //[self paymentSuccessCompleted:nil];
        
        [MBProgressHUD HUDForView:self.view].customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"success.png"]];
        [MBProgressHUD HUDForView:self.view].labelText = NSLocalizedString(@"Success", nil);
        [[MBProgressHUD HUDForView:self.view] hide:YES afterDelay:2];
        
    } failure:^(id object, NSError *error) {
        
        [self paymentFailedCompleted:nil];
        
    }];
}

- (void)paymentFailedCompleted:(NSNotification *)notification
{
    [MBProgressHUD HUDForView:self.view].customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
    [MBProgressHUD HUDForView:self.view].labelText = NSLocalizedString(@"Failed", nil);
    [[MBProgressHUD HUDForView:self.view] hide:YES afterDelay:2];
}

- (void)paymentCancelledCompleted:(NSNotification *)notification
{
    [MBProgressHUD HUDForView:self.view].customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
    [MBProgressHUD HUDForView:self.view].labelText = NSLocalizedString(@"Cancel", nil);
    [[MBProgressHUD HUDForView:self.view] hide:YES afterDelay:2];
}

@end
