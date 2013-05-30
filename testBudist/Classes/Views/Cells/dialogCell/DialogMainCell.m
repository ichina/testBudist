//
//  DialogCell.m
//  iSaler
//
//  Created by Paul Semionov on 19.11.12.
//
//

#import "DialogMainCell.h"
#import "NSString+Extensions.h"

@implementation DialogMainCell

@synthesize messageLabel;

@synthesize badge;

-(void)awakeFromNib
{
    [super awakeFromNib];
    [badge setWidthMode:LKBadgeViewWidthModeStandard];
    [badge setHorizontalAlignment:LKBadgeViewHorizontalAlignmentCenter];
    [badge setBadgeColor:[UIColor colorWithRed:133.0/255 green:152.0/255 blue:173.0/255 alpha:1.0]];
}

-(void)setDialogInfo:(Dialog*)dialog
{
    if([dialog.incoming boolValue]) {
        [messageLabel setText:dialog.body];
    }else{
        
        [messageLabel setText:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Me", nil), dialog.body]];
    }
    [nameLabel setText:dialog.user.name];
    [titleLabel setText:dialog.ad.title];
    
    [dateLabel setText:[dialog.createdAt formatStringDateWithFormat:nil withTime:NO]];
    
    [self setTag:[[[dialog.ad.identifier stringValue] stringByAppendingString:[dialog.user.identifier stringValue]] integerValue]];

    
    if([dialog.freshCount integerValue]) {
        [badge setText:[NSString stringWithFormat:@"%@",dialog.freshCount]];
    }else{
        [badge setText:@""];
    }
    
    [avatarImageView setImageWithURL:[NSURL URLWithString:dialog.user.avatar] placeholderfileName:@"smile.png"];
    [itemPicture setImageWithURL:[NSURL URLWithString:dialog.ad.image] placeholderfileName:@"placeholder.png"];
}

@end
