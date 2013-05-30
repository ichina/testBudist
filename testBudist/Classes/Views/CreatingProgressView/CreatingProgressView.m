//
//  CreatingProgressView.m
//  iSeller
//
//  Created by Чина on 19.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "CreatingProgressView.h"
#import <QuartzCore/QuartzCore.h>
@implementation CreatingProgressView

@synthesize backgroundTintColor = _backgroundTintColor;
@synthesize progress,lblProgress;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        self.userInteractionEnabled = NO;
        lblProgress = [[UILabel alloc] init];
        [lblProgress setTextAlignment:NSTextAlignmentCenter];
        [lblProgress setTextColor:[UIColor whiteColor]];
        lblProgress.font = [UIFont fontWithName:@"Lobster 1.4" size:25.f];
        [lblProgress setBackgroundColor:[UIColor clearColor]];
        [lblProgress setCenter:self.center];
        [lblProgress setShadowColor:[UIColor blackColor]];
        [lblProgress setShadowOffset:CGSizeMake(0, 1)];
        [self addSubview:lblProgress];
        lblProgress.alpha = 0;
    
    }
    return self;
}

-(void) setProgress:(float)_progress
{
    progress = _progress;
    
    [self setNeedsDisplay];
    
    if(progress==0)
        lblProgress.alpha = 1.0f;
    [lblProgress setText:[NSString stringWithFormat:@"%d%%",(int)(progress*100)]];
    [lblProgress sizeToFit];
    [lblProgress setCenter:CGPointMake(self.center.x-self.frame.origin.x,self.center.y-self.frame.origin.y)];
    
    if(progress==1)
    {
        [UIView animateWithDuration:0.4f delay:0.5f options:0 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
	
	CGRect allRect = self.bounds;
	CGContextRef context = UIGraphicsGetCurrentContext();
	
    CGPoint center = CGPointMake(allRect.size.width / 2, allRect.size.height / 2);
    CGFloat radius = (allRect.size.width - 4) / 2;
    
    CGFloat startAngle = - ((float)M_PI / 2) ; // 90 degrees
    CGFloat endAngle = + progress*2 * (float)M_PI - (float)M_PI / 2;
    
    
    
    CGContextSaveGState(context);
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    
    CGFloat comps[] = { 0.0, 0.0, 0.0, 0.0f, 0.0, 0.0, 0.0, 0.39f};
    CGFloat comps2[] = { 0.0, 0.0, 0.0, 0.39f, 0.0, 0.0, 0.0, 0.39f};
    
    CGFloat locs[] = {0,1};
    CGGradientRef g = CGGradientCreateWithColorComponents(space, comps, locs, 2);
    CGGradientRef g2 = CGGradientCreateWithColorComponents(space, comps2, locs, 2);
    
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, center.x, center.y);
    //CGPathAddArcToPoint(path, NULL, c.x+100, c.y-100, c.x+100, c.y, 100);
    CGPathAddArc(path, NULL, center.x, center.y, radius, startAngle, endAngle, 0);
    CGPathAddLineToPoint(path, NULL, center.x, center.y);
    
    CGContextAddPath(context, path);
    CGContextClip(context);
        
    //CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 0.7f);
    /*
    CGContextMoveToPoint(context, center.x, center.y);
    CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
    CGContextClosePath(context);
     */
    //CGContextFillPath(context);
    
    CGContextDrawRadialGradient(context, g, center, 0.0f, center, radius*0.83, 0);
    CGContextDrawRadialGradient(context, g2, center, radius*0.83, center, radius, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(g);
    CGGradientRelease(g2);
    CGPathRelease(path);
    CGColorSpaceRelease(space);
}

-(void) removeFromSuperview
{
    [super removeFromSuperview];
}
@end
