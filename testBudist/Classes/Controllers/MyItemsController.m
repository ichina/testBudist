//
//  MyItemsController.m
//  iSeller
//
//  Created by Чина on 19.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "MyItemsController.h"
#import "MyItemsDataSource.h"
#import "AdvertisementController.h"

#import "UIImage+scale.h"

@interface MyItemsController ()
{
    MyItemsDataSource* myItemsDataSource;
    BOOL isDataLoading;
}

@property (nonatomic, assign) FilterDataOption *filterOption;
@property (nonatomic, retain) UIActionSheet *actionSheet;

- (IBAction)filterButtonPressed:(id)sender;

@end

@implementation MyItemsController

@synthesize justCreatedImage, justEditedImage;

@synthesize filterOption;

@synthesize actionSheet;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        myItemsDataSource = [MyItemsDataSource new];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataSource:) name:CHINAS_NOTIFICATION_MY_ITEMS_DATA_SOURCE_UPDATED object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:myItemsDataSource];
    [self.tableView setRowHeight:70];
    //[self.tableView setBackgroundColor:[UIColor redColor]];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:BG_IMAGE]]];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"basket.png"]];
    [backgroundView sizeToFit];
    
    [backgroundView setCenter:CGPointMake(self.tableView.center.x, self.tableView.center.y-64)];
    NSLog(@"%@",NSStringFromCGPoint(backgroundView.center));
    [backgroundView setTag:123654];
    
    [self.tableView addSubview:backgroundView];
    
    refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    
    CGRect cropRect = CGRectMake([self.justCreatedImage[@"x"] floatValue], [self.justCreatedImage[@"y"] floatValue], [self.justCreatedImage[@"side"] floatValue], [self.justCreatedImage[@"side"] floatValue]);
    
    self.justEditedImage = [self.justCreatedImage[@"attachment"] imageByScalingAndCroppingForRect:cropRect];
    
    [myItemsDataSource setJustCreatedImage:self.justEditedImage];
    
    loaderView = [[LoaderView alloc] initWithMode:loaderViewModeIndeterminate];
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    [footerView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setTableFooterView:footerView];
    [loaderView setCenter:CGPointMake(footerView.center.x, 30)];
    [footerView addSubview:loaderView];
    if(isDataLoading)
        [loaderView startAnimating];
    
    [self needUpdateDataWithOption:updateDataWithReset];
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

-(void)viewWillAppear:(BOOL)animated
{
    [self.tabBarController setHidden:YES animated:YES];
    [super viewWillAppear:animated];
}

-(void) needUpdateDataWithOption:(updateDataOption)updateDataOption
{
    if(!myItemsDataSource.isFullList)
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
        isDataLoading = YES;
    [myItemsDataSource updateDataWithOption:updateDataOption];
}

-(void)reloadDataSource:(NSNotification *) notification
{
    dispatch_async( dispatch_get_main_queue(), ^{
        isDataLoading = NO;
        if(myItemsDataSource.isFullList)
        {
            [loaderView stopAnimating];
            UIView* view = self.tableView.tableFooterView;
            [view setFrame:CGRectZero];
            [self.tableView setTableFooterView:view];
        }
        [refreshControl endRefreshing];
        [self.tableView reloadData];
        
        
        if([self.tableView numberOfRowsInSection:0] > 0) {
            
            [[self.tableView viewWithTag:123654] removeFromSuperview];
            
            
        }else{
            
            [[self.tableView viewWithTag:123654] removeFromSuperview];
            
            UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"basket.png"]];
            [backgroundView sizeToFit];
            
            [backgroundView setCenter:CGPointMake(self.tableView.center.x, self.tableView.center.y-64+22)];
            NSLog(@"%@",NSStringFromCGPoint(backgroundView.center));
            
            [backgroundView setTag:123654];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            [label setText:NSLocalizedString(@"You have no items", nil)];
            [label sizeToFit];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
            [label setTextColor:[UIColor colorWithRed:196.0/255.0 green:200.0/255.0 blue:207.0/255.0 alpha:1.0f]];
            [label setShadowColor:[UIColor blackColor]];
            [label setShadowOffset:CGSizeMake(0, 1)];
            [label setCenter:CGPointMake(backgroundView.frame.size.width/2, backgroundView.frame.size.height + label.frame.size.height/2)];
            
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
    [self performSegueWithIdentifier:kSegueFromMyItemsToAd sender:indexPath];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:kSegueFromMyItemsToAd])
    {
        AdvertisementController* adController = segue.destinationViewController;
        [adController setAd:[myItemsDataSource getAdAtIndex:((NSIndexPath*)sender).row]];
    }
}

#pragma mark - ODRefreshViewController

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    [self needUpdateDataWithOption:updateDataWithReset];
}

- (IBAction)filterButtonPressed:(id)sender {
    
    [self sendEventWithCategory:@"MyItems" action:@"Filter button pressed" label:@"" value:nil];
    
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil
                                                    cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    self.actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    self.actionSheet.tag = 123321;
    
    UIToolbar *tools=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    tools.barStyle = UIBarStyleBlackOpaque;
    [self.actionSheet addSubview:tools];
    
    UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, tools.frame.size.height, 320, 400)];
    picker.showsSelectionIndicator=YES;
    picker.dataSource = self;
    picker.delegate = self;
    [self.actionSheet addSubview:picker];
    // [picker release];
    
    //picker title
    UILabel *lblPickerTitle=[[UILabel alloc]initWithFrame:CGRectMake(60, 8, 200, 25)];
    lblPickerTitle.text=NSLocalizedString(@"Filter", nil);
    lblPickerTitle.backgroundColor=[UIColor clearColor];
    lblPickerTitle.textColor=[UIColor whiteColor];
    lblPickerTitle.textAlignment=UITextAlignmentCenter;
    lblPickerTitle.font=[UIFont boldSystemFontOfSize:15];
    [tools addSubview:lblPickerTitle];
    
    UIBarButtonItem *doneButton=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(doneButtonPressed:)];
    doneButton.imageInsets=UIEdgeInsetsMake(200, 6, 50, 25);
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonPressed:)];
    
    UIBarButtonItem *flexSpace= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray *array = [[NSArray alloc] initWithObjects:cancelButton, flexSpace, flexSpace, doneButton,nil];
    
    [tools setItems:array];
    
    [self.actionSheet showFromRect:CGRectMake(0, 480, 320, 250) inView:self.view animated:YES];
    [self.actionSheet setBounds:CGRectMake(0, 0, 320, 488)];
    
    self.filterOption = 0;
    
}

- (IBAction)doneButtonPressed:(id)sender {
    
    [self sendEventWithCategory:@"MyItems:Filter" action:@"Done button pressed" label:@"" value:nil];
    
    [myItemsDataSource filterDataUsingOption:self.filterOption];
    
    [self reloadDataSource:nil];
    
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
        
}

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self sendEventWithCategory:@"MyItems:Filter" action:@"Cancel button pressed" label:@"" value:nil];
    
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
    
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return 5;
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    switch (row) {
        case FilterDataOptionActive:
            return NSLocalizedString(@"Active", nil);
            break;
        case FilterDataOptionModeration:
            return NSLocalizedString(@"Moderation", nil);
            break;
        case FilterDataOptionInactive:
            return NSLocalizedString(@"Inactive", nil);
            break;
        case FilterDataOptionSold:
            return NSLocalizedString(@"Sold", nil);
            break;
        case FilterDataOptionAll:
            return NSLocalizedString(@"All", nil);
            break;
            
        default:
            break;
    }
    
    return nil;
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    self.filterOption = row;
    
}

@end
