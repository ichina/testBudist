//
//  TopAlarmsController.m
//  testBudist
//
//  Created by Чингис on 30.05.13.
//  Copyright (c) 2013 Чингис. All rights reserved.
//

#import "TopAlarmsController.h"

@implementation TopAlarmsController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        alarmsDataSource = [AlarmsDataSource new];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataSource:) name:CHINAS_NOTIFICATION_DATA_SOURCE_UPDATED object:alarmsDataSource];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:alarmsDataSource];
    
    [alarmsDataSource updateDataWithOption:DataSourceUpdateDataWithReset];
    
    
}

- (void)reloadDataSource:(NSNotification* )notification
{
    dispatch_async( dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 74;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:kSegueFromTableToAlarm sender:indexPath];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:kSegueFromTableToAlarm])
    {
        //[segue.destinationViewController setValue:[alarmsDataSource getDataAtIndex:(NSInteger)[sender valueForKey:@"row"]] forKey:@"alarm"];
        NSIndexPath* indexPath = (NSIndexPath*)sender;
        AlarmController* alarmController = (AlarmController*)segue.destinationViewController;
        [alarmController setAlarm:[alarmsDataSource getDataAtIndex:indexPath.row]];
        
    }
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setTableView:nil];
    [super viewDidUnload];
}
@end
