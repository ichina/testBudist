//
//  TutorialPageControl.m
//  iSeller
//
//  Created by Чингис on 28.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "TutorialPageControl.h"
@implementation TutorialPageControl
@synthesize numberOfPages = _numberOfPages;
@synthesize currentPage = _currentPage;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.backgroundColor = [UIColor clearColor];
        currentPageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial_page_control_on.png"]];
        
        [self addSubview:currentPageView];
    }
    return self;
}

-(void)setNumberOfPages:(int)numberOfPages
{
    _numberOfPages = numberOfPages;
    
    for(UIView *view in self.subviews)
        [view removeFromSuperview];
    
    for (int i = 0; i < numberOfPages; i++)
    {
        UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"tutorial_page_control_off.png"]];
        
        [imageView setCenter:CGPointMake(20*(i+1) , 10)];
        
        if(i==self.currentPage)
        {
            [currentPageView setCenter:imageView.center];
            [self addSubview:currentPageView];
        }
        [self addSubview:imageView];
    }
    [self setFrame:CGRectMake(0, 0, 20*(numberOfPages+2), 20)];
}

-(void)setCurrentPage:(int)currentPage
{
    if(currentPage<self.numberOfPages && currentPage>=0)
    {
        _currentPage = currentPage;
        [currentPageView setCenter:CGPointMake(20*(currentPage+1), 10)];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
