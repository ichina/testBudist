//
//  DialogsController.h
//  iSeller
//
//  Created by Чина on 16.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseController.h"
#import "ODRefreshControl.h"

@interface DialogsController : BaseController < UITableViewDelegate >
{
    ODRefreshControl *refreshControl;
}
@property (nonatomic,weak) IBOutlet UITableView* tableView;

@end
