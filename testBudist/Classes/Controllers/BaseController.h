//
//  BaseController.h
//  iSeller
//
//  Created by Чина on 27.12.12.
//  Copyright (c) 2012 CloudTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Model.h"

#import <GAI.h>

typedef void(^block)();

@interface BaseController : GAITrackedViewController <ModelDelegate, CGAlertViewDelegate>

@property (nonatomic) BOOL skipAuth;
@property (nonatomic, copy) block successBlock;

- (BOOL)isAuthorized;
- (void)authorizeWithAlert:(BOOL)needAlert animated:(BOOL)animated block:(block)_block;
- (void)authorize:(BOOL)animated block:(block)_block;

- (void)sendEventWithCategory:(NSString *)_category action:(NSString *)_action label:(NSString *)_label value:(NSNumber *)_value;

@end
