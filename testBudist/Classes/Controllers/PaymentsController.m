//
//  PaymentHistory.m
//  iSeller
//
//  Created by Чина on 24.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "PaymentsController.h"
#import "PaymentsDataSource.h"
#import "Profile.h"
#import "PriceFormatter.h"
#import "NSString+Extensions.h"

#import "LoaderView.h"

static int profileBalanceObservanceContext;

@interface PaymentsController ()
{
    PaymentsDataSource* paymentsDataSource;
    BOOL isDataLoading;
    LoaderView* loaderView;
}
@end

@implementation PaymentsController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        paymentsDataSource = [PaymentsDataSource new];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataSource:) name:CHINAS_NOTIFICATION_PAYMENTS_DATA_SOURCE_UPDATED object:paymentsDataSource];
                
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:paymentsDataSource];
    [self.tableView setFrame:self.view.bounds];
    [self.tableView setTableHeaderView:self.headerView];
    [self.tableView setRowHeight:53];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:BG_IMAGE]]];
    //[self needUpdateDataWithOption:updateDataWithReset];
    
    NSString* coins = [NSLocalizedString(@"locale", nil) isEqualToString:@"en"]?@"coins":[[[[Profile sharedProfile] balance] stringValue] rusSklonenieCoins];
    
    self.lblBalance.text = [[[[[Profile sharedProfile] balance] stringValue] stringByAppendingString:@" "] stringByAppendingString:coins];
    
    [self.balanceImageView setImage:[[UIImage imageNamed:@"profile_alone.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)]];
        
	// Do any additional setup after loading the view.
    
    loaderView = [[LoaderView alloc] initWithMode:loaderViewModeIndeterminate];
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    [footerView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setTableFooterView:footerView];
    [loaderView setCenter:CGPointMake(footerView.center.x, footerView.center.y-footerView.frame.origin.y)];//footerView.center];
    [footerView addSubview:loaderView];
    if(isDataLoading)
        [loaderView startAnimating];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"paymentHistoryNoContent.png"]];
    [backgroundView sizeToFit];
    [backgroundView setCenter:CGPointMake(self.tableView.center.x, self.tableView.center.y)];
    [backgroundView setTag:123654];
    [self.tableView addSubview:backgroundView];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self needUpdateDataWithOption:updateDataWithReset];
}
-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToPurchase:) name:CHINAS_NOTIFICATION_GO_TO_PURCHASING object:paymentsDataSource];
    
    [[Profile sharedProfile] addObserver:self forKeyPath:@"balance" options:0 context:&profileBalanceObservanceContext];
    
    [self.tabBarController setHidden:YES animated:YES];
    [super viewWillAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHINAS_NOTIFICATION_GO_TO_PURCHASING object:paymentsDataSource];
    
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
    [[Profile sharedProfile] removeObserver:self forKeyPath:@"balance"];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void) needUpdateDataWithOption:(updateDataOption)updateDataOption
{
    if(!paymentsDataSource.isFullList)
    {
        [loaderView startAnimating];
        if(CGRectEqualToRect(self.tableView.tableFooterView.frame, CGRectZero))
        {
            UIView* view = self.tableView.tableFooterView;
            [view setFrame:CGRectMake(0, 0, 320, 60)];
            [self.tableView setTableFooterView:view];
        }
    }
    if(updateDataOption==updateDataLoadNext)
    {
        isDataLoading = YES;
    }
    [paymentsDataSource updateDataWithOption:updateDataOption];
}

-(void)reloadDataSource:(NSNotification *) notification
{
    dispatch_async( dispatch_get_main_queue(), ^{
        isDataLoading = NO;
        if(paymentsDataSource.isFullList)
        {
            [loaderView stopAnimating];
            UIView* view = self.tableView.tableFooterView;
            [view setFrame:CGRectZero];
            [self.tableView setTableFooterView:view];
        }
        [self.tableView reloadData];
        
        if([self.tableView numberOfRowsInSection:0] > 0) {
            
            [[self.tableView viewWithTag:123654] removeFromSuperview];
            
        }else{
            
            [[self.tableView viewWithTag:123654] removeFromSuperview];
            
            UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"paymentHistoryNoContent.png"]];
            [backgroundView sizeToFit];
            [backgroundView setCenter:CGPointMake(self.tableView.center.x, self.tableView.center.y+22)];
            [backgroundView setTag:123654];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            [label setText:NSLocalizedString(@"No payments", nil)];
            [label sizeToFit];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
            [label setTextColor:[UIColor colorWithRed:196.0/255.0 green:200.0/255.0 blue:207.0/255.0 alpha:1.0f]];
            [label setCenter:CGPointMake(backgroundView.frame.size.width/2+10, backgroundView.frame.size.height + label.frame.size.height/2)];
            [label setShadowColor:[UIColor blackColor]];
            [label setShadowOffset:CGSizeMake(0, 1)];
            
            [backgroundView addSubview:label];
            
            [self.tableView addSubview:backgroundView];
            
        }

    });
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(!isDataLoading && (CGRectGetMaxY(scrollView.bounds) >= CGRectGetMinY(self.tableView.tableFooterView.bounds)) && (CGRectGetMaxY(scrollView.bounds) > CGRectGetHeight(scrollView.bounds)))
       [self needUpdateDataWithOption:updateDataLoadNext];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 53;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setBalanceImageView:nil];
    [self setLblBalance:nil];
    [self setHeaderView:nil];
    [super viewDidUnload];
}

- (void)goToPurchase:(NSNotification*) notification{
    
    [self sendEventWithCategory:@"Payments" action:@"Purchase button pressed" label:@"" value:nil];
    
    [self performSegueWithIdentifier:kSegueFromPaymentHistoryToPurchase sender:nil];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if(context == &profileBalanceObservanceContext) {
        
        NSString* coins = [NSLocalizedString(@"locale", nil) isEqualToString:@"en"]?@"coins":[[[[Profile sharedProfile] balance] stringValue] rusSklonenieCoins];
        
        self.lblBalance.text = [[[[[Profile sharedProfile] balance] stringValue] stringByAppendingString:@" "] stringByAppendingString:coins];
        
    }else{
        
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];

    }
}

@end
