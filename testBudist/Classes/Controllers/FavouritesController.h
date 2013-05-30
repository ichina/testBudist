//
//  FavouritesController.h
//  iSeller
//
//  Created by Чина on 12.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "BaseController.h"
#import "ODRefreshControl.h"
#import "LoaderView.h"

@interface FavouritesController : BaseController <UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
    BOOL isDataLoading;
    ODRefreshControl *refreshControl;
    LoaderView* loaderView;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
