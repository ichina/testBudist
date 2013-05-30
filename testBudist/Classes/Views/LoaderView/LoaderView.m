//
//  LoaderView.m
//  iSeller
//
//  Created by Чина on 26.02.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "LoaderView.h"
#import "UIImage+scale.h"

@implementation LoaderView

-(id)initWithMode:(loaderViewMode)loaderMode
{
    self = [super initWithFrame:loaderMode==loaderViewModeIndeterminate ? CGRectMake(0, 0, 37, 37):CGRectMake(0, 0, 74, 74)];
    if (self) {
        self.animationImages = (loaderMode==loaderViewModeIndeterminate)?[self creatIndeterminateAnimation] : [self creatDeterminateAnimation];
        self.animationDuration = 0.5f;
        mode = loaderMode;
        previndex = -1;
    }
    return self;
}

-(void)startAnimating
{
    if(mode==loaderViewModeIndeterminate)
        [super startAnimating];
}

- (NSArray*)creatIndeterminateAnimation {
    UIImage *image = [UIImage imageNamed:@"indeterminate.png"];
    NSMutableArray *animationImages = [NSMutableArray array];
    for (int i = 0; i<8; i++) {
        [animationImages addObject:[image imageRotatedByDegrees:45*i]];
    }
    return animationImages;
}

- (NSArray*)creatDeterminateAnimation {
    NSString* fileName = @"determinate";
    NSMutableArray *animationImages = [NSMutableArray array];
    for (int i = 1; i<=9; i++) {
        [animationImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%@%d.png",fileName,i]]];
    }
    return animationImages;
}

-(void)setProgress:(float)_progress
{
    if(mode == loaderViewModeIndeterminate)
        return;
    
    if(_progress>1 || _progress<0)
        return;
    
    int index = (int)((self.animationImages.count-1)*_progress+1)%self.animationImages.count;
    if(index!=previndex)
    {
        self.image = self.animationImages[index];
        previndex = index;
    }
    [self setHidden:(_progress==1)];
}


@end
