//
//  ShareView.h
//  iSeller
//
//  Created by Чина on 16.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ShareViewDelegate;

@interface ShareView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) id <ShareViewDelegate> delegate;
@property (nonatomic, strong) UITableView* tableView;

-(void)socialPostingSucceded:(NSDictionary*) userInfo;
@end

@protocol ShareViewDelegate <NSObject>
@required
-(void)fbClicked;
-(void)twitterClicked;
-(void)emailClicked;
-(void)vkClicked;
@end