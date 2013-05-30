//
//  ProfileCell.h
//  iSeller
//
//  Created by Чина on 05.02.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCellForSelecting.h"

@interface ProfileCell : CustomCellForSelecting

@property (weak, nonatomic) IBOutlet UILabel *lblText;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end
