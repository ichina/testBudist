//
//  PaymentHistoryCell.m
//  iSaler
//
//  Created by Чина on 01.11.12.
//
//

#import "PaymentHistoryCell.h"
#import "NSString+Extensions.h"

@implementation PaymentHistoryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setPaymentInfo:(Payment*) payment;
{
    self.date.text = [payment.createdAt formatStringDateWithFormat:@"HH:mm dd MMM yyyy" withTime:YES];

    self.mount.text = [payment.amount stringValue];
    if(self.mount.text.intValue<=0)
    {
        //[self.mount setTextColor:[UIColor colorWithRed:216.0f/255.0f green:34.0f/255.0f blue:45.0f/255.0f alpha:1.0f]];
        //self.type.text = payment.device;
        [self.iconView setImage:[UIImage imageNamed:@"profile_addToTop_icon.png"]];
        self.type.text = payment.data[@"ad_title"];
        self.mount.textColor = [UIColor colorWithRed:153.0f/255 green:191.0f/255 blue:1.0f/255 alpha:1.0];
    }
    else
    {
        //[self.mount setTextColor:[UIColor colorWithRed:148.0f/255.0f green:200.0f/255.0f blue:24.0f/255.0f alpha:1.0f]];
        self.type.text =  @"Пополнение cчета";
        [self.iconView setImage:[UIImage imageNamed:@"profile_purchase_icon.png"]];
        self.mount.textColor = [UIColor colorWithRed:255.0f/255 green:184.0f/255 blue:33.0f/255 alpha:1.0];
    }
    
}

@end
