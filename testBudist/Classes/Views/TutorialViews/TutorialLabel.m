//
//  TutorialLabel.m
//  iSeller
//
//  Created by Чингис on 28.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "TutorialLabel.h"

@implementation TutorialLabel

@synthesize label = _label;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _label = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, 250, 25)];
        [_label setTextAlignment:NSTextAlignmentLeft];
        _label.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        _label.textColor = [UIColor whiteColor];
        [_label setNumberOfLines:0];
        [_label setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_label];
        
        UIImageView *pointView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial_point_for_label.png"]];
        [pointView sizeToFit];
        [pointView setCenter:CGPointMake( 20 , 10)];
        [self addSubview:pointView];
    }
    return self;
}

-(void) setText:(NSString*)text
{
    [self.label setText:text];
    [self.label sizeToFit];
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.label.frame.size.height)];
}

@end
