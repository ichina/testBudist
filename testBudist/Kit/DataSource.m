//
//  DataSource.m
//  PhotoMob
//
//  Created by Chingis Gomboev on 25.04.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "DataSource.h"

@implementation DataSource

@synthesize isFullList;

#pragma mark Core
#pragma mark DataSource initializing methods

- (id)init
{
    self = [super init];
    if(self) {
        
        sourceArray = [NSMutableArray array];
        
    }
    
    return self;
}

- (id)initWithModel:(id)_model {
    
    self = [self init];
    if(self) {
        
        model = _model;
        
    }
    
    return self;
    
}

#pragma mark Core
#pragma mark DataSource data methods

- (void)updateDataWithOption:(DataSourceUpdateOption)option {
    
    if(isFullList && option == DataSourceUpdateDataLoadNext) //т.е. подгружать больше нечего
        return;
        
}

- (void)recalculateData:(NSArray *)array withOption:(DataSourceUpdateOption)option {
    
    isFullList = array.count < 10 ;
    
    if(option == DataSourceUpdateDataWithReset)
    {
        [sourceArray removeAllObjects];
    }
    
    for(__typeof(&*model)item in array)
    {
        [sourceArray addObject:item];
    }
    
}

- (id)getDataAtIndex:(int)index
{
    return index < sourceArray.count ? [sourceArray objectAtIndex:index] : [[[model class] alloc] performSelector:@selector(createWithContents:) withObject:nil];
}

-(BOOL) isEmpty
{
    return sourceArray.count==0;
}

-(void)dealloc
{
    [sourceArray removeAllObjects];
    model = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)resetData:(NSNotification*) notification
{
    [sourceArray removeAllObjects];
    isFullList = NO;
    
    
    
}


@end
