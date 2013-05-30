//
//  TutorialPageView.m
//  iSeller
//
//  Created by Чингис on 28.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "TutorialPageView.h"
#import "TutorialImageView.h"
#import "TutorialLabel.h"

#define TITLE_TAG 150
@implementation TutorialPageView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)addTitle:(NSString*)title
{
    UILabel* lblTitle = (UILabel*)[self viewWithTag:TITLE_TAG];
    if(!lblTitle)
    {
        lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 7, 280, 35)];
        [lblTitle setTextAlignment:NSTextAlignmentCenter];
        lblTitle.font = [UIFont fontWithName:@"Lobster 1.4" size:25.f];
        lblTitle.textColor = [UIColor whiteColor];
        [lblTitle setNumberOfLines:0];
        [lblTitle setBackgroundColor:[UIColor clearColor]];
    }
    
    [lblTitle setText:title];
    [self addSubview:lblTitle];
    
    contentHeight+=(CGRectGetMaxY(lblTitle.frame)+10);
    
}

-(void)addMirroredImage:(NSString*)imageName
{
    UIImage* image = [UIImage imageNamed:imageName];

    TutorialImageView* tutorialImageView = [[TutorialImageView alloc] init];
    [tutorialImageView setFrame:CGRectMake(0, 0, image.size.width/(IS_RETINA?2:1), image.size.height/(IS_RETINA?2:1))];
    [tutorialImageView setTutorialImage:image];
    //[tutorialImageView sizeToFit];
    [tutorialImageView setCenter:CGPointMake(160, contentHeight+tutorialImageView.frame.size.height/2)];
    [self insertSubview:tutorialImageView atIndex:0];
    
    [self addShadowWithMirrorForImageView:tutorialImageView originaImage:image offset:0];
    
    contentHeight+=(CGRectGetHeight(tutorialImageView.frame) + 60);
}

-(void)addMirroredImage:(NSString*)imageName withGradientToTopOffset:(float)yOffset
{
    UIImage* image = [UIImage imageNamed:imageName];
    
    TutorialImageView* tutorialImageView = [[TutorialImageView alloc] init];
    [tutorialImageView setFrame:CGRectMake(0, 0, image.size.width/(IS_RETINA?2:1), image.size.height/(IS_RETINA?2:1))];
    [tutorialImageView setTutorialImage:image withGradientToTopOffset:yOffset];
    //[tutorialImageView sizeToFit];
    [tutorialImageView setCenter:CGPointMake(160, contentHeight+tutorialImageView.frame.size.height/2)];
    [self insertSubview:tutorialImageView atIndex:0];
    
    [self addShadowWithMirrorForImageView:tutorialImageView originaImage:image offset:yOffset];
    
    contentHeight+=(CGRectGetHeight(tutorialImageView.frame) + 60);
}

-(void)addLabel:(NSString* ) text
{    
    TutorialLabel* lblText = [[TutorialLabel alloc] initWithFrame:CGRectMake(0, contentHeight, 320, 25)];
    
    [lblText setText:text];
    [self addSubview:lblText];
    
    contentHeight+=CGRectGetHeight(lblText.frame)+5;
}

-(void) addShadowWithMirrorForImageView:(TutorialImageView*)tutorialImageView originaImage:(UIImage*)image offset:(float) offset
{
    
    tutorialImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    //imageView.layer.shadowOffset = CGSizeMake(0, 10);
    [tutorialImageView.layer setShadowOpacity:0.7];
    [tutorialImageView.layer setShadowRadius:7.0];
    tutorialImageView.clipsToBounds = NO;
    CGRect rect = CGRectMake(-5, -5, tutorialImageView.frame.size.width+10, tutorialImageView.frame.size.height+10);
    if(offset!=0)
    {
        rect.origin.y += (offset+tutorialImageView.frame.size.height/3);
        rect.size.height -= (offset+tutorialImageView.frame.size.height/3);
    }
    
    tutorialImageView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:7].CGPath;
    
    TutorialImageView* mirroredImageView = [[TutorialImageView alloc] init];

    [mirroredImageView setFrame:CGRectMake(0, 0, image.size.width/(IS_RETINA?2:1), image.size.height/(IS_RETINA?2:1))];
    [mirroredImageView setCenter:CGPointMake(tutorialImageView.center.x, tutorialImageView.center.y+image.size.height/(IS_RETINA?2:1)+10)];
    [mirroredImageView setMirrorImage:image];
    [self addSubview:mirroredImageView];
}

-(void)addContentOffset:(float)offset
{
    contentHeight+=offset;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
