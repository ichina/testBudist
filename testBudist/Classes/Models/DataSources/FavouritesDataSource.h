//
//  FavouritesDataSources.h
//  iSeller
//
//  Created by Чина on 12.01.13.
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

@interface FavouritesDataSource : NSObject <UITableViewDataSource>
{
    NSMutableArray* favourites;
}

@property(nonatomic) BOOL isFullList;

-(void)updateDataWithOption:(updateDataOption)option;

- (void)filterDataUsingOption:(FilterDataOption)option;

-(void)deleteAdAtIndex:(int)index;
-(Advertisement* )getAdAtIndex:(int)index;
@end
