//
//  BaseController.h
//  iSeller
//
//  Created by Чина on 27.12.12.
//  Copyright (c) 2012 CloudTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Model.h"

typedef void(^block)();

@interface BaseController : UIViewController <UIAlertViewDelegate>

@property (nonatomic) BOOL skipAuth;
@property (nonatomic, copy) block successBlock;

@end
