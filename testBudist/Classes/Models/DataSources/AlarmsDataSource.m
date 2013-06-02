//
//  AlarmsDataSource.m
//  testBudist
//
//  Created by Чингис on 02.06.13.
//  Copyright (c) 2013 Чингис. All rights reserved.
//

#import "AlarmsDataSource.h"
#import "AlarmsCell.h"

@implementation AlarmsDataSource
@synthesize isFullList;

-(void)updateDataWithOption:(DataSourceUpdateOption)option
{
    if(isFullList && option==DataSourceUpdateDataLoadNext) //т.е. подгружать больше нечего
        return;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self getInfo:option];
    });
    
}


-(void)getInfo:(DataSourceUpdateOption)option
{
    [Alarm getAlarmsWithSuccess:^(NSArray *alarms) {
        
        [self recalculateData:alarms withOption:option];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_DATA_SOURCE_UPDATED object:self];
        
    } failure:^(NSDictionary *dict, NSError *error) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_DATA_SOURCE_UPDATED object:self];
        NSLog(@"%@ \n %@",dict, error);
        
    }];
}

-(void)recalculateData:(NSArray *)array withOption:(DataSourceUpdateOption)option
{
    isFullList = array.count < 10 ;
    
    if(option==DataSourceUpdateDataWithReset)
    {
        [sourceArray removeAllObjects];
    }
    
    for(Alarm* alarm in array)
    {
        [sourceArray addObject:alarm];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return sourceArray.count;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AlarmsCell *cell = (AlarmsCell *)[tableView dequeueReusableCellWithIdentifier:@"AlarmCell"];
    
    if(sourceArray.count<=indexPath.row)
        return cell;
    
    Alarm* tempAlarm = [sourceArray objectAtIndex:indexPath.row];
    
    [cell setInfoWithAlarm:tempAlarm];
    
    return cell;
}

@end
