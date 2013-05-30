//
//  asdasd.m
//  asdf
//
//  Created by Чина on 01.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "CGSwitch.h"
#import <QuartzCore/QuartzCore.h>

#define SWITCH_BG_HEIGHT 32 //63
#define SWITCH_BG_WIDTH 79 //158
#define SWITCH_CONTENT_WIDTH 75 //150
@implementation CGSwitch

static int sliderCenterObservanceContext;
static int sliderValueChangedObservanceContext;
@synthesize isOn;

@synthesize delegate;

- (id)initWithToggleImage:(UIImage*) toggleImage sliderImage:(UIImage*)sliderImage
{
    //NSLog(@"%@",NSStringFromCGSize(sliderImage.size));
    //NSLog(@"%@",NSStringFromCGSize(toggleImage.size));

    CGRect frame = CGRectMake(0, 0,SWITCH_BG_WIDTH, SWITCH_BG_HEIGHT);
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self initialSettingWithToggleImage:toggleImage sliderImage:sliderImage];
    }
    return self;
}

-(void)initialSettingWithToggleImage:(UIImage*) toggleImage sliderImage:(UIImage*)sliderImage
{

    //isOn=YES;
    [self setIsOn:YES];
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(2, 2, 75, 28)];
    [contentView setClipsToBounds:YES];
    [contentView.layer setCornerRadius:4];
    [self addSubview:contentView];
    
    toggleView = [[UIImageView alloc] initWithImage:toggleImage];
    [toggleView sizeToFit];
    [contentView addSubview:toggleView];
    
    alphaView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(toggleView.frame), CGRectGetWidth(toggleView.frame)/2, CGRectGetHeight(toggleView.frame))];
    [alphaView setBackgroundColor:[UIColor whiteColor]];
    [alphaView setAlpha:1.0f];
    
    [contentView addSubview:alphaView];

    backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"switch_bg.png"]];
    [backgroundView sizeToFit];
    [self addSubview:backgroundView];
    
    sliderView = [[UIImageView alloc] initWithImage:sliderImage];
    [sliderView sizeToFit];
    [sliderView setUserInteractionEnabled:YES];
    [self addSubview:sliderView];
    [sliderView setCenter:CGPointMake(self.frame.size.width-sliderView.frame.size.width/2-2, sliderView.center.y +2)];
    
    [sliderView addObserver:self forKeyPath:@"center" options:0 context:&sliderCenterObservanceContext];
    
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(sliderPan:)];
    [self addGestureRecognizer:panGesture];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTap:)];
    [self addGestureRecognizer:tapGesture];
    
    [self setON:NO duration:0.0f];
    [alphaView setCenter:CGPointMake(toggleView.frame.origin.x+alphaView.frame.size.width/2, alphaView.center.y)];
    
    [self addObserver:self forKeyPath:@"isOn" options:0 context:&sliderValueChangedObservanceContext];
}

-(void)setFrame:(CGRect)frame
{
    if(!toggleView || !sliderView)
        [super setFrame:frame];
    else
    {
        [super setFrame:CGRectMake(frame.origin.x, frame.origin.y, toggleView.image.size.width/2+sliderView.image.size.width/2, toggleView.image.size.height)];
    }
}

-(void) sliderTap:(UIGestureRecognizer*) gesture
{
    /*
    if (isOn) {
        [UIView animateWithDuration:0.3 animations:^{
            [sliderView setCenter:CGPointMake(sliderView.frame.size.width/2+2, sliderView.center.y)];
            [toggleView setCenter:CGPointMake(contentView.frame.size.width-toggleView.image.size.width/2, toggleView.center.y)];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3 animations:^{
            [sliderView setCenter:CGPointMake(contentView.frame.size.width-sliderView.frame.size.width/2+2, sliderView.center.y)];
            [toggleView setCenter:CGPointMake(toggleView.frame.size.width/2, toggleView.center.y)];
        }];
    }
    
    isOn = !isOn;
     */
    [self setON:!isOn duration:0.3f];
    //NSLog(isOn?@"YES":@"NO");

}

-(void)sliderPan:(UIGestureRecognizer*) gesture
{
    CGPoint point = [gesture locationInView:contentView];
    switch (gesture.state) {
        case UIGestureRecognizerStateChanged:case UIGestureRecognizerStateBegan:
        {
            if(point.x<=sliderView.frame.size.width/2) point.x = sliderView.frame.size.width/2;
            if(point.x>=contentView.frame.size.width-sliderView.frame.size.width/2) point.x = contentView.frame.size.width-sliderView.frame.size.width/2;

                [UIView animateWithDuration:0.05f delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction animations:^{
                    [sliderView setCenter:CGPointMake(point.x+2, sliderView.center.y)];
                    [toggleView setCenter:CGPointMake(point.x, toggleView.center.y)];
                } completion:nil];
        }
            break;
        case UIGestureRecognizerStateEnded: case UIGestureRecognizerStateCancelled:
        {
            if(point.x>contentView.frame.size.width/2)
            {
                /*
                isOn = YES;
                [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                    [sliderView setCenter:CGPointMake(contentView.frame.size.width-sliderView.frame.size.width/2 +2, sliderView.center.y)];
                    [toggleView setCenter:CGPointMake(toggleView.frame.size.width/2, toggleView.center.y)];                } completion:nil];
                 */
                [self setON:YES duration:0.1f];
            }
            else
            {
                /*
                isOn = NO;
                [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                    [sliderView setCenter:CGPointMake(sliderView.frame.size.width/2 +2, sliderView.center.y)];
                    [toggleView setCenter:CGPointMake(contentView.frame.size.width-toggleView.image.size.width/2, toggleView.center.y)];
                } completion:nil];
                 */
                [self setON:NO duration:0.1f];
            }
            //NSLog(isOn?@"YES":@"NO");
        }
            break;
        default:
            break;
    }
    
}

-(void) setON:(BOOL)on duration:(float) duration
{
    if(on)
        [UIView animateWithDuration:duration animations:^{
            [sliderView setCenter:CGPointMake(contentView.frame.size.width-sliderView.frame.size.width/2+2, sliderView.center.y)];
            [toggleView setCenter:CGPointMake(toggleView.frame.size.width/2, toggleView.center.y)];
            [self calculateAlpha];
        }];
    else
        [UIView animateWithDuration:duration animations:^{
            [sliderView setCenter:CGPointMake(sliderView.frame.size.width/2+2, sliderView.center.y)];
            [toggleView setCenter:CGPointMake(contentView.frame.size.width-toggleView.image.size.width/2, toggleView.center.y)];
            [self calculateAlpha];
        }];
    [self setIsOn:on];
    //isOn = on;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &sliderCenterObservanceContext) {
        
        [self calculateAlpha];
        
    } else if (context == &sliderValueChangedObservanceContext) {
        
        if(delegate && [delegate respondsToSelector:@selector(CGSwitch:valueChanged:)])
            [delegate CGSwitch:self valueChanged:isOn];
    }else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
/*
-(void)setIsOn:(BOOL)_isOn
{
    isOn = _isOn;
}
*/
-(void)calculateAlpha
{
    float ratio = (self.frame.size.width-sliderView.frame.size.width - sliderView.center.x)/(self.frame.size.width-sliderView.frame.size.width);
    [alphaView setAlpha:(0.2f+1.3f*ratio)];
    
    [alphaView setCenter:CGPointMake(toggleView.frame.origin.x+alphaView.frame.size.width/2, alphaView.center.y)];
}

@end
