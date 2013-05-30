//
//  GridViewCell.h
//  iSeller
//
//  Created by Чингис on 07.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Advertisement.h"
#import "LoaderView.h"

@interface GridViewCell : UIView
{
    __block UIImageView* imageView;
}
@property (nonatomic, assign) int index;
@property(nonatomic) BOOL isLeft;
@property(nonatomic) BOOL isTop;

//@property(nonatomic,weak) IBOutlet UIView* view;
@property(nonatomic,strong) UIView* panel;

@property(nonatomic,strong) UILabel* titleOfAd;
@property(nonatomic,strong) UILabel* price;
@property(nonatomic,strong) UILabel* distance;
@property(nonatomic,strong) UIImageView* imageView;
@property(nonatomic,strong) LoaderView* loaderView;

-(void)initSubviews;
-(void)setAdvertisementInfo:(Advertisement*)ad;

@end
