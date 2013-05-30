//
//  CustomCellForSelecting.h
//  iSaler
//
//  Created by Чина on 13.11.12.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum {
    CellPositionTop = 0,
    CellPositionMiddle,
    CellPositionBottom,
    CellPositionAlone
} CellPosition;

typedef enum {
    CellHighlightionDefault = 0,
    CellHighlightionNone
} CellHighlightionStyle;

@interface CustomCellForSelecting : UITableViewCell

@property (nonatomic, assign) CellPosition position;
@property (nonatomic, strong) UIImageView* backgroundImageView;
@property (nonatomic, strong) UIImageView* backgroundSelectedImageView;
@property (nonatomic, strong) UIImageView* separator;
@property (nonatomic, assign) CellHighlightionStyle highlightionStyle;

-(void) setProsition:(UITableView*) tableView withIndexPath:(NSIndexPath*) indexPath;

@end
