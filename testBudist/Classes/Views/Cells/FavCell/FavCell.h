//
//  FavCell.h
//  seller
//
//  Created by Чина on 19.09.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCellForSelecting.h"
#import "PSBadgeStatusView.h"
#import "Advertisement.h"

@interface FavCell : CustomCellForSelecting

@property(nonatomic,weak) IBOutlet UILabel* titleOfAd;
@property(nonatomic,weak) IBOutlet UILabel* price;
@property(nonatomic,weak) IBOutlet UIImageView* smallImageView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@property (nonatomic, retain) PSBadgeStatusView *badgeView;

@property (nonatomic, retain) NSString *state;

-(void)setAdvertisementInfo:(Advertisement*)ad;

@end
