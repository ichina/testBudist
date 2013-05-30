//
//  ViewForViewerCell.m
//  seller
//
//  Created by Чингис on 12.10.12.
//
//

#import "ViewForViewerCell.h"

@implementation ViewForViewerCell
@synthesize iconView,lblSubtitle,lblTitle;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initial];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initial];
    }
    return self;
}

-(void)initial
{
    // Initialization code
    iconView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 30, 30)];
    [iconView setContentMode:UIViewContentModeScaleAspectFit];
    [iconView setCenter:CGPointMake(iconView.center.x,self.frame.size.height/2)];
    lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(55, 15, 200, 17)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17]];
    [lblTitle setCenter:CGPointMake(lblTitle.center.x,self.frame.size.height/2)];
    
    [self addSubview:iconView];
    [self addSubview:lblTitle];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
