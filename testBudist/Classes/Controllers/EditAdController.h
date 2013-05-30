//
//  EditAdController.h
//  iSeller
//
//  Created by Чина on 31.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "BaseController.h"
#import "CamOverlayController.h"
#import "PhotoItem.h"
#import "Advertisement.h"

@interface EditAdController : BaseController<UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,CamOverlayDelegate,PhotoItemDelegate, UIScrollViewDelegate>
{
    NSMutableArray* attachments;
    NSMutableArray* oldImages;
    NSArray* enabledStatuses;
    int selectedStatus;
    
    int index;
    NSNumber* mainImg;
    BOOL isPhotoItemsAnimated;
    BOOL descCellEdited;
}
@property (nonatomic, strong) Advertisement* ad;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
- (IBAction)takePhoto:(id)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *horizontalScrollView;
@end

