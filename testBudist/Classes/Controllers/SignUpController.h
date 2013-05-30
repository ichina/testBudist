//
//  SignUpController.h
//  iSeller
//
//  Created by Чина on 28.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "BaseController.h"

#import "LoaderView.h"

@interface SignUpController : BaseController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)singUP:(id)sender;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem2;
- (IBAction)backTapped:(id)sender;

@end
