//
//  asdasd.h
//  asdf
//
//  Created by Чина on 01.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CGSwitchDelegate;

@interface CGSwitch : UIControl
{
    UIImageView* toggleView;
    UIImageView* sliderView;
    UIImageView* backgroundView;
    UIView* contentView;
    UIView* alphaView;
}
@property(nonatomic) BOOL isOn;

@property (nonatomic, retain) id <CGSwitchDelegate> delegate;

- (id)initWithToggleImage:(UIImage*) toggleImage sliderImage:(UIImage*)sliderImage;
-(void) setON:(BOOL)on duration:(float) duration;
-(void)setIsOn:(BOOL)_isOn;

@end


@protocol CGSwitchDelegate <NSObject>
@optional
-(void) CGSwitch:(CGSwitch*)cgSwitch valueChanged:(BOOL)isOn;
@end