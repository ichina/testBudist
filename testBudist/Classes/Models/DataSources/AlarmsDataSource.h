//
//  AlarmsDataSource.h
//  testBudist
//
//  Created by Чингис on 02.06.13.
//  Copyright (c) 2013 Чингис. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataSource.h"
#import "Alarm.h"

@interface AlarmsDataSource : DataSource 
-(void)updateDataWithOption:(DataSourceUpdateOption)option;
-(void)getInfo:(DataSourceUpdateOption)option;
@end
