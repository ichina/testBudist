//
//  MessagesControllerViewController.h
//  iSeller
//
//  Created by Чина on 17.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "BaseController.h"
#import "Dialog.h"
#import "MessagesDataSource.h"
#import "HPGrowingTextView.h"

@interface MessagesController : BaseController <UITableViewDelegate,HPGrowingTextViewDelegate,UIScrollViewDelegate>
{
    MessagesDataSource* messagesDataSource;
    BOOL isDataLoading;
    BOOL needScrollToBottom;
    
    UIView *containerView;
    HPGrowingTextView *textView;
    UIButton *sendBtn;
}
@property (nonatomic,weak) IBOutlet UITableView* tableView;
@property (nonatomic,strong) Dialog* dialog;

@end
