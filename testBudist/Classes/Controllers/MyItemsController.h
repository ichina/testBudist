//
//  MyItemsController.h
//  iSeller
//
//  Created by Чина on 19.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "BaseController.h"
#import "ODRefreshControl.h"
#import "LoaderView.h"

@interface MyItemsController : BaseController <UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
    ODRefreshControl *refreshControl;
    LoaderView* loaderView;
}
@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, retain) NSDictionary *justCreatedImage;
@property (nonatomic, retain) UIImage *justEditedImage;

@end
