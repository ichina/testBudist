//
//  ContactsView.h
//  iSeller
//
//  Created by Чина on 16.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Advertisement.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@protocol ContactsViewDelegate;

@interface ContactsView : UIView <UITableViewDataSource,UITableViewDelegate,MFMailComposeViewControllerDelegate,CGAlertViewDelegate>

@property(nonatomic,strong) UITableView* tableView;
@property(nonatomic,strong) NSMutableDictionary* contactInfo;
@property (nonatomic, retain) id <ContactsViewDelegate> delegate;

-(void)setContactInfoWithAd:(Advertisement*) ad;

@end

@protocol ContactsViewDelegate <NSObject>
@optional
-(void)descriptionBtnClicked;
@end
