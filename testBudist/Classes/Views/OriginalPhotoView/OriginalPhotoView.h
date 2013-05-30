//
//  OriginalPhotoView.h
//  iSeller
//
//  Created by Чина on 20.02.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoaderView.h"
@interface OriginalPhotoView : UIView
{
    NSURL* imageUrl;
    //__block UIImageView* imageView;
    //UIActivityIndicatorView* indicator;
    //LoaderView* loaderView;
    //float mCurrentOffsetX;
    //float mCurrentOffsetY;
    CGAffineTransform newScaleTransform;
    CGAffineTransform newTranslationTransform;
    CGPoint lastPoint;
    float lastScale;
}

//@property(nonatomic,strong) UIActivityIndicatorView* indicator;

@property (nonatomic) float mCurrentScale;
@property (nonatomic) float mLastScale;

@property(nonatomic) BOOL isAlreadyLoading;

-(id)initWithURL:(NSURL*)url;
-(void)viewWillShow;

@end
