//
//  GridView.m
//  iSeller
//
//  Created by Чингис on 07.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "GridView.h"
#import "GridViewCell.h"

@implementation GridView
@synthesize dataSource,gridDelegate;

#define HEADER_VIEW_TAG 70
#define FOOTER_VIEW_TAG 71

static int contentSizeObservanceContext;

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.delegate = self;
        self.backgroundColor = [UIColor blackColor];
        m_recycledCells = [NSMutableSet new];
        m_visibleCells = [NSMutableSet new];
        [self addObserver:self forKeyPath:@"contentSize" options:0 context:&contentSizeObservanceContext];
    }
    
    return self;
}


-(void) didMoveToSuperview
{
    [self reloadData];
}

#pragma mark - Displaying cells

// достает ячейку для повторного использования
// выбирает любую из тех, которые не используются в данный момент
- (GridViewCell *)dequeueRecycledCell
{
    GridViewCell *cell = [m_recycledCells anyObject];
    
    if ( cell ) {
        //[[cell retain] autorelease];
        [m_recycledCells removeObject:cell];
    }
    
    return cell;
}

// проверяет, показывается ли ячейка с индексом
- (BOOL)isDisplayingCellForIndex:(NSUInteger)index
{
    BOOL found = NO;
    for (GridViewCell *cell in m_visibleCells) {
        if (cell.index == index) {
            found = YES;
            break;
        }
    }
    return found;
}

-(void) layoutCells
{
    // определим границы номеров ячеек, которые нужны показывать
    
    CGRect bounds = self.bounds;
    
    int firstCellIndex = (floorf((CGRectGetMinY(bounds)-heightHeader) / CELL_HEIGHT)-1)*2;  // индекс первой ячейки
    int lastCellIndex  = floorf((CGRectGetMaxY(bounds)-heightHeader) / CELL_HEIGHT)*2+1;  //индекс самой последней
    firstCellIndex = MAX(firstCellIndex, 0);
    lastCellIndex  = MIN(lastCellIndex, m_numberOfCells - 1);
    
    // удалим ненужные ячейки
    
    for (GridViewCell *cell in m_visibleCells) {
        if (cell.index < firstCellIndex || cell.index > lastCellIndex) {
            [m_recycledCells addObject:cell];
            [cell removeFromSuperview];
            [cell.imageView cancelImageRequestOperation];
        }
    }
    
    [m_visibleCells minusSet:m_recycledCells];
    
    // добавим недостающие ячейки
    
    for (int index = firstCellIndex; index <= lastCellIndex; index++) {
        // если ячейки нет на экране
        if (![self isDisplayingCellForIndex:index]) {
            
            // вот тут просим у dataSource ячейку
            GridViewCell* cell = [self.dataSource tableView:self cellForRow:index];
            cell.frame = CGRectMake(index%2==0 ?  0 : self.bounds.size.width/2, heightHeader + CELL_HEIGHT*(index/2), self.bounds.size.width/2, CELL_HEIGHT);
            cell.index = index;
            
            [self addSubview:cell];
            
            // чтобы при скролле ячейка не закрывала scrollbar
            [self sendSubviewToBack:cell];
            
            [m_visibleCells addObject:cell];
        }
    }
}

#pragma mark - Public methods

// обновляет таблицу
-(void) reloadData
{
    m_numberOfCells = [self.dataSource numberOfRowsInTableView:self];
    
    CGFloat ff = (m_numberOfCells+1)/2;
    ff = heightHeader+heightFooter+CELL_HEIGHT*ff;
    ff = (ff<self.frame.size.height)?self.frame.size.height+1:ff;
        self.contentSize = CGSizeMake(self.bounds.size.width, ff);
    //}];

//БЛЯТЬ НЕЗНАЮ КАК РЕЛОАЛДИТЬ СОДЕРЖИМОЕ ДЛЯ ОТОБРАЖЕННЫХ ЯЧЕЕК, ОБНУЛЯЮ КОНТЕНТ ПРИ НУЛЕВОМ ОТСТУПЕ СКРОЛЛА!!!!(((
    //БЛЯТЬ теперь обнуляю когда отступуп с баунсом меньше высоты первых 10 ячеек
    //if(self.contentOffset.y+CGRectGetHeight(self.bounds)<CELL_HEIGHT*5)
    if(self.contentSize.height<=(heightHeader+heightFooter+CELL_HEIGHT*5))
    {
        [m_visibleCells removeAllObjects];
        for(UIView* view in self.subviews)
            if([view isKindOfClass:([GridViewCell class])])
            {
                [m_recycledCells addObject:view];
                [view removeFromSuperview];
            }
    }
    
    [self layoutCells];
}
#pragma mark - header footer views;
- (void)setFooterView:(UIView*)view
{
    if([self viewWithTag:FOOTER_VIEW_TAG])
        [[self viewWithTag:FOOTER_VIEW_TAG] removeFromSuperview];
    [view setTag:FOOTER_VIEW_TAG];
    [self addSubview:view];
    heightFooter = view.frame.size.height;
    self.contentSize = CGSizeMake(self.bounds.size.width, self.contentSize.height+view.frame.size.height);
    [view setCenter:CGPointMake(self.frame.size.width/2, self.contentSize.height-view.frame.size.height/2)];
    [self sendSubviewToBack:view];
}
- (void)setHeaderView:(UIView*)view
{
    if([self viewWithTag:HEADER_VIEW_TAG])
        [[self viewWithTag:HEADER_VIEW_TAG] removeFromSuperview];
    [view setTag:HEADER_VIEW_TAG];
    [self addSubview:view];
    heightHeader  = view.frame.size.height;
    self.contentSize = CGSizeMake(self.bounds.size.width, self.contentSize.height+view.frame.size.height);
    [view setCenter:CGPointMake(self.frame.size.width/2, self.contentSize.height-view.frame.size.height/2)];
    [self sendSubviewToBack:view];
}

#pragma mark - UIScrollView delegate

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    //NSLog(@"Is main thread: %@", [NSThread isMainThread] ? @"YES" : @"NO");
    
    [self layoutCells];
    if(self.contentSize.height <= ((CGRectGetMaxY(self.bounds)+200)))
        if(gridDelegate && [self.gridDelegate respondsToSelector:@selector(gridViewDidScrollToBottom:)])
           [gridDelegate gridViewDidScrollToBottom:self];
}

-(NSInteger) numberOfCells
{
    return m_numberOfCells;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &contentSizeObservanceContext) {
        
        if([self viewWithTag:FOOTER_VIEW_TAG])
            [[self viewWithTag:FOOTER_VIEW_TAG] setCenter:CGPointMake(self.frame.size.width/2, self.contentSize.height-[self viewWithTag:FOOTER_VIEW_TAG].frame.size.height/2)];
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
@end
