//
//  SearchController.m
//  iSeller
//
//  Created by Чина on 27.12.12.
//  Copyright (c) 2012 CloudTeam. All rights reserved.
//

#import "SearchController.h"

#import "Profile.h"
#import "AdvertisementController.h"
#import "NSString+Extensions.h"
#import "UIViewController+KNSemiModal.h"
#import "MapController.h"

#import "CGAlertView.h"

@interface SearchController ()

- (IBAction)mapButtonPressed:(id)sender;

@end

@implementation SearchController

@synthesize filterView = _filterView;

static int filterObservanceContext;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        // Custom initialization
        adDataSource = [AdvertisementsDataSource new];
        
        NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:@"FilterView"
                                                        owner:self options:nil];
        for (id object in bundle) {
            if ([object isKindOfClass:[FilterView class]])
                self.filterView = (FilterView *)object;
        }
        
        adDataSource.range = [NSString stringWithFormat:@"%f",[[self.filterView.currStatText substringToIndex:self.filterView.currStatText.length-3] doubleValue]*1000];
        adDataSource.priceFrom = self.filterView.priceFromText;
        adDataSource.priceTo = self.filterView.priceToText;
        
        assert(self.filterView != nil && "FilterView can't be nil");
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDataSource:) name:CHINAS_NOTIFICATION_NEED_UPDATE_FEED_DATA_SOURCE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataSource:) name:CHINAS_NOTIFICATION_SEARCH_DATA_SOURCE_UPDATED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gridViewCellTapped:) name:CHINAS_NOTIFICATION_GRIDVIEWCELL_TAPPED object:nil];
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    
    self.skipAuth = YES;
    
    [super viewDidLoad];
    
    gridView = [[GridView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44+382+( IS_IPHONE5 ? 88:0))];
    gridView.dataSource = adDataSource;
    gridView.gridDelegate = self;
    [gridView setHeaderView:self.searchBar];
    
    [self.view addSubview:gridView];
    
    for(UIView* view in self.searchBar.subviews)
    {
        if([view isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
            [(UITextField*)view setEnablesReturnKeyAutomatically:NO];
            [(UITextField*)view setClearButtonMode:UITextFieldViewModeWhileEditing];
        }
    }
    
    //self.searchBar.
    
    //[self resizeleftNavItem];
    isDataLoading = YES;
    //[self updateDataSource:nil];
    
    refreshControl = [[ODRefreshControl alloc] initInScrollView:gridView];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    
    activityIndicator = [[LoaderView alloc] initWithMode:loaderViewModeIndeterminate];
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 57)];//57
    [footerView setBackgroundColor:[UIColor clearColor]];
    [activityIndicator setCenter:CGPointMake(footerView.center.x, footerView.center.y)];//footerView.center];
    [gridView setFooterView:footerView];
    [footerView addSubview:activityIndicator];
    [activityIndicator startAnimating];
    

    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:BG_IMAGE]]];
    [gridView setBackgroundColor:[UIColor clearColor]];
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_no_content.png"]];
    [backgroundView sizeToFit];
    [backgroundView setFrame:CGRectMake(gridView.frame.size.width/2 - backgroundView.frame.size.width/2, (gridView.frame.size.height/2 - 20) - backgroundView.frame.size.height/2, backgroundView.frame.size.width, backgroundView.frame.size.height)];
    [backgroundView setTag:123654];
    
    [gridView addSubview:backgroundView];
    
    [self needUpdateDataWithOption:updateDataWithReset];   
    
    [self.filterView setDelegate:self];
    [self.filterView addObserver:self forKeyPath:@"currStatText" options:NSKeyValueObservingOptionNew context:&filterObservanceContext];
    [self.filterView addObserver:self forKeyPath:@"priceFromText" options:NSKeyValueObservingOptionNew context:&filterObservanceContext];
    [self.filterView addObserver:self forKeyPath:@"priceToText" options:NSKeyValueObservingOptionNew context:&filterObservanceContext];
}

- (void)reloadDataSource:(NSNotification* )notification
{
    dispatch_async( dispatch_get_main_queue(), ^{
        isDataLoading = NO;
        [gridView reloadData];
        [refreshControl endRefreshing];
        if(adDataSource.isFullList)
            [activityIndicator stopAnimating];
        
        if([gridView numberOfCells] > 0) {
            
            [[gridView viewWithTag:123654] removeFromSuperview];   
            
        }else{
            
            [[gridView viewWithTag:123654] removeFromSuperview];
            
            UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_no_content.png"]];
            [backgroundView sizeToFit];
            [backgroundView setFrame:CGRectMake(gridView.frame.size.width/2 - backgroundView.frame.size.width/2, (gridView.frame.size.height/2 - 20) - backgroundView.frame.size.height/2, backgroundView.frame.size.width, backgroundView.frame.size.height)];
            [backgroundView setTag:123654];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            [label setText:NSLocalizedString(@"No result", nil)];
            [label sizeToFit];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setTextColor:[UIColor colorWithRed:193.0/255.0 green:197.0/255.0 blue:204.0/255.0 alpha:0.5]];
            [label setCenter:CGPointMake(backgroundView.frame.size.width/2, backgroundView.frame.size.height + label.frame.size.height/2)];
            
            [backgroundView addSubview:label];
            
            [gridView addSubview:backgroundView];
            
        }
        
    });
}

- (void)needUpdateDataWithOption:(updateDataOption)updateDataOption
{
    if(updateDataOption==updateDataLoadNext)
        isDataLoading = YES;
    
    if(!adDataSource.isFullList)
        [activityIndicator startAnimating];
    [adDataSource updateDataWithOption:updateDataOption];
}

