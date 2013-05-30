//
//  TutorialPageView.h
//  iSeller
//
//  Created by Чингис on 28.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialPageView : UIView
{
    float contentHeight;
}
-(void)addTitle:(NSString*)title;
-(void)addMirroredImage:(NSString*)imageName;
-(void)addLabel:(NSString* ) text;
-(void)addMirroredImage:(NSString*)imageName withGradientToTopOffset:(float)yOffset;
-(void)addContentOffset:(float)offset;

@end
