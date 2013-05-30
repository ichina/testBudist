//
//  SearchController.h
//  iSeller
//
//  Created by Чина on 27.12.12.
//  Copyright (c) 2012 CloudTeam. All rights reserved.
//

#import "BaseController.h"
#import "GridView.h"
#import "AdvertisementsDataSource.h"
#import "ODRefreshControl.h"
#import "FilterView.h"
#import "LoaderView.h"

@interface SearchController : BaseController <UISearchBarDelegate, GridViewDelegate,FilterViewDelegate>
{
    GridView *gridView;
    AdvertisementsDataSource* adDataSource;
    BOOL isDataLoading;
    ODRefreshControl *refreshControl;
    LoaderView* activityIndicator;
}
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) FilterView *filterView;

-(IBAction)setFilter:(id)sender;

@end
