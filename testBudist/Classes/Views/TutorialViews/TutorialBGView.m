//
//  TutorialBGView.m
//  iSeller
//
//  Created by Чингис on 26.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "TutorialBGView.h"

@implementation TutorialBGView

@synthesize isFirstPresentTutorial = _isFirstPresentTutorial;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGFloat radius = 270.0f;
    
    CGPoint c = CGPointMake(160, 100) ;//147

    CGContextRef cx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(cx);
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    
    CGFloat comps[] = { 0.0, 0.0, 0.0, 0.58f, 0.0, 0.0, 0.0, 1.0f};
    CGFloat comps2[] = { 0.0, 0.0, 0.0, 1.0f, 0.0, 0.0, 0.0, 1.0f};

    CGFloat locs[] = {0,1};
    CGGradientRef g = CGGradientCreateWithColorComponents(space, comps, locs, 2);
    CGGradientRef g2 = CGGradientCreateWithColorComponents(space, comps2, locs, 2);

    if(self.isFirstPresentTutorial)
    {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 0, 0);
        CGPathMoveToPoint(path, NULL, -120, rect.size.height+100);

        CGPathAddArc(path, NULL, rect.size.width/2 , rect.size.height+80, 240, - M_PI, 0, 0);
        CGPathAddLineToPoint(path, NULL, rect.size.width+120, rect.size.height);
        CGPathAddLineToPoint(path, NULL, rect.size.width, 0);
        CGPathAddLineToPoint(path, NULL, 0, 0);
        CGContextAddPath(cx, path);
        CGContextClip(cx);
        CGPathRelease(path);
    }
    CGContextDrawRadialGradient(cx, g, c, 0.0f, c, radius+(IS_IPHONE5?40:-40), 0);
    CGContextDrawRadialGradient(cx, g2, c, radius+(IS_IPHONE5?40:-40), c, (IS_IPHONE5?2:(self.isFirstPresentTutorial? 1.5:1.6f))*radius, 0);
    CGContextRestoreGState(cx);
    
    CGGradientRelease(g);
    CGGradientRelease(g2);
    CGColorSpaceRelease(space);
    if(self.isFirstPresentTutorial)
    {
        CGContextRef cx2 = UIGraphicsGetCurrentContext();
        
        CGContextSaveGState(cx2);
        CGColorSpaceRef space2 = CGColorSpaceCreateDeviceRGB();
        
        CGFloat comps3[] = { 0.0, 0.0, 0.0, 0.1f, 0.0, 0.0, 0.0, 1.0f};//(IS_IPHONE5)?1.0f:0.95f};
        
        CGFloat locs3[] = {0,1};
        CGGradientRef g3 = CGGradientCreateWithColorComponents(space2, comps3, locs3, 2);
        c = CGPointMake(rect.size.width/2, rect.size.height+80);
        CGContextDrawRadialGradient(cx2, g3, c, 0.0f, c, 241, 0);
        CGContextRestoreGState(cx2);
        
        CGGradientRelease(g3);
        CGColorSpaceRelease(space2);
    }
}

-(void)setIsFirstPresentTutorial:(BOOL)isFirstPresentTutorial
{
    _isFirstPresentTutorial = isFirstPresentTutorial;
    [self setNeedsDisplay];
}

@end
