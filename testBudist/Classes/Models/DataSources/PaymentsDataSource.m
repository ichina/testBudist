//
//  PaymentsDataSource.m
//  iSeller
//
//  Created by Чина on 24.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "PaymentsDataSource.h"
#import "PaymentHistoryCell.h"
#import "Payment.h"
#import "PriceFormatter.h"
#import "Profile.h"
@implementation PaymentsDataSource

@synthesize isFullList;

-(id)init
{
    self = [super init];
    if(self)
    {
        payments = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetData:) name:CHINAS_NOTIFICATION_USER_DID_LOGOUT object:nil];
    }
    return self;
}

-(void)updateDataWithOption:(updateDataOption)option
{
    if(isFullList && option==updateDataLoadNext) //т.е. подгружать больше нечего
        return;
    
    [Payment getPaymentsWithIdentifier:(payments.count && option!=updateDataWithReset ? [[(Payment*)payments.lastObject identifier] stringValue] : @"") success:^(NSArray *_payments) {
        [self recalculateData:_payments withOption:option];
        [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_PAYMENTS_DATA_SOURCE_UPDATED object:self];
    } failure:^(NSDictionary *dict, NSError *error) {
        NSLog(@"%@, %@",dict, error);
        [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_PAYMENTS_DATA_SOURCE_UPDATED object:self];
    }];
}


-(void)recalculateData:(NSArray *)array withOption:(updateDataOption)option
{
    if(option==updateDataWithReset){
        [payments removeAllObjects];
    }
    
    isFullList = array.count < 10 ? YES : NO;
    
    [payments addObjectsFromArray:array];
}


#pragma mark - TableViewDataSource Method's

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return payments.count; 
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell;
    
    cell = (PaymentHistoryCell*)[tableView dequeueReusableCellWithIdentifier:@"PaymentCell"];
    
    [(CustomCellForSelecting*)cell setHighlightionStyle:CellHighlightionNone];
    
    [(PaymentHistoryCell*)cell setPaymentInfo:payments[indexPath.row]];
    
    [(PaymentHistoryCell*)cell setProsition:tableView withIndexPath:indexPath];

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
        [payments removeObjectAtIndex:indexPath.row];
        [tableView endUpdates];
    }
}
-(void)deleteAdAtIndex:(int)index
{
    //[Advertisement deleteFavouriteWithIdentifier:[[(Advertisement*)myItems[index] identifier] stringValue] success:nil failure:nil];
}

-(Advertisement* )getAdAtIndex:(int)index
{
    return index<payments.count ? [payments objectAtIndex:index] : nil;
}

-(void)resetData:(NSNotification*) notification
{
    [payments removeAllObjects];
    isFullList = NO;
}

-(void)goToPurchase:(id) sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_GO_TO_PURCHASING object:self];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
