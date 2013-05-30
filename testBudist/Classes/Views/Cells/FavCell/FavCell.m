//
//  FavCell.m
//  seller
//
//  Created by Чина on 19.09.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FavCell.h"
#import "UIImageView+AFNetworking.h"
#import "PriceFormatter.h"
typedef enum {
    StatusModeration = 0,
    StatusActive,
    StatusInactive,
    StatusSold
} Status;

@implementation FavCell

@synthesize badgeView;

@synthesize state = _state;

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if(self) {
        
        badgeView = [[PSBadgeStatusView alloc] initWithTitle:NSLocalizedString(@"inactive", nil) textColor:[UIColor whiteColor] andFontSize:14.0];
        [self addSubview:badgeView];
    }
    
    return self;
}


-(void)setAdvertisementInfo:(Advertisement *)ad {
    self.titleOfAd.text = [ad title];
    self.price.text = [[PriceFormatter sharedFormatter] formatPrice:[[ad price] floatValue]];
    [self setState:[ad status]];
    
    [self.smallImageView setImageWithURL:[NSURL URLWithString:[ad getSmallImage]] placeholderfileName:@"placeholder.png"];
}

- (void)setState:(NSString *)state {
    
    static NSArray* statusArray = nil;
    if(!statusArray)
        statusArray = [NSArray arrayWithObjects:@"moderation", @"active", @"inactive", @"sold", nil];
    
    badgeView.title.text = NSLocalizedString(state, nil);
    
    [badgeView refreshInterface];
    
    switch ([statusArray indexOfObject:state]) {
        case StatusModeration:
            [badgeView setColor:[UIColor colorWithRed:230.0/255 green:165.0/255 blue:9.0/255 alpha:1.0]];
            break;
        case StatusActive:
            [badgeView setColor:[UIColor colorWithRed:196.0/255 green:55.0/255 blue:64.0/255 alpha:1.0]];
            break;
        case StatusInactive:
            [badgeView setColor:[UIColor colorWithRed:163.0/255 green:167.0/255 blue:175.0/255 alpha:1.0]];
            break;
        case StatusSold:
            [badgeView setColor:[UIColor colorWithRed:69.0/255 green:87.0/255 blue:102.0/255 alpha:1.0]];
            break;
            
        default:
            break;
    }
    
    [badgeView setNeedsDisplay];
    
    //y был 43
    [badgeView setFrame:CGRectMake(self.price.frame.origin.x, CGRectGetMaxY(self.iconImageView.frame)-badgeView.frame.size.height-1, badgeView.frame.size.width, badgeView.frame.size.height)];
}


@end
