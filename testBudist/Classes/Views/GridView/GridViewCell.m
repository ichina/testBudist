//
//  GridViewCell.m
//  iSeller
//
//  Created by Чингис on 07.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "GridViewCell.h"
#import "AFNetworking.h"
#import "LocationManager.h"
#import "PriceFormatter.h"

@implementation GridViewCell
@synthesize index;
@synthesize panel,price,titleOfAd,isLeft,isTop,imageView,distance;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        [self initSubviews];
        [self setContentMode:UIViewContentModeScaleToFill];
    }
    return self;
}

-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

-(void)initSubviews
{
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 159.5f, 160)];
    imageView.userInteractionEnabled = NO;
    [imageView setContentMode:UIViewContentModeScaleToFill];
    [self addSubview:imageView];
    
    panel = [[UIView alloc] initWithFrame:CGRectMake(0, 126, 160, 34)];
    [panel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"buy_good_bg.png"]]];
    [self addSubview:panel];
    [panel setUserInteractionEnabled:NO];
    
    titleOfAd = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, 152, 18)];
    titleOfAd.textColor = [UIColor whiteColor];
    titleOfAd.shadowColor = [UIColor blackColor];
    titleOfAd.shadowOffset = CGSizeMake(0, -1);
    titleOfAd.backgroundColor = [UIColor clearColor];
    titleOfAd.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
    [panel addSubview:titleOfAd];
    
    price = [[UILabel alloc] initWithFrame:CGRectMake(8, 12, 101, 21)];
    price.textColor = [UIColor whiteColor];
    price.shadowColor = [UIColor blackColor];
    price.shadowOffset = CGSizeMake(0, -1);
    price.backgroundColor = [UIColor clearColor];
    price.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0f];
    [panel addSubview:price];
    
    distance = [[UILabel alloc] initWithFrame:CGRectMake(104, 12, 49, 21)];
    distance.textColor = [UIColor whiteColor];
    distance.shadowColor = [UIColor blackColor];
    distance.textAlignment = NSTextAlignmentRight;
    distance.shadowOffset = CGSizeMake(0, -1);
    distance.backgroundColor = [UIColor clearColor];
    distance.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
    [panel addSubview:distance];
    
    
    self.loaderView = [[LoaderView alloc] initWithMode:loaderViewModeIndeterminate];
    [self.loaderView setCenter:CGPointMake(80, 80)];
    [self addSubview:self.loaderView];
    
    [self setExclusiveTouch:YES];
}

-(void)setAdvertisementInfo:(Advertisement*)ad
{
    titleOfAd.text = [ad title];
    price.text = [[PriceFormatter sharedFormatter] formatPrice:[[ad price] floatValue]];
    distance.text = [[LocationManager sharedManager] calculateDistanceWithLocation:ad.location];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:ad.image]];
    [request setHTTPShouldHandleCookies:NO];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"placeholder.png"]]];    
    
    [imageView setAlpha:0.0f];
    
    __weak GridViewCell *weakSelf = self;
    
    [self.loaderView startAnimating];

    [imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [weakSelf.imageView setImage:image];
        if(!request && !response)
            [weakSelf.imageView setAlpha:1.0f];
        else
            [UIView animateWithDuration:0.3f animations:^{
                [weakSelf.imageView setAlpha:1.0f];
            }];
        [weakSelf.loaderView stopAnimating];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [weakSelf.loaderView stopAnimating];

    }];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_GRIDVIEWCELL_TAPPED object:self];
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
