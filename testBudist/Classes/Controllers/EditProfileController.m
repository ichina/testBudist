//
//  EditProfileController.m
//  iSeller
//
//  Created by Чина on 24.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "EditProfileController.h"
#import "UIImage+scale.h"
#import "Profile.h"
#import "ProfileCell.h"
#import "UIView+Extensions.h"
#import "PassManageController.h"
#import "LoaderView.h"
#import "NSString+Extensions.h"

#import <MBProgressHUD.h>

@interface EditProfileController ()

@end

@implementation EditProfileController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController setHidden:YES animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.frameOfAvatar setFrame:CGRectMake(self.frameOfAvatar.frame.origin.x, self.frameOfAvatar.frame.origin.y, 86, 86)];
        
    [self.avatarBtn setImage:[[[Profile sharedProfile] avatarImage] roundCornerImageWithWidth:7 height:7] forState:UIControlStateNormal];
    if(!self.avatarBtn.imageView.image)
    {
        [self.avatarBtn.imageView setImageWithURL:[NSURL URLWithString:[[Profile sharedProfile] avatar] ] placeholderfileName:@"smile.png"];
    }

    [self.tableView setRowHeight:44];
    self.name.text = [[Profile sharedProfile] name];
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width, IS_IPHONE5 ? 508 : 418)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setFrameOfAvatar:nil];
    [self setTableView:nil];
    [self setScrollView:nil];
    [self setName:nil];
    [self setAvatarBtn:nil];
    [super viewDidUnload];
}

#pragma mark - TableViewDataSource Method's

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section ? 2 : 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProfileCell* cell = (ProfileCell*)[tableView dequeueReusableCellWithIdentifier:@"EditProfileCell"];
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setProsition:tableView withIndexPath:indexPath];
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell.lblText.text = NSLocalizedString(@"Email", nil);
                    cell.textField.text = [[Profile sharedProfile] contactEmail] ? [[Profile sharedProfile] contactEmail] : @"" ;
                    [cell.textField setKeyboardType:UIKeyboardTypeEmailAddress];
                    [cell.textField setDelegate:self];
                    
                    break;
                case 1:
                    cell.lblText.text = NSLocalizedString(@"Phone", nil);
                    cell.textField.text = [[Profile sharedProfile] phone] ? [[Profile sharedProfile] phone] : @"" ;
                    [cell.textField setKeyboardType:UIKeyboardTypePhonePad];
                    
                    break;
                case 2:
                    cell.lblText.text = @"Skype";
                    cell.textField.text = [[Profile sharedProfile] skype] ? [[Profile sharedProfile] skype] : @"" ;
                    [cell.textField setKeyboardType:UIKeyboardTypeAlphabet];
                    
                    break;
            }
            break;
        case 1:
            if(indexPath.row==1)
            {
                cell.lblText.text = NSLocalizedString(@"Change password", nil);
                [cell.textField removeFromSuperview];
                [cell setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dialog_accessory.png"]]];
            }
            else
            {
                cell.lblText.text = NSLocalizedString(@"Email", nil);
                cell.textField.text = [[Profile sharedProfile] email] ? [[Profile sharedProfile] email] : @"" ;
                [cell.textField setKeyboardType:UIKeyboardTypeEmailAddress];
                [cell.textField setDelegate:self];
                //[cell setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dialog_accessory.png"]]];
            }
            break;
    }
    [cell.textField setDelegate:self];
    [cell setHighlightionStyle:(indexPath.section==1 && indexPath.row==1)?CellHighlightionDefault: CellHighlightionNone];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section==1 && indexPath.row==1)
    {
        
        [self sendEventWithCategory:@"EditProfile" action:@"Manage password button pressed" label:@"" value:nil];
        
        PassManageController* passController = [self.storyboard instantiateViewControllerWithIdentifier:@"PassManageController"];
        passController.isForgotPassMode = NO;
        [self.navigationController pushViewController:passController animated:YES];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section)
    {
        return NSLocalizedString(@"Access to account", nil);
    }
    else
        return NSLocalizedString(@"Contacts", nil);
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = [self tableView:self.tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 8, 320, 20);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];//[UIColor colorWithRed:188.0f/255.0f green:196.0f/255.0f blue:203.0f/255.0f alpha:1.0f];
    label.shadowColor = [UIColor colorWithWhite:0 alpha:0.75f];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.font = [UIFont boldSystemFontOfSize:17];
    label.text = sectionTitle;
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor clearColor]];
    return view;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self.view commitAnimationsBlock:^{
        [self.scrollView setContentOffset:CGPointMake(0,-[textField convertPoint:textField.frame.origin fromView:self.scrollView ].y-40.0f)];
    }];
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)keyboardWillHide:(NSNotification*)notification
{
    if(CGRectGetMaxY(self.scrollView.bounds) > self.scrollView.contentSize.height)
        [self.view commitAnimationsBlock:^{
            [self.scrollView setContentOffset:CGPointMake(0, 0)];//self.scrollView.contentSize.height - CGRectGetHeight(self.scrollView.bounds))];
        }];
}

