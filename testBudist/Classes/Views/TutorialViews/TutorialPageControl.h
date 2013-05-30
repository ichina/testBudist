//
//  TutorialPageControl.h
//  iSeller
//
//  Created by Чингис on 28.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialPageControl : UIView
{
    UIImageView *currentPageView;
}
@property(nonatomic) int numberOfPages;
@property(nonatomic) int currentPage;

@end
