//
//  DataSource.h
//  PhotoMob
//
//  Created by Chingis Gomboev on 25.04.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    
    DataSourceUpdateDataWithReset = 0,
    DataSourceUpdateDataLoadNext,
    DataSourceUpdateDataLoadAfter
    
} DataSourceUpdateOption;

@interface DataSource : NSObject <UITableViewDataSource> {
    
    NSMutableArray *sourceArray;
    
    id model;
    
}

@property (nonatomic, assign) BOOL isFullList;

- (id)initWithModel:(id)_model;

- (void)updateDataWithOption:(DataSourceUpdateOption)option;
- (void)recalculateData:(NSArray *)array withOption:(DataSourceUpdateOption)option;
- (id)getDataAtIndex:(int)index;
- (BOOL) isEmpty;

@end
