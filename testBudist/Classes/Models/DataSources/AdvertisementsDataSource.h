//
//  AdvertisementsDataSource.h
//  iSeller
//
//  Created by Чингис on 06.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Advertisement.h"
#import "GridView.h"
#import "GridViewCell.h"

@interface AdvertisementsDataSource : NSObject <GridViewDataSource>
{
    NSMutableArray* ads;
    NSString* excluded;
    NSString* location;
}

@property(nonatomic,strong) NSString* query;
@property(nonatomic,strong) NSString* range;
@property(nonatomic,strong) NSString* priceFrom;
@property(nonatomic,strong) NSString* priceTo;
@property(nonatomic) BOOL isFullList;
@property(nonatomic) BOOL isEmpty;

-(void)updateDataWithOption:(updateDataOption)option;
-(Advertisement*) getAdAtIndex:(int) index;

@end
