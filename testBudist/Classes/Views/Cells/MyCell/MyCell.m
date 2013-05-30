//
//  MyCell.m
//  iSaler
//
//  Created by Paul Semionov on 28.11.12.
//
//

#import "MyCell.h"

#import "PriceFormatter.h"

typedef enum {
    StatusModeration = 0,
    StatusActive,
    StatusInactive,
    StatusSold
} Status;

@implementation MyCell

@synthesize titleOfAd, imageView, price, state = _state;

@synthesize badge,badgeView,statusArray;

@synthesize justCreatedImage;

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if(self) {
        
        badgeView = [[PSBadgeStatusView alloc] initWithTitle:NSLocalizedString(@"inactive", nil) textColor:[UIColor whiteColor] andFontSize:14.0];
        statusArray = [NSArray arrayWithObjects:@"moderation", @"active", @"inactive", @"sold", nil];
        [self addSubview:badgeView];
        
    }
    
    return self;
}

- (void)setState:(NSString *)state {
    
    
    badgeView.title.text = NSLocalizedString(state, nil);
    
    [badgeView refreshInterface];
    
    switch ([statusArray indexOfObject:state]) {
        case StatusModeration:
            [badgeView setColor:[UIColor colorWithRed:238.0/255 green:164.0/255 blue:1.0/255 alpha:1.0]];
            break;
        case StatusActive:
            [badgeView setColor:[UIColor colorWithRed:211.0/255 green:1.0/255 blue:51.0/255 alpha:1.0]];
            break;
        case StatusInactive:
            [badgeView setColor:[UIColor colorWithRed:160.0/255 green:164.0/255 blue:173.0/255 alpha:1.0]];
            break;
        case StatusSold:
            [badgeView setColor:[UIColor colorWithRed:65.0/255 green:87.0/255 blue:103.0/255 alpha:1.0]];
            break;
            
        default:
            break;
    }
    
    [badgeView setNeedsDisplay];
        
    if(![NSStringFromCGRect(self.badge.frame) isEqualToString:NSStringFromCGRect(CGRectMake(self.price.frame.origin.x + 10, 43, badgeView.frame.size.width, badgeView.frame.size.height))]) {
    
        [badgeView setFrame:CGRectMake(self.price.frame.origin.x + 10, 43, badgeView.frame.size.width, badgeView.frame.size.height)];
    }
        
}

- (void)setViewCount:(NSString *)viewCount {
    
    [[self viewWithTag:101] removeFromSuperview];
    
    if(viewCount) {
    
        PSBadgeStatusView *viewCountView = [[PSBadgeStatusView alloc] initWithImage:[UIImage imageNamed:@"eye.png"] title:viewCount textColor:[UIColor whiteColor] andFontSize:14.0];
        
        [viewCountView setTag:101];
        
        [viewCountView setColor:[UIColor colorWithRed:160.0/255 green:164.0/255 blue:173.0/255 alpha:1.0]];
        
        [self addSubview:viewCountView];
        
        //NSLog(@"Title of ad label: %@", NSStringFromCGRect(self.titleOfAd.frame));
        
        [viewCountView setFrame:CGRectMake(self.titleOfAd.frame.origin.x + self.titleOfAd.frame.size.width - 82, 43, viewCountView.frame.size.width, viewCountView.frame.size.height)];
    }
}

-(void) setAdvertisementInfo :(Advertisement*) ad
{
    self.titleOfAd.text = [ad title];
    self.price.text = [[PriceFormatter sharedFormatter] formatPrice:[[ad price] floatValue]];
    [self setState:[ad status]];
    
    if(ad.viewCount.intValue) {
        [self setViewCount:[ad.viewCount stringValue]];
    }else{
        //[cell.badge setText:@""];
        [self setViewCount:nil];
    }
    
    if(self.tag == 102) {
        
        [self.imageView setImageWithURL:[NSURL URLWithString:[ad getSmallImage]] placeholderImage:self.justCreatedImage];
        self.tag = 0;
        
    }else{
        
        [self.imageView setImageWithURL:[NSURL URLWithString:[ad getSmallImage]] placeholderfileName:@"placeholder.png"];
        
    }

}

@end
