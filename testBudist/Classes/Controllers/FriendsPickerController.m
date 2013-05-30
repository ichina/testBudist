//
//  FriendsPickerController.m
//  iSeller
//
//  Created by Чингис on 29.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "FriendsPickerController.h"
#import "LoaderView.h"
#import "UISegmentedControl+Extensions.h"
#import <QuartzCore/QuartzCore.h>
#import "CGSocialManager.h"

@interface FriendsPickerController ()

@end

@implementation FriendsPickerController
@synthesize dataSource = _dataSource;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.dataSource = [[FriendsPickerDataSource alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataSource:) name:CHINAS_NOTIFICATION_FRIENDSPICK_DATA_SOURCE_UPDATED object:self.dataSource];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inviteVKFriend:) name:@"GET_INDEX_VK_FRIEND_CELL" object:self.dataSource];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"FriendsPicker", nil);
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self.dataSource];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
        
    self.segmentedControl = [[BinarySegmentControl alloc] initWithFrame:CGRectMake(0, 0, 310, 36)];
    [self.segmentedControl setSelectedSegmentIndex:0];
    [self.segmentedControl setDelegate:self];
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [view addSubview:self.segmentedControl];
    [self.segmentedControl setCenter:CGPointMake(view.center.x, view.center.y)];
    //[view setCenter:CGPointMake(160, 66)];
    [self.view addSubview:view];
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 5)]];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:BG_IMAGE]]];
    [self.dataSource updateDataWithOption:updateDataWithReset];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    //[self.searchBar setDelegate:self];

    [self.tableView setClipsToBounds:YES];
    
    /*
    self.searchBar.layer.shadowColor = [UIColor blackColor].CGColor;
    self.searchBar.layer.shadowOpacity = 0.4f;
    self.searchBar.layer.shadowOffset = CGSizeMake(0,6);
    CGRect shadowPath = CGRectMake(self.searchBar.layer.bounds.origin.x - 10, self.searchBar.layer.bounds.size.height - 10, self.searchBar.layer.bounds.size.width + 20, 10);
    self.searchBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowPath].CGPath;
    */
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tabBarController setHidden:YES animated:YES];
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socialCanceled:) name:CHINAS_NOTIFICATION_VK_AUTH_CANCELED object:[CGSocialManager sharedSocialManager]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socialCanceled:) name:CHINAS_NOTIFICATION_FB_AUTH_CANCELED object:[CGSocialManager sharedSocialManager]];
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


-(void) needUpdateDataWithOption:(updateDataOption)updateDataOption
{
    if(self.segmentedControl.selectedSegmentIndex==0)
        fbIsDataLoading = YES;
    else
        vkIsDataLoading = YES;
    
    [self.dataSource updateDataWithOption:updateDataOption];
}

-(void)reloadDataSource:(NSNotification *) notification
{
    dispatch_async( dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        
        if(notification.userInfo && notification.userInfo[@"option"] && [notification.userInfo[@"option"] isEqualToString:@"just_update"])
            return;
        
        if(self.segmentedControl.selectedSegmentIndex == 1) {
            vkIsDataLoading = NO;
        }else{
            fbIsDataLoading = NO;
        }
        
        if(self.segmentedControl.selectedSegmentIndex>=0)
            [[self.tableView viewWithTag:301] removeFromSuperview];
        
        LoaderView* loader = (LoaderView*)[self.tableView viewWithTag:300];
        if(!loader)
        {
            loader = [[LoaderView alloc] initWithMode:loaderViewModeIndeterminate];
            [loader setCenter:CGPointMake(self.tableView.center.x, self.tableView.center.y-150)];
            [self.tableView addSubview:loader];
            [loader setTag:300];
        }
        if([self.tableView numberOfRowsInSection:0]==0 && self.segmentedControl.selectedSegmentIndex>=0)
            [loader startAnimating];
        else
            [loader stopAnimating];
    });
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FBFriend* friend = (FBFriend*)[self.dataSource getAdAtIndex:indexPath.row];
    
    if(friend.installed)
        friend.needInvite = YES;
    else
        friend.needInvite = !friend.needInvite;
    
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell.accessoryView setHidden:!friend.needInvite];
}


/*
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentedControl.selectedSegmentIndex==1) {
        [self.dataSource inviteVKFriend:indexPath.row];
    }
}
*/
/*
#pragma mark - UISearchBar Delegate method's for FB

- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
    [searchBar resignFirstResponder];
    self.searchText = searchBar.text;
    [self.dataSource filter];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.searchText = searchBar.text;
    self.dataSource.searchText = searchBar.text;
    [self.dataSource filter];
    //[self.friendPickerController updateView];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    self.searchText = nil;
    self.dataSource.searchText = @"";
    [self.dataSource filter];
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}
-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    return YES;
}
*/

- (void)viewDidUnload {
    [self setSearchBar:nil];
    [self setTableView:nil];
    [self setSegmentedControl:nil];
    [super viewDidUnload];
}
- (IBAction)inviteFriends:(id)sender {
    [self.dataSource inviteFriends];
}

- (void)binarySegmentChangeValue:(BinarySegmentControl*)segmentControl {
    self.dataSource.selectedSegmentIndex = self.segmentedControl.selectedSegmentIndex;
    [self.dataSource updateDataWithOption:updateDataWithReset];
}

-(void) socialCanceled:(NSNotification*) notification
{
    [self.segmentedControl setSelectedSegmentIndex:-1];
    LoaderView* loader = (LoaderView*)[self.tableView viewWithTag:300];
    if(loader)
    {
        [loader stopAnimating];
        if ([notification.name isEqualToString:CHINAS_NOTIFICATION_FB_AUTH_CANCELED]) {
            self.dataSource.isRequestFBSended = NO;
        }
        else
            self.dataSource.isRequestVKSended = NO;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        [label setText:NSLocalizedString(@"Select any social", nil)];
        [label sizeToFit];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
        [label setTextColor:[UIColor colorWithRed:196.0/255.0 green:200.0/255.0 blue:207.0/255.0 alpha:1.0f]];
        [label sizeToFit];
        [label setCenter:CGPointMake(self.tableView.frame.size.width/2, self.tableView.frame.size.height/2 -30)];
        [label setShadowColor:[UIColor blackColor]];
        [label setShadowOffset:CGSizeMake(0, 1)];
        label.tag = 301;
        [self.tableView addSubview:label];
    }
}

#pragma mark - scrollview delegate method's


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(self.segmentedControl.selectedSegmentIndex==0)
    {
        if(!fbIsDataLoading && (CGRectGetMaxY(scrollView.bounds) >= CGRectGetMinY(self.tableView.tableFooterView.bounds)) && (CGRectGetMaxY(scrollView.bounds) > CGRectGetHeight(scrollView.bounds)))
            [self needUpdateDataWithOption:updateDataLoadNext];
    }else
    {
        if(!vkIsDataLoading && (CGRectGetMaxY(scrollView.bounds) >= CGRectGetMinY(self.tableView.tableFooterView.frame)) && (CGRectGetMaxY(scrollView.bounds) > CGRectGetHeight(scrollView.bounds)))
        {
            [self needUpdateDataWithOption:updateDataLoadNext];
        }
    }
        
}


@end

