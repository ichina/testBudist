//
//  GridView.h
//  iSeller
//
//  Created by Чингис on 07.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#define CELL_HEIGHT 160.0

@class GridView;
@class GridViewCell;

@protocol GridViewDataSource <NSObject>
@required

-(int) numberOfRowsInTableView:(GridView *)tableView;

-(GridViewCell*) tableView:(GridView *)tableView cellForRow:(int)row;

@end

@protocol GridViewDelegate <NSObject>
@optional

-(void)gridViewDidScrollToBottom:(GridView *)gridView;

@end

@interface GridView : UIScrollView<UIScrollViewDelegate>
{
    NSMutableSet* m_recycledCells;
    NSMutableSet* m_visibleCells;
    int m_numberOfCells;
    id <GridViewDelegate> gridDelegate;
    float heightHeader;
    float heightFooter;
}

@property (nonatomic, weak) id<GridViewDataSource> dataSource;
@property (nonatomic, retain) id <GridViewDelegate> gridDelegate;

- (void) reloadData;

-(NSInteger) numberOfCells;

- (GridViewCell *)dequeueRecycledCell;
- (void)setFooterView:(UIView*)view;
- (void)setHeaderView:(UIView*)view;

@end
