//
//  ProfileController.m
//  iSeller
//
//  Created by Чина on 18.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "ProfileController.h"
#import "CustomCellForSelecting.h"
#import "Profile.h"
#import "UIImage+scale.h"
#import "NSString+Extensions.h"

#import "MyItemsController.h"

#define avatarTag  10
#define nameTag 11
#define cityTag 12

#define FB_SHARE_TAG 55
#define VK_SHARE_TAG 57

@interface ProfileController ()

@end

@implementation ProfileController
@synthesize tableView = _tableView;

@synthesize logoutButton;

static int profileNameObservanceContext;
static int profileImageObservanceContext;
static int profileBalanceObservanceContext;

static int profileSocialAttachingObservanceContext;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [[Profile sharedProfile] addObserver:self forKeyPath:@"name" options:0 context:&profileNameObservanceContext];
        [[Profile sharedProfile] addObserver:self forKeyPath:@"avatarImage" options:0 context:&profileImageObservanceContext];
        [[Profile sharedProfile] addObserver:self forKeyPath:@"authProviders" options:0 context:&profileSocialAttachingObservanceContext];
        [[Profile sharedProfile] addObserver:self forKeyPath:@"balance" options:0 context:&profileBalanceObservanceContext];

    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController setHidden:NO animated:YES];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHINAS_NOTIFICATION_SOCIAL_ACCESS_TOKEN_RECEIVED object:[CGSocialManager sharedSocialManager]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessTokenReceived:) name:CHINAS_NOTIFICATION_SOCIAL_ACCESS_TOKEN_RECEIVED object:[CGSocialManager sharedSocialManager]];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHINAS_NOTIFICATION_SOCIAL_ACCESS_TOKEN_RECEIVED object:[CGSocialManager sharedSocialManager]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    //[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:BG_TEXTURE_IMAGE]]];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:BG_IMAGE]]];
    
    [self.imageViewBtnBG setImage:[[UIImage imageNamed:@"payCoinBtnsBg.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:20]];
    [self.scrollView setBounces:YES];
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, IS_IPHONE5 ? self.scrollView.frame.size.height : self.scrollView.frame.size.height + 63)];// CGSizeMake(320, 300)];
    self.lblName.text = [[Profile sharedProfile] name];
    [self.avatarBtn setImage:[[[Profile sharedProfile] avatarImage] roundCornerImageWithWidth:7 height:7] forState:UIControlStateNormal];
    
    UIImageView* imageView = (UIImageView*)[self.scrollView viewWithTag:50];
    [imageView setImage:[imageView.image resizableImageWithCapInsets:UIEdgeInsetsMake(15, 0, 15, 0)]];
    
    [self.logoutButton setBackgroundImage:[[UIImage imageNamed:@"auth_sign_in.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)] forState:UIControlStateNormal];
    [self.logoutButton setBackgroundImage:[[UIImage imageNamed:@"auth_sign_in_sel.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)] forState:UIControlStateHighlighted];
    
    fbSwitch = [[CGSwitch alloc] initWithToggleImage:[UIImage imageNamed:@"switch_fb.png"] sliderImage:[UIImage imageNamed:@"switch_slider.png"]];
    [fbSwitch setCenter:CGPointMake(64, imageView.center.y)];
    [fbSwitch setTag:FB_SHARE_TAG];
    [self.scrollView addSubview:fbSwitch];
    [fbSwitch setDelegate:self];
    
    vkSwitch = [[CGSwitch alloc] initWithToggleImage:[UIImage imageNamed:@"switch_vk.png"] sliderImage:[UIImage imageNamed:@"switch_slider.png"]];
    [vkSwitch setCenter:CGPointMake(160, imageView.center.y)];
    [vkSwitch setTag:VK_SHARE_TAG];
    [self.scrollView addSubview:vkSwitch];
    [vkSwitch setDelegate:self];
    
    [vkSwitch setON:[[Profile sharedProfile] vkAttached] duration:0];
    [fbSwitch setON:[[Profile sharedProfile] fbAttached] duration:0];
    [vkSwitch setUserInteractionEnabled:![[Profile sharedProfile] vkAttached]];
    [fbSwitch setUserInteractionEnabled:![[Profile sharedProfile] fbAttached]];
    [self resizeleftNavItem];
    
}



#pragma mark - TableViewDataSource Method's

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCellForSelecting *cell;// = (CustomCellForSelecting*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    switch (indexPath.row) {
        case 0:
            cell = (CustomCellForSelecting*)[tableView dequeueReusableCellWithIdentifier:@"ProfileItemCell"];
            cell.textLabel.text = NSLocalizedString(@"My Items", nil);
                        
            break;
        case 1:
        {
            cell = (CustomCellForSelecting*)[tableView dequeueReusableCellWithIdentifier:@"ProfileBalanceCell"];
            
            NSString* coins = [NSLocalizedString(@"locale", nil) isEqualToString:@"en"]?@"coins":[[[[Profile sharedProfile] balance] stringValue] rusSklonenieCoins];
            
            cell.detailTextLabel.text = [[[[[Profile sharedProfile] balance] stringValue] stringByAppendingString:@" "] stringByAppendingString:coins];
        }
            break;
        default:
            break;
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setProsition:tableView withIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [cell setAccessoryView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dialog_accessory.png"]]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
            [self sendEventWithCategory:@"Profile" action:@"My items button pressed" label:@"" value:nil];
            [self goToMyItems];
            break;
        case 1:
            [self sendEventWithCategory:@"Profile" action:@"Payments button pressed" label:@"" value:nil];
            [self goToPaymentSetting];
            break;
            
    }
}

-(IBAction)goToProfileEdit:(id) sender
{
    [self performSegueWithIdentifier:kSegueFromProfileToEdit sender:nil];
}

- (IBAction)changeAvatar:(id)sender {
    
    [self sendEventWithCategory:@"Profile" action:@"Change avatar button pressed" label:@"" value:nil];
    
    [self performSegueWithIdentifier:kSegueFromProfileToCamOverlay sender:nil];
}

-(void)goToMyItems
{
    [self performSegueWithIdentifier:kSegueFromProfileToMyItems sender:nil];
}

-(void)goToPaymentSetting
{
    [self performSegueWithIdentifier:kSegueFromProfileToPaymentHistory sender:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:kSegueFromProfileToMyItems])
    {
        for(NSDictionary *image in sender) {
            
            for(NSString *key in [image allKeys]) {
                
                if([key isEqualToString:@"main_image"]) {
                    
                    [((MyItemsController*)segue.destinationViewController) setJustCreatedImage:image];
                    break;
                    
                }
                
            }
            
        }
        
        if(!((MyItemsController*)segue.destinationViewController).justCreatedImage) {
            
            [((MyItemsController*)segue.destinationViewController) setJustCreatedImage:[sender objectAtIndex:0]];
            
        }

    }
    if([segue.identifier isEqualToString:kSegueFromProfileToPaymentHistory])
    {
        return;
    }
    if([segue.identifier isEqualToString:kSegueFromProfileToCamOverlay])
    {
        [((CamOverlayController*)segue.destinationViewController) setIndex:-1];
        [(CamOverlayController*)segue.destinationViewController setDelegate:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)logout:(id)sender {
    
    [self sendEventWithCategory:@"Profile" action:@"Logout button pressed" label:@"" value:nil];
    
    [[Profile sharedProfile] logout];
    [self authorizeWithAlert:NO animated:YES block:nil];
    //[self.tabBarController setSelectedIndex:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_USER_DID_LOGOUT object:nil];
}

- (IBAction)inviteBtnClicked:(id)sender {
    
    [self sendEventWithCategory:@"Profile" action:@"Invite friends button pressed" label:@"" value:nil];
    
    //[[CGSocialManager sharedSocialManager] setDelegate:self];
    //[[CGSocialManager sharedSocialManager] tryOpenSessionFB:inviteFriendFromFB];
    [self performSegueWithIdentifier:kSegueFromProfileToFriendPicker sender:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(context==&profileImageObservanceContext)
    {
        [self.avatarBtn setImage:[[[Profile sharedProfile] avatarImage] roundCornerImageWithWidth:7 height:7] forState:UIControlStateNormal];
        
    } else if (context==&profileNameObservanceContext)
    {
        [self.lblName setText:[[Profile sharedProfile] name]];
        
    } else if (context==&profileSocialAttachingObservanceContext)
    {
        [vkSwitch setON:[[Profile sharedProfile] vkAttached] duration:0];
        [vkSwitch setUserInteractionEnabled:![[Profile sharedProfile] vkAttached]];
        
        [fbSwitch setON:[[Profile sharedProfile] fbAttached] duration:0];
        [fbSwitch setUserInteractionEnabled:![[Profile sharedProfile] fbAttached]];

    }else if (context==&profileBalanceObservanceContext) {
        
        NSString* coins = [NSLocalizedString(@"locale", nil) isEqualToString:@"en"]?@"coins":[[[[Profile sharedProfile] balance] stringValue] rusSklonenieCoins];
        
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]].detailTextLabel.text = [[[[[Profile sharedProfile] balance] stringValue] stringByAppendingString:@" "] stringByAppendingString:coins];
        
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];

    }
    
    else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

-(void)CGSwitch:(CGSwitch *)cgSwitch valueChanged:(BOOL)isOn
{
    if(isOn)
    {
        if(cgSwitch==vkSwitch && ![[Profile sharedProfile] vkAttached])
        {
            [self sendEventWithCategory:@"Profile" action:@"Attach VKontakte profile button pressed" label:@"" value:nil];
            
            [[CGSocialManager sharedSocialManager] authWithVKWithView:([UIApplication sharedApplication].delegate).window];
            return;
        }
        if(cgSwitch==fbSwitch && ![[Profile sharedProfile] fbAttached])
        {
            
            [self sendEventWithCategory:@"Profile" action:@"Attach Facebook profile button pressed" label:@"" value:nil];
            
            [[CGSocialManager sharedSocialManager] authWithFacebook];
            return;
        }
            
    }
    else
        [cgSwitch setUserInteractionEnabled:YES];
}

-(void)resizeleftNavItem
{
    UIButton* btn = (UIButton*)self.navigationItem.leftBarButtonItem.customView;
    [btn setBackgroundImage:[[UIImage imageNamed:@"sale_navbar_filter.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)] forState:UIControlStateNormal];
}

-(void)accessTokenReceived:(NSNotification*) notification
{
    [[Profile sharedProfile] authorizeUserWithSocialToken:notification.userInfo[@"token"] provider:notification.userInfo[@"provider"] success:^{
        
    } failure:^(NSError *error) {
        [vkSwitch setON:NO duration:1];
    }];
}

- (void)viewDidUnload {
    
    [self setImageViewBtnBG:nil];
    [self setInviteBtn:nil];
    [self setScrollView:nil];
    [self setLblName:nil];
    [self setLblName:nil];
    [self setAvatarBtn:nil];
    [super viewDidUnload];
    
}

#pragma mark - CamOverlayDelegate
-(void)imagePickerControllerDidCancel:(CamOverlayController *)picker
{
    
}

-(void)imagePickerController:(CamOverlayController *)picker didFinishPickingMediaWithInfo:(NSMutableDictionary *)info
{
    UIImage* editedImage = [info objectForKey:@"editedImage"];
    
    [[Profile sharedProfile] setAvatarImage:[editedImage imageByScalingAndCroppingForSize:CGSizeMake(150, 150)]];
    [picker dismissModalViewControllerAnimated:YES];
    
    [[Profile sharedProfile] updateProfileWithParams:@{@"avatar": self.avatarBtn.imageView.image} progress:nil success:nil failure:nil];
}

@end
