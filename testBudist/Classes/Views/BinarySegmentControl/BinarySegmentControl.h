//
//  BinarySegmentControl.h
//  iSeller
//
//  Created by Чингис on 02.04.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BinarySegmentDelegate;
@interface BinarySegmentControl : UIView
{
    UIImageView* firstSegment;
    UIImageView* secondSegment;
}

@property (nonatomic, weak) id <BinarySegmentDelegate> delegate;

@property (nonatomic, assign) CGPoint lastTouch;
@property( nonatomic) NSInteger selectedSegmentIndex;

@end

@protocol BinarySegmentDelegate <NSObject>
@optional
-(void)binarySegmentChangeValue:(BinarySegmentControl*)binarySegment;

@end