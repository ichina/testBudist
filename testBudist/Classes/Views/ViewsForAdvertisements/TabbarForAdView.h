//
//  TabbarForAdView.h
//  iSeller
//
//  Created by Чина on 15.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TabbarForAdDelegate;

@interface TabbarForAdView : UIView
{
    id <TabbarForAdDelegate> delegate;
    int selectedIndex;
    BOOL isOwnAd;
    UIImageView* indicator;
}
@property (nonatomic, retain) id <TabbarForAdDelegate> delegate;

-(void) drawButtonsForMyAd:(BOOL)_isMyAd;
- (id)initWithFrame:(CGRect)frame isMyAd:(BOOL)_isMyAd;
-(void)selectTabIndex:(int)index;
-(void)deselectTabIndex:(int)index;

@end


@protocol TabbarForAdDelegate <NSObject>
@optional

-(void)tabbarForAd:(TabbarForAdView*)tabbarForAd didSelectIndex:(NSNumber*) indexNumber;
-(void)fbClicked;
-(void)twitterClicked;
-(void)emailClicked;
@end