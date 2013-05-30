//
//  TutorialLabel.h
//  iSeller
//
//  Created by Чингис on 28.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialLabel : UIView

@property(nonatomic,strong) UILabel* label;

-(void) setText:(NSString*)text;

@end
