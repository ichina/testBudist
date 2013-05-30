//
//  ViewForViewerCell.h
//  seller
//
//  Created by Чингис on 12.10.12.
//
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "CustomCellForSelecting.h"
@interface ViewForViewerCell : CustomCellForSelecting

@property(nonatomic, strong) UIImageView* iconView;
@property(nonatomic, strong) UILabel* lblTitle;
@property(nonatomic, strong) UILabel* lblSubtitle;


@end
