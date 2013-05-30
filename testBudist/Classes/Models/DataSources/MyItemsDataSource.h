//
//  MyItemsDataSource.h
//  iSeller
//
//  Created by Чина on 19.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Advertisement.h"

typedef enum {
    FilterDataOptionAll = 0,
    FilterDataOptionActive,
    FilterDataOptionModeration,
    FilterDataOptionInactive,
    FilterDataOptionSold,
}
FilterDataOption;

@interface MyItemsDataSource : NSObject <UITableViewDataSource>
{
    NSMutableArray* myItems;
}

@property(nonatomic) BOOL isFullList;

@property (nonatomic, retain) UIImage *justCreatedImage;

-(void)updateDataWithOption:(updateDataOption)option;

- (void)filterDataUsingOption:(FilterDataOption)option;

-(void)deleteAdAtIndex:(int)index;
-(Advertisement* )getAdAtIndex:(int)index;
@end
