//
//  ProfileController.h
//  iSeller
//
//  Created by Чина on 18.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "BaseController.h"
#import "CGSocialManager.h"
#import "CGSwitch.h"
#import "CamOverlayController.h"

@interface ProfileController : BaseController <UITableViewDataSource, UITableViewDelegate,CGSocialManagerProtocol,CGSwitchDelegate, CamOverlayDelegate>
{
    CGSwitch* fbSwitch;
    CGSwitch* vkSwitch;
}
@property(nonatomic, strong) IBOutlet UITableView* tableView;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewBtnBG;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIButton *avatarBtn;
@property (nonatomic, retain) IBOutlet UIButton *logoutButton;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
- (IBAction)logout:(id)sender;
- (IBAction)inviteBtnClicked:(id)sender;
- (IBAction)goToProfileEdit:(id) sender;
- (IBAction)changeAvatar:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *inviteBtn;

@end
