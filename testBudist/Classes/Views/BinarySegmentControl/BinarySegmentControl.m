//
//  BinarySegmentControl.m
//  iSeller
//
//  Created by Чингис on 02.04.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "BinarySegmentControl.h"

@implementation BinarySegmentControl
@synthesize lastTouch;
@synthesize selectedSegmentIndex = _selectedSegmentIndex;
@synthesize delegate;

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        firstSegment = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/2, self.frame.size.height)];
        
        [firstSegment setImage:[[UIImage imageNamed:@"segment_fb.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:5]];
        [firstSegment setHighlightedImage:[[UIImage imageNamed:@"segment_fb_selected.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:5]];
        
        UILabel* lblFb = [[UILabel alloc] init];
        [lblFb setText:@"Facebook"];
        [lblFb setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f]];
        [lblFb setShadowColor:[UIColor colorWithWhite:0 alpha:0.75f]];
        [lblFb setShadowOffset:CGSizeMake(0, 1)];
        [lblFb sizeToFit];
        [lblFb setCenter:firstSegment.center];
        [lblFb setBackgroundColor:[UIColor clearColor]];
        [lblFb setTextColor:[UIColor whiteColor]];
        
        secondSegment = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width/2, 0, self.frame.size.width/2, self.frame.size.height)];
        [secondSegment setImage:[[UIImage imageNamed:@"segment_vk.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:5]];
        [secondSegment setHighlightedImage:[[UIImage imageNamed:@"segment_vk_selected.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:5]];
        UILabel* lblVk = [[UILabel alloc] init];
        [lblVk setText:NSLocalizedString(@"VK.com", nil)];
        [lblVk setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f]];
        [lblVk setShadowColor:[UIColor colorWithWhite:0 alpha:0.75f]];
        [lblVk setShadowOffset:CGSizeMake(0, 1)];
        [lblVk sizeToFit];
        [lblVk setCenter:secondSegment.center];
        [lblVk setBackgroundColor:[UIColor clearColor]];
        [lblVk setTextColor:[UIColor whiteColor]];
        
        [self addSubview:firstSegment];
        [self addSubview:secondSegment];
        [self addSubview:lblFb];
        [self addSubview:lblVk];

    }
    return self;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [[event.allTouches anyObject] locationInView:self];
    
    [self calculateIndexFromPoint:touchPoint];
    
    [super touchesBegan:touches withEvent:event];
}

-(void) calculateIndexFromPoint:(CGPoint) point
{
    int index = point.x/(self.frame.size.width/2);
    if(index!=self.selectedSegmentIndex)
    {
        [self setSelectedSegmentIndex:index];
        if (delegate && [delegate respondsToSelector:@selector(binarySegmentChangeValue:)]) {
            [delegate binarySegmentChangeValue:self];
        }
    }
}

-(void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex
{
    _selectedSegmentIndex = selectedSegmentIndex;
    [firstSegment setHighlighted:!self.selectedSegmentIndex];
    [secondSegment setHighlighted:self.selectedSegmentIndex];
    
    if(selectedSegmentIndex == -1)
    {
        [firstSegment setHighlighted:NO];
        [secondSegment setHighlighted:NO];
    }
}

@end
