//
//  TabBarController.h
//  iSeller
//
//  Created by Чина on 28.12.12.
//  Copyright (c) 2012 CloudTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CreatingProgressView.h"

@interface TabBarController : UITabBarController

-(void)closeCreateTab;

-(void)drawCreatingProgressView:(CreatingProgressView*)creatingProgressView;

- (void)returnToPreviousTab;

@property(nonatomic) BOOL allowRotatingFullSize;

@end

@interface UITabBarController (ShowHide)

-(void)setHidden:(BOOL)hidden animated:(BOOL)animated;

-(void)animation:(BOOL)hidden;

@end