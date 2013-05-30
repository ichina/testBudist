//
//  TutorialImageView.h
//  iSeller
//
//  Created by Чингис on 26.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialImageView : UIImageView

-(void)setTutorialImage:(UIImage *)image;
-(void)setTutorialImage:(UIImage *)image withGradientToTopOffset:(float)yOffset;

-(void)setMirrorImage:(UIImage*)image;
@end
