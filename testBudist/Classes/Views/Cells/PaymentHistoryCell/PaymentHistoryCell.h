//
//  PaymentHistoryCell.h
//  iSaler
//
//  Created by Чина on 01.11.12.
//
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Payment.h"
#import "CustomCellForSelecting.h"
@interface PaymentHistoryCell : CustomCellForSelecting
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *type;
@property (weak, nonatomic) IBOutlet UILabel *mount;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;

-(void)setPaymentInfo:(Payment*) payment;

@end
