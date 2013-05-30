//
//  PaymentsDataSource.h
//  iSeller
//
//  Created by Чина on 24.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Payment.h"
@interface PaymentsDataSource : NSObject <UITableViewDataSource>
{
    NSMutableArray* payments;
}

@property(nonatomic) BOOL isFullList;

-(void)updateDataWithOption:(updateDataOption)option;

-(void)deleteAdAtIndex:(int)index;
-(Payment* )getAdAtIndex:(int)index;
@end
