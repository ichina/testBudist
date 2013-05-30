//
//  CustomCellForSelecting.m
//  iSaler
//
//  Created by Чина on 13.11.12.
//
//

#import "CustomCellForSelecting.h"

@implementation CustomCellForSelecting

@synthesize position,backgroundImageView,backgroundSelectedImageView,separator,highlightionStyle;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        backgroundImageView = [[UIImageView alloc] initWithFrame:self.frame];
        [self addSubview:backgroundImageView];
        [self sendSubviewToBack:self.backgroundImageView];
        separator = [[UIImageView alloc] initWithFrame:self.frame];
        [self.separator setImage:[[UIImage imageNamed:@"profile_devider.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0,5,0,5)]];
        [self addSubview:separator];
        
        backgroundSelectedImageView = [[UIImageView alloc] initWithFrame:self.frame];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    
    
    [self sendSubviewToBack:self.backgroundImageView];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        backgroundImageView = [[UIImageView alloc] initWithFrame:self.frame];
        [self addSubview:backgroundImageView];
        
        separator = [[UIImageView alloc] initWithFrame:self.frame];
        [self.separator setImage:[[UIImage imageNamed:@"profile_devider.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0,5,0,5)]];
        [self addSubview:separator];
        
        backgroundSelectedImageView = [[UIImageView alloc] initWithFrame:self.frame];
    }
    return self;
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (self.highlightionStyle==CellHighlightionNone) {
        return;
    }
    
    if(highlighted)
    {
        [self insertSubview:backgroundSelectedImageView aboveSubview:self.backgroundImageView];
        [backgroundSelectedImageView setAlpha:0.0];
        [backgroundSelectedImageView setFrame:(self.position==CellPositionMiddle)?CGRectInset(backgroundImageView.frame, 2.5f, 0): backgroundImageView.frame];
        [UIView animateWithDuration:0.1f animations:^{
            [backgroundSelectedImageView setAlpha:1.0f];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.1f animations:^{
            backgroundSelectedImageView.alpha = 0;
        } completion:^(BOOL finished) {
            [backgroundSelectedImageView removeFromSuperview];
            //backgroundSelectedImageView = nil;
        }];
        return;
    }
    
    switch (self.position) {
        case CellPositionAlone:
            [self.backgroundSelectedImageView setImage:[[UIImage imageNamed:@"profile_alone_selected.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(15,15,15,15)]];
            break;
        case CellPositionTop:
            [self.backgroundSelectedImageView setImage:[[UIImage imageNamed:@"profile_top_selected.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(15,15,3,15)]];
            break;
        case CellPositionBottom:
            [self.backgroundSelectedImageView setImage:[[UIImage imageNamed:@"profile_bottom_selected.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(3,15,15,15)]];
            break;
        case CellPositionMiddle:
            [self.backgroundSelectedImageView setImage:[[UIImage imageNamed:@"profile_mid_selected.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(0,15,0,15)]];
            break;
    }
    
    
}

+ (CellPosition) positionForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    
    if ([tableView.dataSource tableView:tableView numberOfRowsInSection:indexPath.section] == 1) {
        return CellPositionAlone;
    }
    if (indexPath.row == 0) {
        return CellPositionTop;
    }
    if (indexPath.row+1 == [tableView.dataSource tableView:tableView numberOfRowsInSection:indexPath.section])
    {
        return CellPositionBottom;
    }
    
    return CellPositionMiddle;
}

-(void) setProsition:(UITableView*) tableView withIndexPath:(NSIndexPath*) indexPath
{
    self.position = [CustomCellForSelecting positionForTableView:tableView indexPath:indexPath];
    
    [self setFrameForComponentsWithPosition:self.position tableView:tableView];
    
    switch (self.position) {
        case CellPositionAlone:
            [self.backgroundImageView setImage:[[UIImage imageNamed:@"profile_alone.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(15,15,15,15)]];
            [self.backgroundImageView setFrame:CGRectMake(0, -5, 320, CGRectGetHeight(self.frame)+10)];
            break;
        case CellPositionTop:
            [self.backgroundImageView setImage:[[UIImage imageNamed:@"profile_top.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(15,15,3,15)]];
            [self.backgroundImageView setFrame:CGRectMake(0, -5, 320, CGRectGetHeight(self.frame)+(CGRectGetHeight(self.frame)==44?6:5))];
            break;
        case CellPositionBottom:
            [self.backgroundImageView setImage:[[UIImage imageNamed:@"profile_bottom.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(3,15,15,15)]];
            [self.backgroundImageView setFrame:CGRectMake(0, 0, 320, CGRectGetHeight(self.frame)+5)];
            break;
        case CellPositionMiddle:
            [self.backgroundImageView setImage:[[UIImage imageNamed:@"profile_mid.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(0,15,0,15)]];
            [self.backgroundImageView setFrame:CGRectMake(0, 0, 320, CGRectGetHeight(self.frame))];
        
            break;
    }

}

-(void) setFrameForComponentsWithPosition:(CellPosition)_position tableView:(UITableView*) tableView
{
    CGRect rect = self.frame;
    if(_position==CellPositionBottom || _position == CellPositionAlone)
    {
        [self.separator setHidden:YES];
        return;
    }
    else
    {
        [self.separator setHidden:NO];
        [self.separator setFrame:CGRectMake(2, rect.size.height-1, 316, 1)];
        //[self.separator setImage:[[UIImage imageNamed:@"profile_devider.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0,5,0,5)]];
    }
}



@end

