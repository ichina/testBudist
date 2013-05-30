//
//  CalloutView.m
//  iSeller
//
//  Created by Paul Semionov on 25.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "CalloutView.h"

@implementation CalloutView

@synthesize image;

@synthesize title;

- (void)drawRect:(CGRect)rect {
        
    // Set the fill color
	[[UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:0.8] setFill];
    
    // Create the path for the rounded rectanble
    CGRect roundedRect = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height * 0.8);
    UIBezierPath *roundedRectPath = [UIBezierPath bezierPathWithRoundedRect:roundedRect cornerRadius:8.0];
    
    // Create the arrow path
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    CGFloat midX = CGRectGetMidX(self.bounds);
    CGPoint p0 = CGPointMake(midX, CGRectGetMaxY(self.bounds));
    [arrowPath moveToPoint:p0];
    [arrowPath addLineToPoint:CGPointMake((midX - ((self.frame.size.height <= 72) ? 8.0 : 15.0)), CGRectGetMaxY(roundedRect))];
    [arrowPath addLineToPoint:CGPointMake((midX + ((self.frame.size.height <= 72) ? 8.0 : 15.0)), CGRectGetMaxY(roundedRect))];
    [arrowPath closePath];
    
    // Attach the arrow path to the buble
    [roundedRectPath appendPath:arrowPath];
    
    [roundedRectPath fill];
    
}

- (void)removeFromSuperview {
    
    NSLog(@"Someone tried to remove callout from subview");
    
    [super removeFromSuperview];
    
}

@end
