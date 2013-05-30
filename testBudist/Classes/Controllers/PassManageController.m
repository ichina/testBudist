//
//  PassManageController.m
//  iSeller
//
//  Created by Чина on 05.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.


#import "PassManageController.h"
#import "Profile.h"
#import "NSString+Extensions.h"

@interface PassManageController ()

@end

@implementation PassManageController

@synthesize isForgotPassMode;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:BG_IMAGE]]];
    
    if(isForgotPassMode)
    {
        [self.oldPassField setHidden:YES];
        [self.confirmPassField setHidden:YES];
        [self.passField setSecureTextEntry:NO];
        [self.passField setKeyboardType:UIKeyboardTypeEmailAddress];
        [self.passField setPlaceholder:NSLocalizedString(@"Enter Email", nil)];
        [self.passField setReturnKeyType:UIReturnKeyDone];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [[self.panelView viewWithTag:545] removeFromSuperview];
        [[self.panelView viewWithTag:546] removeFromSuperview];
        [self.imageView setFrame:CGRectInset(self.imageView.frame, 0, 44)];
    }
    else
    {
        [self.oldPassField setReturnKeyType:UIReturnKeyNext];
        [self.passField setReturnKeyType:UIReturnKeyNext];
        [self.confirmPassField setReturnKeyType:UIReturnKeyDone];
    }
    
    [self.imageView setImage:[self.imageView.image  resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
	// Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationItem.title = NSLocalizedString((isForgotPassMode?@"Forgot password":@"Change password"), nil);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setOldPassField:nil];
    [self setConfirmPassField:nil];
    [self setImageView:nil];
    [self setPanelView:nil];
    [super viewDidUnload];
}
- (IBAction)changePassword:(id)sender {
    if(!isForgotPassMode)
    {
        if (self.passField.text.length<6 || self.oldPassField.text.length<6)
        {
            [[[CGAlertView alloc] initWithTitle:NSLocalizedString(@"Too short password", nil) message:NSLocalizedString(@"The password must be at least 6 characters", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        }
        
        if(![self.passField.text isEqualToString:self.confirmPassField.text])
        {
            [[[CGAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Passwords are not equal", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        }
        
        [[Profile sharedProfile] updateProfileWithParams:@{@"current_password": self.oldPassField.text, @"password":self.passField.text, @"password_confirmation"
         :self.confirmPassField.text} progress:nil success:^{
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSError *error) {
            
        }];
    }
    else
    {
        if (![self.passField.text isValidEmail])
        {
            [[[CGAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Incorrect Email", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        }
        
        [[Profile sharedProfile] restorePassword:self.passField.text withSuccess:^{
                                                            [[[CGAlertView alloc] initWithTitle:NSLocalizedString(@"Sended", nil) message:NSLocalizedString(@"Sent to your e-mail letter", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                                        } failure:^(NSError *error) {
                                                            [[[CGAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"No user with this Email", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                                        }];
    }
}

-(void)alertView:(CGAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString:NSLocalizedString(@"Sended", nil)])
        [self backAction:nil];
    
}

-(void)alertViewCancel:(CGAlertView *)alertView
{
    
}

- (IBAction)backAction:(id)sender {
   // if(isForgotPassMode)
        //[self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backgroundTapped:(id)sender {
    [self.view endEditing:YES];
}

-(void)showKeyboard:(NSNotification*) notification
{
    [UIView animateWithDuration:0.3f animations:^{
        [self.panelView setCenter:CGPointMake(160, 100)];
    }];
}

-(void)hideKeyboard:(NSNotification*) notification
{
    [UIView animateWithDuration:0.3f animations:^{
        [self.panelView setCenter:CGPointMake(160, 192)];
    }];
}



-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(isForgotPassMode)
    {
        [textField resignFirstResponder];
        [self changePassword:nil];
    }
    else
    {
        if(textField==self.oldPassField)
            [self.passField becomeFirstResponder];
        else if(textField==self.passField)
            [self.confirmPassField becomeFirstResponder];
        else
        {
            [textField resignFirstResponder];
            [self changePassword:nil];
        }
    }
    return YES;
}

@end
