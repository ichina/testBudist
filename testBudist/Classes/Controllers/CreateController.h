//
//  CreateController.h
//  iSeller
//
//  Created by Чина on 21.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "BaseController.h"
#import "CamOverlayController.h"
#import "PhotoItem.h"

#import <MBProgressHUD/MBProgressHUD.h>

#import "GeoPickerController.h"
#import "CGSocialManager+FBcom.h"
#import "CGSocialManager+VKcom.h"

@interface CreateController : BaseController <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,CamOverlayDelegate,PhotoItemDelegate, UIScrollViewDelegate, CGAlertViewDelegate, GeoPickerControllerDelegate, CGSocialManagerProtocol, MBProgressHUDDelegate>
{
    NSMutableArray* attachments;
    int index;
    BOOL isPhotoItemsAnimated;
    __weak IBOutlet UIImageView *topImageView;
    __weak IBOutlet UISwitch *topSwitch;
    NSString* idOfLastCreatedAd;
    BOOL descCellEdited;
    NSString* descText;
    int socialCount; //количество социалок включеных в создание для постинга
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
- (IBAction)takePhoto:(id)sender;
- (IBAction)cancel:(id) sender;
-(IBAction)create:(id)sender;

@property (weak, nonatomic) IBOutlet UIScrollView *horizontalScrollView;

@end
