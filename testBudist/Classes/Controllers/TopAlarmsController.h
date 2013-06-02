//
//  TopAlarmsController.h
//  testBudist
//
//  Created by Чингис on 30.05.13.
//  Copyright (c) 2013 Чингис. All rights reserved.
//

#import "BaseController.h"
#import "AlarmsDataSource.h"
#import "AlarmController.h"
@interface TopAlarmsController : BaseController <UITableViewDelegate>
{
    AlarmsDataSource* alarmsDataSource;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