- (void)updateDataSource:(NSNotification* )notification
{
    [gridView setContentOffset:CGPointZero];
    [self needUpdateDataWithOption:updateDataWithReset];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController setHidden:NO animated:YES];
    
    if(adDataSource.query.length > 0) {
        
        [self.searchBar setText:adDataSource.query];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - searchBar DelegateMethod's

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [adDataSource setQuery:searchText];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar setText:@""];
    
    [adDataSource setQuery:searchBar.text];
    
    [self searchBarSearchButtonClicked:searchBar];
    
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self needUpdateDataWithOption:updateDataWithReset];
    
    for(UIView *subview in searchBar.subviews){
        if([subview isKindOfClass:UIButton.class]){
            [(UIButton*)subview setEnabled:YES];
        }
    }
}

- (void)gridViewCellTapped:(NSNotification *)notification
{
    [self performSegueWithIdentifier:kSegueFromSearchToAd sender:notification];
}

- (void)gridViewDidScrollToBottom:(GridView *)gridView
{
    if(!isDataLoading && !adDataSource.isFullList && ![adDataSource isEmpty])
        [self needUpdateDataWithOption:updateDataLoadNext];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:kSegueFromSearchToAd])
    {
        GridViewCell* cell = (GridViewCell*)[(NSNotification* )sender object];
        AdvertisementController* adController = segue.destinationViewController;
        [adController setAd:[adDataSource getAdAtIndex:cell.index]];
    }
}

- (IBAction)mapButtonPressed:(id)sender {
    
    [self sendEventWithCategory:@"Main feed" action:@"Map button pressed" label:@"" value:nil];
    
    //[self performSegueWithIdentifier:kSegueFromSearchToMap sender:self];
    MapController* mapController = [self.storyboard instantiateViewControllerWithIdentifier:@"MapController"];
    
    mapController.priceTo = adDataSource.priceTo;
    mapController.priceFrom = adDataSource.priceFrom;
    mapController.query = adDataSource.query;
    
    if(adDataSource.query.length > 0) {
        
        [mapController setIsSearching:YES];
        
    }
    
    [UIView
     transitionWithView:self.navigationController.view
     duration:0.8f
     options:UIViewAnimationOptionTransitionFlipFromLeft
     animations:^{
         [self.navigationController
          pushViewController:mapController
          animated:NO];
     }
     completion:nil];
}

#pragma mark - ODRefreshViewController

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    [self searchBarSearchButtonClicked:self.searchBar];
}

-(void)filterTouchableGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    
    CGPoint touchLocation = [gestureRecognizer locationInView:gridView];
    touchLocation.y-=gridView.contentOffset.y;
    CGSize size = self.filterView.frame.size;
    
    CGFloat limitHeight = self.filterView.initialFrame.size.height + (IS_IPHONE5 ? 220 : 100);
    
    if((gridView.frame.size.height - touchLocation.y) > 103 && (gridView.frame.size.height - touchLocation.y) < limitHeight) {
        size = CGSizeMake(self.filterView.frame.size.width, (gridView.frame.size.height - touchLocation.y) < limitHeight ? (gridView.frame.size.height - touchLocation.y) : gridView.frame.size.height);
        
        if(gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
            size = self.filterView.initialFrame.size;
        }
        
    }else if((gridView.frame.size.height - touchLocation.y) < 103) {
        
        size = CGSizeMake(self.filterView.frame.size.width, (gridView.frame.size.height - touchLocation.y) < limitHeight ? (gridView.frame.size.height - touchLocation.y) : gridView.frame.size.height);
        
        if(gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
            [self.filterView.touchable removeGestureRecognizer:gestureRecognizer];
            [self dismissSemiModalView];
            return;
        }
        
    }else{
        size = size;
        if(gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
            size = self.filterView.initialFrame.size;
        }
    }
    
    [self resizeSemiView:size withDuration:0.35];
    
}


#pragma mark - filter's meTHODS

-(IBAction)setFilter:(id)sender
{
    
    [self sendEventWithCategory:@"Main feed" action:@"Filter button pressed" label:@"" value:nil];
    
    [self.view endEditing:YES];
    UIPanGestureRecognizer *filterGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(filterTouchableGesture:)];
    [self.filterView.touchable addGestureRecognizer:filterGesture];
    
    [self.filterView setFrame:self.filterView.initialFrame];
    
    [self presentSemiView:self.filterView];
}
- (void)filterView:(FilterView *)filterView wantsToDismissWithData:(id)data {
    
    if(filterView.isKeyboardShown) {
        [self resizeSemiView:CGSizeMake(filterView.frame.size.width, filterView.frame.size.height - (IS_IPHONE5 ? 220 : 180)) withDuration:0.35];
        filterView.isKeyboardShown = NO;
    }
    
    [self dismissSemiModalView];
    
    if(data) {
        [gridView setContentOffset:CGPointMake(0, 0) animated:NO];
        [self searchBarSearchButtonClicked:self.searchBar];
    }
}

- (void)filterView:(FilterView *)filterView wantsToResizeToSize:(CGSize)size {
    
    [self resizeSemiView:size withDuration:0.35f];

}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &filterObservanceContext)
    {
        adDataSource.range = [NSString stringWithFormat:@"%f",[[self.filterView.currStatText substringToIndex:self.filterView.currStatText.length-3] doubleValue]*1000];
        adDataSource.priceFrom = self.filterView.priceFromText;
        adDataSource.priceTo = self.filterView.priceToText;
    }
    else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}
-(void)resizeleftNavItem
{
    UIButton* btn = (UIButton*)self.navigationItem.leftBarButtonItem.customView;
    [btn setBackgroundImage:[[UIImage imageNamed:@"sale_navbar_filter.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)] forState:UIControlStateNormal];
}
@end
