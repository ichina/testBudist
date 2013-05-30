//
//  DialogsController.m
//  iSeller
//
//  Created by Чина on 16.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "DialogsController.h"
#import "DialogsDataSource.h"
#import "MessagesController.h"
#import "UIImage+scale.h"
#import "DialogMainCell.h"

@interface DialogsController ()
{
    DialogsDataSource* dialogsDataSource;
    BOOL isDataLoading;
}
@end

@implementation DialogsController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        dialogsDataSource = [DialogsDataSource new];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataSource:) name:CHINAS_NOTIFICATION_DIALOGS_DATA_SOURCE_UPDATED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveRowToTop:) name:CHINAS_NOTIFICATION_MOVE_ROW_TO_TOP object:dialogsDataSource];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:dialogsDataSource];
    
    [self.tableView setRowHeight:70];
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 60)]];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:BG_IMAGE]]];
    
    [self.tableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)]];

    refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dialogs_no_content.png"]];
    [backgroundView sizeToFit];
    [backgroundView setCenter:CGPointMake(self.tableView.center.x, self.tableView.center.y-64)];
    [backgroundView setTag:123654];
    [self.tableView addSubview:backgroundView];
}

-(void)viewWillAppear:(BOOL)animated
{
    __typeof(&*self)_self = self;
    
    self.successBlock = ^{
        
        [_self.tableView reloadData];
        
        if(!_self->isDataLoading)
            [_self needUpdateDataWithOption:updateDataWithReset];
        
    };
    
    [super viewWillAppear:animated];
    [self.tabBarController setHidden:NO animated:YES];    
}

-(void) needUpdateDataWithOption:(updateDataOption)updateDataOption
{
    isDataLoading = YES;
    [dialogsDataSource updateDataWithOption:updateDataOption];
}

-(void)reloadDataSource:(NSNotification *) notification
{
    dispatch_async( dispatch_get_main_queue(), ^{
        isDataLoading = NO;
        [self.tableView reloadData];
        [refreshControl endRefreshing];
        
        if([self.tableView numberOfRowsInSection:0] > 0) {
            
            [[self.tableView viewWithTag:123654] removeFromSuperview];
            
        }else{
            
            [[self.tableView viewWithTag:123654] removeFromSuperview];
            
            UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dialogs_no_content.png"]];
            [backgroundView sizeToFit];
            [backgroundView setCenter:CGPointMake(self.tableView.center.x, self.tableView.center.y-42)];
            [backgroundView setTag:123654];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            [label setText:NSLocalizedString(@"You have no dialogs", nil)];
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MessagesController* messController = [self.storyboard instantiateViewControllerWithIdentifier:@"MessagesController"];
    messController.dialog = [dialogsDataSource getAdAtIndex:indexPath.row];
    [self.navigationController pushViewController:messController animated:YES];
}


#pragma mark - ODRefreshViewController

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    [self needUpdateDataWithOption:updateDataWithReset];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)moveRowToTop:(NSNotification*) notification
{
    if(!notification.userInfo || [self.tableView numberOfRowsInSection:0]>1)
        return;
    NSIndexPath* indexPath = (NSIndexPath*)notification.userInfo[@"indexPath"];
    NSArray* array = [self.tableView indexPathsForVisibleRows];
    BOOL indexPathIsVisible = NO;
    for(NSIndexPath* tempIndexPath in array)
        if(indexPath.row == tempIndexPath.row)
            indexPathIsVisible = YES;
    
    if(indexPathIsVisible)
    {
        DialogMainCell* dialogCell = (DialogMainCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        dialogCell.badge.text = [NSString stringWithFormat:@"%d",dialogCell.badge.text.integerValue+1];
        if(notification.userInfo[@"message"])
            dialogCell.messageLabel.text = notification.userInfo[@"message"];
        [self.tableView moveRowAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        NSArray* indexPaths = ([self.tableView numberOfRowsInSection:0]>1)?@[[NSIndexPath indexPathForRow:0 inSection:0],[NSIndexPath indexPathForRow:1 inSection:0]]:@[[NSIndexPath indexPathForRow:0 inSection:0]];
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
