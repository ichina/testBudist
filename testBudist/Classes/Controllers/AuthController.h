//
//  AuthController.h
//  iSeller
//
//  Created by Чина on 27.12.12.
//  Copyright (c) 2012 CloudTeam. All rights reserved.
//

#import "BaseController.h"
#import "AppDelegate.h"
#import "UnderlinedButton.h"
@interface AuthController : GAITrackedViewController <UITextFieldDelegate,CGAlertViewDelegate>
{
    __weak IBOutlet UIImageView *fieldsBGView;
}
@property (weak, nonatomic) IBOutlet UIButton *fbButton;
@property (weak, nonatomic) IBOutlet UIButton *authButton;
@property (weak, nonatomic) IBOutlet UITextField *loginTextField;
@property (weak, nonatomic) IBOutlet UITextField *passTextField;
@property (weak, nonatomic) IBOutlet UnderlinedButton *signUpButton;
@property (weak, nonatomic) IBOutlet UnderlinedButton *forgotPasswordButton;

- (IBAction)signUp:(id)sender;
- (IBAction)authWithFB:(id)sender;
- (IBAction)authWithVK:(id)sender;
- (IBAction)goToInfo:(id)sender;
- (IBAction)goToForgotPass:(id)sender;
- (IBAction)backgroundTapped:(id)sender;


@end
