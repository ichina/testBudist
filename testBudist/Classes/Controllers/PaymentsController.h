//
//  PaymentHistory.h
//  iSeller
//
//  Created by Чина on 24.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "BaseController.h"

@interface PaymentsController : BaseController <UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *balanceImageView;
@property (weak, nonatomic) IBOutlet UILabel *lblBalance;
@property (weak, nonatomic) IBOutlet UIView *headerView;

- (IBAction)goToPurchase:(id)sender;
@end
