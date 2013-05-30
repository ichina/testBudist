//
//  MyItemsDataSource.m
//  iSeller
//
//  Created by Чина on 19.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "MyItemsDataSource.h"
#import "MyCell.h"
#import "Profile.h"

@interface MyItemsDataSource()

@property (nonatomic, retain) NSString *statusFilter;

@end

@implementation MyItemsDataSource

@synthesize statusFilter;

@synthesize isFullList;
-(id)init
{
    self = [super init];
    if(self)
    {
        myItems = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetData:) name:CHINAS_NOTIFICATION_USER_DID_LOGOUT object:nil];
    }
    return self;
}

-(void)updateDataWithOption:(updateDataOption)option
{
    
    if(option == -1) {
        
        option = updateDataWithReset;
        
        self.isFullList = NO;
        
    }
    
    if(isFullList && option==updateDataLoadNext) //т.е. подгружать больше нечего
        return;
    
    [Advertisement  getMyItemsWithLastIdentifier:(myItems.count && option!=updateDataWithReset ? [[(Advertisement*)myItems.lastObject identifier] stringValue] : @"") status:self.statusFilter ? self.statusFilter : @"" success:^(NSArray *ads) {
        [self recalculateData:ads withOption:option];
        [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_MY_ITEMS_DATA_SOURCE_UPDATED object:nil];
    } failure:^(NSDictionary *dict, NSError *error) {
        NSLog(@"%@, %@",dict, error);
        [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_MY_ITEMS_DATA_SOURCE_UPDATED object:nil];
    }];
}


-(void)recalculateData:(NSArray *)array withOption:(updateDataOption)option
{
    if(option==updateDataWithReset){
        [myItems removeAllObjects];
    }
    
    isFullList = array.count < 10 ? YES : NO;
    
    [myItems addObjectsFromArray:array];
}


#pragma mark - TableViewDataSource Method's

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return myItems.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyCell *cell = (MyCell*)[tableView dequeueReusableCellWithIdentifier:@"MyCell"];
    
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setProsition:tableView withIndexPath:indexPath];
        
    if(indexPath.row == 0 && ![cell.imageView.image isEqual:[UIImage imageNamed:@"placeholder.png"]] && self.justCreatedImage) {
        
        [cell setTag:102];
        [cell setJustCreatedImage:self.justCreatedImage];
        
    }
        
    [cell setAdvertisementInfo:myItems[indexPath.row]];
        
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self deleteAdAtIndex:indexPath.row];
        [myItems removeObjectAtIndex:indexPath.row];
        [tableView endUpdates];
    }
}
-(void)deleteAdAtIndex:(int)index
{
    //[Advertisement deleteFavouriteWithIdentifier:[[(Advertisement*)myItems[index] identifier] stringValue] success:nil failure:nil];
}

-(Advertisement* )getAdAtIndex:(int)index
{
    return index<myItems.count ? [myItems objectAtIndex:index] : [[Advertisement alloc] initWithContents:nil];

}

-(void)resetData:(NSNotification*) notification
{
    [myItems removeAllObjects];
    isFullList = NO;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)filterDataUsingOption:(FilterDataOption)option {
            
    switch (option) {
        case FilterDataOptionActive:
            self.statusFilter = @"active";
            break;
        case FilterDataOptionModeration:
            self.statusFilter = @"moderation";
            break;
        case FilterDataOptionInactive:
            self.statusFilter = @"inactive";
            break;
        case FilterDataOptionSold:
            self.statusFilter = @"sold";
            break;
        case FilterDataOptionAll:
            self.statusFilter = @"";
            break;
        default:
            break;
    }
    
    [self updateDataWithOption:-1];
    
}

@end
