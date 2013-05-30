//
//  AdvertisementsDataSource.m
//  iSeller
//
//  Created by Чингис on 06.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "AdvertisementsDataSource.h"
#import "LocationManager.h"

@implementation AdvertisementsDataSource
@synthesize isFullList;
-(id)init
{
    self = [super init];
    if(self)
    {
        ads = [[NSMutableArray alloc] init];
        self.query = @"";
        excluded = @"";
        self.range = @"";
        self.priceFrom = @"";
        self.priceTo = @"";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetData:) name:CHINAS_NOTIFICATION_USER_DID_LOGOUT object:nil];
    }
    return self;
}

-(void)updateDataWithOption:(updateDataOption)option
{
    if(isFullList && option==updateDataLoadNext) //т.е. подгружать больше нечего
        return;
    if(updateDataWithReset==option)
    {
        excluded = @"";
        [[LocationManager sharedManager] getLocationWithSuccess:^(CLLocation *_location) {
                        
            location = [NSString stringWithFormat:@"%f,%f",_location.coordinate.latitude,_location.coordinate.longitude,nil];
            
            [self getInfo:option];
            
        } failure:^(NSError *error) {
            
            NSLog(@"Error: %@", [error localizedDescription]);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_SEARCH_DATA_SOURCE_UPDATED object:nil];
            
        }];
    }
    else
        [self getInfo:option];
    
}

-(void)getInfo:(updateDataOption)option
{
    NSDictionary *params = @{
                             @"q" : ( self.query    ?     self.query : @"" ),
                             @"ll" : location, //( ll       ?        ll : @"" ),
                             @"range" : self.range , //( range    ?     range : @"" ),
                             @"from" : self.priceFrom,//( from     ?     from  : @"" ),
                             @"to" : self.priceTo,//( to       ?       to  : @"" ),
                             @"excluded" : ( excluded ? excluded  : @"" )
                             };
    
    [Advertisement searchWithParams:params success:^(NSArray *_ads) {
        [self recalculateData:_ads withOption:option];
        [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_SEARCH_DATA_SOURCE_UPDATED object:nil];
    } failure:^(NSDictionary *dict, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_SEARCH_DATA_SOURCE_UPDATED object:nil];
        NSLog(@"%@ \n %@",dict, error);
    }];
}

-(void)recalculateData:(NSArray *)array withOption:(updateDataOption)option
{
    isFullList = array.count < 10 ;
    
    if(option==updateDataWithReset)
    {
        [ads removeAllObjects];
        excluded = @"";
    }
    
    for(Advertisement* ad in array)
    {
        excluded =  [NSString stringWithFormat:@"%@,%@",excluded,[ad identifier],nil];
        [ads addObject:ad];
    }
    
    if(option==updateDataWithReset && excluded.length>1)
        excluded = [excluded substringFromIndex:1];
}

-(Advertisement* )getAdAtIndex:(int)index
{
    return index<ads.count ? [ads objectAtIndex:index] : [[Advertisement alloc] initWithContents:nil];
}

#pragma mark - GridViewDataSource Method's

-(int)numberOfRowsInTableView:(GridView *)tableView
{
    return ads.count;
}

-(GridViewCell *)tableView:(GridView *)tableView cellForRow:(int)row
{
    GridViewCell* cell;
    
    cell = [tableView dequeueRecycledCell];
    if ( !cell ) {
        cell = [[GridViewCell alloc] init];
    }
    if (ads.count<=row) { //типа протекшн
        return cell;
    }
    [cell setAdvertisementInfo:ads[row]];
    
    return cell;
}

-(BOOL) isEmpty
{
    return ads.count==0;
}

-(void)resetData:(NSNotification*) notification
{
    [ads removeAllObjects];
    excluded = @"";
    isFullList = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_SEARCH_DATA_SOURCE_UPDATED object:nil];
}


@end
