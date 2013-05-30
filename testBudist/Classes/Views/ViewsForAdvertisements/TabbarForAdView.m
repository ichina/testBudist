//
//  TabbarForAdView.m
//  iSeller
//
//  Created by Чина on 15.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "TabbarForAdView.h"

#import "UIImage+scale.h"

#define TWITTER_SHARE_BTN_TAG 50
#define FB_SHAREBTN_TAG 51
#define EMAIL_SHARE_BTN_TAG 52
#define VK_SHARE_BTN_TAG 53

@implementation TabbarForAdView
@synthesize delegate;
- (id)initWithFrame:(CGRect)frame isMyAd:(BOOL)_isMyAd
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, 320, TAB_BAR_HEIGHT)];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"item_tab_bg.png"]]];
        [self drawButtonsForMyAd:_isMyAd];
    }
    return self;
}

-(void) drawButtonsForMyAd:(BOOL)_isMyAd
{
    isOwnAd = _isMyAd;
    
    if(_isMyAd)
    {
        CGRect rect;
        rect.origin.y = self.frame.origin.y+TAB_BAR_HEIGHT;
        
        
        UIButton* btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [btn2 setFrame:CGRectMake(0, 0, btn2.imageView.image.size.width, btn2.imageView.image.size.height)];
        [btn2 setCenter:CGPointMake(self.center.x, 21)];
        [btn2 addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn2 setTag:TWITTER_SHARE_BTN_TAG];
        [self addSubview:btn2];
        
        
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(0, 0, btn.imageView.image.size.width, btn.imageView.image.size.height)];
        [btn setCenter:CGPointMake(self.center.x/2, 21)];
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTag:FB_SHAREBTN_TAG];
        [self addSubview:btn];
        
        
        
        UIButton* btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn3 setFrame:CGRectMake(0, 0, btn3.imageView.image.size.width, btn3.imageView.image.size.height)];
        [btn3 setCenter:CGPointMake(self.center.x*1.5, 21)];
        [btn3 addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn3 setTag:EMAIL_SHARE_BTN_TAG];
        [self addSubview:btn3];
        
        UIButton* btn4 = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn4 setFrame:CGRectMake(0, 0, btn4.imageView.image.size.width, btn4.imageView.image.size.height)];
        [btn4 setCenter:CGPointMake(self.center.x*1.5, 21)];
        [btn4 addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn4 setTag:VK_SHARE_BTN_TAG];
        [self addSubview:btn4];
        
        [self deselectTabButton:btn2];
        [self deselectTabButton:btn];
        [self deselectTabButton:btn3];
        [self deselectTabButton:btn4];
    }
    else
    {
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchDown];
        [btn setTag:TWITTER_SHARE_BTN_TAG];
        [self addSubview:btn];
        
        UIButton* btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn2 addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchDown];
        [btn2 setTag:FB_SHAREBTN_TAG];
        [self addSubview:btn2];
        
        UIButton* btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn3 addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchDown];
        [btn3 setTag:EMAIL_SHARE_BTN_TAG];
        [self addSubview:btn3];
        
        [self selectTabButton:btn];
        [self deselectTabButton:btn2];
        [self deselectTabButton:btn3];
        selectedIndex = 0;
    }
    [self layoutTabButtons];
    
    
    if (!isOwnAd) {
        indicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"item_indicator3.png"]];
        [indicator setCenter:CGPointMake(0, TAB_BAR_HEIGHT - floorf(indicator.frame.size.height/2.0f))];

        [self addSubview:indicator];
        
        [self centerIndicatorOnIndex:0];
    }
}

- (void)layoutTabButtons
{
	NSUInteger index = 0;
	NSUInteger count = isOwnAd? 4 : 3;
    
	CGRect rect = CGRectMake(0, 0, floorf(self.bounds.size.width / count), TAB_BAR_HEIGHT);
    
	//indicatorImageView.hidden = YES;
    
	NSArray *buttons = [self subviews];
	for (UIButton *button in buttons)
	{
		//if (index == count - 1)
		//	rect.size.width = self.bounds.size.width - rect.origin.x;
        
		button.frame = CGRectMake(0, 0, button.currentBackgroundImage.size.width, button.currentBackgroundImage.size.height);
        button.center = CGPointMake(CGRectGetWidth(rect)*(button.tag-50+0.5f), CGRectGetMidY(rect));
		//rect.origin.x += rect.size.width;
        [button setClipsToBounds:YES];
		++index;
	}
}

