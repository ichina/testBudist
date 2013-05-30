//
//  CreatingProgressView.h
//  iSeller
//
//  Created by Чина on 19.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>
@interface CreatingProgressView : UIView

@property (nonatomic, strong) UILabel* lblProgress;
@property (nonatomic, strong) UIColor *backgroundTintColor;
@property (nonatomic) float progress;
@property (nonatomic) BOOL hiddden;

-(void) setProgress:(float)_progress;

@end