-(IBAction)applyChanges:(id)sender
{
    
    [self sendEventWithCategory:@"EditProfile" action:@"Apply button pressed" label:@"" value:nil];
    
    [[self.view findFirstResponder] resignFirstResponder];
    
    [self.view commitAnimationsBlock:^{
        [self.scrollView setContentOffset:CGPointMake(0, 0)];//self.scrollView.contentSize.height - CGRectGetHeight(self.scrollView.bounds))];
    }];
    
    NSMutableArray* array = [NSMutableArray new];
    for(int i = 0 ; i < 3 ; i++)
        [array addObject:((ProfileCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]]).textField.text];
    
    NSMutableDictionary* dict = [NSMutableDictionary new];
    //if (((NSString*)array[0]).length)
        [dict setObject:array[0] forKey:@"contact_email"];
    
    //if (((NSString*)array[1]).length)
        [dict setObject:array[1] forKey:@"phone"];
    
    //if (((NSString*)array[2]).length)
        [dict setObject:array[2] forKey:@"skype"];
    if (self.name.text.length)
        [dict setObject:self.name.text forKey:@"name"];
    
    //имейл для авторизации
    NSString* email = ((ProfileCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]).textField.text;
    if(email.length)
        [dict setObject:email forKey:@"email"];
    
    NSMutableArray* errorFields = [@[] mutableCopy];
    if(![email isValidEmail])
        [errorFields addObject:NSLocalizedString(@"Email",nil)];
    if([(NSString*)dict[@"contact_email"] length] && ![(NSString*)dict[@"contact_email"] isValidEmail])
        [errorFields addObject:NSLocalizedString(@"Contact Email", nil)];
    
    if(errorFields.count>0)
    {
        [[[CGAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) message:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Not valid:", nil),[errorFields componentsJoinedByString:@","]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    
    if (isAvatarDidChange)
        [dict setObject:self.avatarBtn.imageView.image forKey:@"avatar"];
    
    if (dict.allKeys.count) {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [hud setSquare:YES];
        [hud setMinSize:CGSizeMake(126, 126)];
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [[LoaderView alloc] initWithMode:loaderViewModeDeterminate];
        [(LoaderView*)hud.customView startAnimating];
        [(LoaderView*)hud.customView setProgress:0];
        hud.labelText = NSLocalizedString(@"Uploading...", nil);
        hud.delegate = self;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hudDidTapped:)];
        [tapGesture setNumberOfTapsRequired:2];
        [hud addGestureRecognizer:tapGesture];
        
        [[Profile sharedProfile] updateProfileWithParams:dict progress:^(float progress) {
            
            if(isAvatarDidChange) {
            
                [(LoaderView*)hud.customView setProgress:progress];
                
                if(progress == 1) {
                    
                    hud.customView = [[LoaderView alloc] initWithMode:loaderViewModeIndeterminate];
                    hud.labelText = NSLocalizedString(@"Waiting...", nil);
                    
                }
            }
            
        } success:^{
            
            hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"success.png"]];
            hud.labelText = NSLocalizedString(@"Success", nil);
            
            [hud setTag:1];
            
            [hud hide:YES afterDelay:1];
                        
            [[Profile sharedProfile] setAvatarImage:self.avatarBtn.imageView.image];
                        
        } failure:^(NSError *error) {
            
            hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
            hud.labelText = NSLocalizedString(@"Failed", nil);
            
            [hud setTag:0];
            
            [hud hide:YES afterDelay:1];
            
        }];
    }
    else
    {
        NSLog(@"все поля пустые");
    }
}

- (IBAction)takeAvatar:(id)sender {
    
    [self sendEventWithCategory:@"EditProfile" action:@"Change avatar button pressed" label:@"" value:nil];
    
    [self performSegueWithIdentifier:kSegueFromEditProfileToCamOverlay sender:self];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:kSegueFromEditProfileToCamOverlay])
    {
        [((CamOverlayController*)segue.destinationViewController) setIndex:-1];
        [(CamOverlayController*)segue.destinationViewController setDelegate:self];
    }
}

#pragma mark - CamOverlayDelegate

-(void)imagePickerControllerDidCancel:(CamOverlayController *)picker
{
    
}

-(void)imagePickerController:(CamOverlayController *)picker didFinishPickingMediaWithInfo:(NSMutableDictionary *)info
{
    UIImage* editedImage = [info objectForKey:@"editedImage"];
    
    [self.avatarBtn setImage:[[editedImage imageByScalingAndCroppingForSize:CGSizeMake(150, 150)]roundCornerImageWithWidth:7 height:7] forState:UIControlStateNormal];
    isAvatarDidChange = YES;
    [picker dismissModalViewControllerAnimated:YES];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    
    if(hud.tag == 1) {
        
        [self.navigationController popViewControllerAnimated:YES];

        hud.tag = 0;
        
    }
    
}

-(void)hudDidTapped:(UIGestureRecognizer*)gesture
{
    
}

@end
