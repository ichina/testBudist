//
//  DialogCell.h
//  iSaler
//
//  Created by Paul Semionov on 19.11.12.
//
//

#import <UIKit/UIKit.h>

#import "CustomCellForSelecting.h"

#import "LKBadgeView.h"
#import "Dialog.h"

@interface DialogMainCell : CustomCellForSelecting
{
    IBOutlet __weak UILabel *titleLabel;
    IBOutlet __weak UILabel *nameLabel;
    //IBOutlet __weak UILabel *messageLabel;
    IBOutlet __weak UILabel *dateLabel;
    
    __weak IBOutlet UIImageView *accessoryImageView;
    __weak IBOutlet UIImageView *itemFrame;
    __weak IBOutlet UIImageView *avatarFrame;
    IBOutlet __weak UIImageView *itemPicture;
    IBOutlet __weak UIImageView *avatarImageView;
    //IBOutlet __weak LKBadgeView *badge;
}

@property (nonatomic, weak) IBOutlet UILabel *messageLabel;

@property (nonatomic, weak) IBOutlet LKBadgeView *badge;

-(void)setDialogInfo:(Dialog*)dialog;

@end
