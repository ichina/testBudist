//
//  LoaderPlayView.m
//  testBudist
//
//  Created by Чингис on 03.06.13.
//  Copyright (c) 2013 Чингис. All rights reserved.
//

#import "LoaderPlayView.h"

@implementation LoaderPlayView
@synthesize progress;
@synthesize delegate;
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        
    }
    return self;
}

-(void)setProgress:(CGFloat)_progress
{
    progress = _progress;
    
    [self setNeedsDisplay];
    
    if(progress==1)
    {
        self.loadingBtn.titleLabel.text = @"";
        [self.loadingBtn setImage:[UIImage imageNamed:@"audio03.png"] forState:UIControlStateNormal];
        [UIView animateWithDuration:0.3f delay:0.3f options:0 animations:^{
            self.finalStateImageView.alpha = 1.0f;
        } completion:^(BOOL finished) {
            
        }];
    }
}

-(IBAction)loadingBtnClicked:(UIButton*)sender
{
    if(progress!=1)
        return;
    
    if(delegate && [delegate respondsToSelector:@selector(loaderPlayBtnDidClicked) ])
        [delegate loaderPlayBtnDidClicked];
    
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGRect allRect = self.bounds;
    
    CGContextRef context0 = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context0);
    CGContextDrawImage(context0, rect, [UIImage imageNamed:@"audio01.png"].CGImage);
    
	CGContextRef context = UIGraphicsGetCurrentContext();
	
    CGPoint center = CGPointMake(allRect.size.width / 2, allRect.size.height / 2);
    CGFloat radius = (allRect.size.width - 4) / 2;
    
    CGFloat startAngle = - ((float)M_PI / 2) ; // 90 degrees
    CGFloat endAngle = + progress*2 * (float)M_PI - (float)M_PI / 2;
    
    
    
    CGContextSaveGState(context);

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, center.x, center.y);
    CGPathAddArc(path, NULL, center.x, center.y, radius, startAngle, endAngle, 0);
    CGPathAddLineToPoint(path, NULL, center.x, center.y);
    
    CGContextAddPath(context, path);
    CGContextClip(context);
    
    CGContextDrawImage(context, rect, [UIImage imageNamed:@"audio02_glow.png"].CGImage);
    CGContextRestoreGState(context);
    CGContextRestoreGState(context0);

    CGPathRelease(path);

}


@end
