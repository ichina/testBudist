//
//  LoaderView.h
//  iSeller
//
//  Created by Чина on 26.02.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    loaderViewModeDeterminate = 0,
    loaderViewModeIndeterminate
}
loaderViewMode;

@interface LoaderView : UIImageView
{
    loaderViewMode mode;
    __block BOOL isAnimate;
    int previndex;
}

-(id)initWithMode:(loaderViewMode)loaderMode;
-(void)setProgress:(float)_progress;

@end
