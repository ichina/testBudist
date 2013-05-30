//
//  OriginalPhotoView.m
//  iSeller
//
//  Created by Чина on 20.02.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "OriginalPhotoView.h"
#import <UIImageView+AFNetworking.h>

@interface OriginalPhotoView ()
@property(nonatomic,strong) UIImageView* imageView;
@property(nonatomic,strong) LoaderView* loaderView;
@end

@implementation OriginalPhotoView

@synthesize imageView;
/*
 @synthesize indicator;
*/
@synthesize loaderView;

@synthesize isAlreadyLoading;
@synthesize mCurrentScale,mLastScale;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithURL:(NSURL*)url
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, (IS_IPHONE5)? 568 : 480)];
    if(self)
    {
        imageUrl = [url copy];
        [self initialFunc];
    }
    return self;
}

-(void)initialFunc
{
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320,self.frame.size.height)];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:imageView];
    
    loaderView = [[LoaderView alloc] initWithMode:loaderViewModeDeterminate];
    [loaderView setCenter:self.center];
    [loaderView startAnimating];
    [self addSubview:loaderView];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self addGestureRecognizer:pinchGesture];
    
}
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [imageView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [loaderView setCenter:imageView.center];
}
-(void)viewWillShow
{
    if(isAlreadyLoading || imageView.image)
        return;
    isAlreadyLoading = YES;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:imageUrl];
    [request setHTTPShouldHandleCookies:NO];
    
    [loaderView setProgress:0];
    __weak OriginalPhotoView *weakSelf = self;
    [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:imageUrl] placeholderImage:imageView.image success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [weakSelf.loaderView setProgress:1.0f];
        
        CATransition *animation = [CATransition animation];
        animation.duration = 0.2f;
        animation.type = kCATransitionFade;
        [weakSelf.layer addAnimation:animation forKey:@"imageFade"];
        
        [weakSelf.imageView setImage:image];
        weakSelf.isAlreadyLoading=NO;
        
        CGAffineTransform currentTransform = CGAffineTransformIdentity;
        weakSelf.imageView.transform = CGAffineTransformScale(currentTransform, 1.0f, 1.0f);
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        weakSelf.isAlreadyLoading=NO;
    } progress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        float progress = ((float)totalBytesRead)/((float)totalBytesExpectedToRead);
        [weakSelf.loaderView setProgress:progress];
    }];
}


- (void)handlePinch:(UIPinchGestureRecognizer *)sender {
    
    static CGPoint beginPoint;
    if (sender.state == UIGestureRecognizerStateBegan) {
        lastScale = 1.0;
        lastPoint = [sender locationInView:self];
        
        beginPoint = [sender locationInView:self];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_ALLOW_ROTATING_IN_FULL_SIZE object:self userInfo:@{@"allowRotate":@NO}];
    }
    
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        mLastScale = 1.0f;
        mCurrentScale = 1.0f;//(mCurrentScale<1.0f)?	1.0f:mCurrentScale;
        [UIView animateWithDuration:0.3f animations:^{
            CGAffineTransform currentTransform = CGAffineTransformIdentity;
            CGAffineTransform scaleTransform = CGAffineTransformScale(currentTransform, mCurrentScale, mCurrentScale);
            CGAffineTransform translationTransform = CGAffineTransformTranslate(currentTransform, 0, 0);
            [self.layer setAffineTransform:CGAffineTransformConcat(scaleTransform, translationTransform)];
        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_ALLOW_ROTATING_IN_FULL_SIZE object:self userInfo:@{@"allowRotate":@YES}];
        return;
    }
    
    // Scale
    CGFloat scale = 1.0 - (lastScale - sender.scale);
    [self.layer setAffineTransform:CGAffineTransformScale([self.layer affineTransform], scale, scale)];
    lastScale = sender.scale;
    
    // Translate
    CGPoint point = [sender locationInView:self];
    [self.layer setAffineTransform:CGAffineTransformTranslate([self.layer affineTransform], point.x - lastPoint.x, point.y - lastPoint.y)];
    lastPoint = [sender locationInView:self];
}

@end