-(void)btnClicked:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    
    if(!isOwnAd && selectedIndex!=btn.tag-50)
        [self deselectTabButton:(UIButton*)[self viewWithTag:selectedIndex+50]];
    selectedIndex = btn.tag-50;
    
    
    
    if(delegate && [delegate respondsToSelector:@selector(tabbarForAd:didSelectIndex:)])
        [delegate tabbarForAd:self didSelectIndex:[NSNumber numberWithInt:selectedIndex]];
    
    [self selectTabButton:btn];
    [self centerIndicatorOnIndex:selectedIndex];
}

-(void)selectTabIndex:(int) index
{
    [self btnClicked:[self viewWithTag:index+50]];
}

- (void)selectTabButton:(UIButton *)button
{
	UIImage *image;
    
    switch (button.tag) {
        case 50:
            image = [UIImage imageNamed:(isOwnAd)?
                @"item_tab_twitter_selected.png":@"item_description_selected.png"];
            break;
        case 51:
            image = [UIImage imageNamed:(isOwnAd)?
                @"item_tab_fb_selected.png":@"item_contact_selected.png"];
            break;
        case 52:
            image = [UIImage imageNamed:(isOwnAd)?@"item_tab_email_selected.png":@"item_share_selected.png"];
            break;
        case 53:
            image = [UIImage imageNamed:@"item_tab_vk_selected.png"];
            break;
        default:
            break;
    }
    /*
	[button setBackgroundImage:isOwnAd?[image imageByScalingAndCroppingForSize:(IS_RETINA)?CGSizeMake(160, 87): CGSizeMake(80,43.5)]:image forState:UIControlStateNormal];
	[button setBackgroundImage:isOwnAd?[image imageByScalingAndCroppingForSize:(IS_RETINA)?CGSizeMake(160, 87): CGSizeMake(80,43.5)]:image forState:UIControlStateHighlighted];
     */
    [button setBackgroundImage:image forState:UIControlStateNormal];
	[button setBackgroundImage:image forState:UIControlStateHighlighted];
    [button setContentMode:(isOwnAd)?UIViewContentModeCenter:UIViewContentModeScaleAspectFit];
}

-(void)deselectTabIndex:(int)index
{
    [self deselectTabButton:(UIButton*)[self viewWithTag:index+50]];
}
- (void)deselectTabButton:(UIButton *)button
{
	[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
	UIImage *image;
    switch (button.tag) {
        case 50:
            image = [UIImage imageNamed:(isOwnAd)?@"item_tab_twitter.png":@"item_description.png"];
            break;
        case 51:
            image = [UIImage imageNamed:(isOwnAd)?@"item_tab_fb.png":@"item_contact.png"];
            break;
        case 52:
            image = [UIImage imageNamed:(isOwnAd)?@"item_tab_email.png":@"item_share.png"];
            break;
        case 53:
            image = [UIImage imageNamed:@"item_tab_vk.png"];
        default:
            break;
    }
    /*
	[button setBackgroundImage:isOwnAd?[image imageByScalingAndCroppingForSize:(IS_RETINA)?CGSizeMake(160, 87): CGSizeMake(80,43.5)]:image forState:UIControlStateNormal];
	[button setBackgroundImage:isOwnAd?[image imageByScalingAndCroppingForSize:(IS_RETINA)?CGSizeMake(160, 87): CGSizeMake(80,43.5)]:image forState:UIControlStateHighlighted];
     */
    [button setBackgroundImage:image forState:UIControlStateNormal];
	[button setBackgroundImage:image forState:UIControlStateHighlighted];
    [button setContentMode:(isOwnAd)?UIViewContentModeCenter:UIViewContentModeScaleAspectFit];
    
}

- (void)centerIndicatorOnIndex:(int)index
{
    UIButton* button = (UIButton*)[self viewWithTag:index+50];

    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [indicator setCenter:CGPointMake(button.center.x, indicator.center.y)];
    } completion:^(BOOL finished) {
        
    }];
}

@end
