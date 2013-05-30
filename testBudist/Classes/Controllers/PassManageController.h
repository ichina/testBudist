//
//  PassManageController.h
//  iSeller
//
//  Created by Чина on 05.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "BaseController.h"

@interface PassManageController : BaseController <UITextFieldDelegate,CGAlertViewDelegate>

@property (nonatomic) BOOL isForgotPassMode;

@property (weak, nonatomic) IBOutlet UITextField *confirmPassField;
@property (weak, nonatomic) IBOutlet UITextField *passField;
@property (weak, nonatomic) IBOutlet UITextField *oldPassField;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIControl *panelView;

- (IBAction)changePassword:(id)sender;
- (IBAction)backAction:(id)sender;
- (IBAction)backgroundTapped:(id)sender;

@end
