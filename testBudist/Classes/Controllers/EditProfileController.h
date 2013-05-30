//
//  EditProfileController.h
//  iSeller
//
//  Created by Чина on 24.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "BaseController.h"
#import "CamOverlayController.h"

@interface EditProfileController : BaseController <UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate,CamOverlayDelegate, MBProgressHUDDelegate>
{
    BOOL isAvatarDidChange;
}
@property (weak, nonatomic) IBOutlet UIImageView *frameOfAvatar;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *avatarBtn;

@end
