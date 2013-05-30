//
//  DescriptionView.m
//  iSeller
//
//  Created by Чина on 15.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "DescriptionView.h"
#import "CustomCellForSelecting.h"

#define DEFAULT_CELL_SUMM_HEIGHT 100

@implementation DescriptionView
@synthesize btnToDialog;
@synthesize description,lblTitle;
@synthesize delegate = _delegate;

static int descFrameObservanceContext;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialSetting];
    }
    return self;
}

-(void)initialSetting
{

    lblTitle = [[UILabel alloc]  initWithFrame:CGRectMake(18, 15, 284, 21)];
    [lblTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0f]];
    [lblTitle setLineBreakMode:NSLineBreakByCharWrapping];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setNumberOfLines:0];
    [lblTitle setTextColor:[UIColor whiteColor]];
    
    
    description = [[UITextView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(lblTitle.frame)+10, 300, 21)];
    [description setFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0f]];
    [description setEditable:NO];
    [description setScrollEnabled:NO];
    [description setBackgroundColor:[UIColor clearColor]];
    [description setTextColor:[UIColor whiteColor]];
    
    UIImage* image = [UIImage imageNamed:@"profile_logout.png"];
    self.goToDialogBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.goToDialogBtn setBackgroundImage:image forState:UIControlStateNormal];
    [self.goToDialogBtn setTitle:@"Купить" forState:UIControlStateNormal];
    [self.goToDialogBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.goToDialogBtn setTitleShadowColor:[UIColor colorWithWhite:1 alpha:0.7f] forState:UIControlStateNormal];
    self.goToDialogBtn.titleLabel.shadowOffset = CGSizeMake(0, 1);
    self.goToDialogBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    [self.goToDialogBtn setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [self.goToDialogBtn setCenter:CGPointMake(self.center.x, self.center.y-230)];
    [self addSubview:self.goToDialogBtn];
    [self bringSubviewToFront:self.goToDialogBtn];
    
    //self.cellImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 300, 105)];
    self.cellImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 125)];

    [self.cellImageView setImage:[[UIImage imageNamed:@"profile_alone.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)]];
    [self addSubview:self.cellImageView];
    [self.cellImageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellDidTapped:)];
    [self.cellImageView addGestureRecognizer:tap];
    tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellDidTapped:)];
    [self.description addGestureRecognizer:tap2];
    
    [self addSubview:lblTitle];
    [self addSubview:description];
    
    [self.description addObserver:self forKeyPath:@"frame" options:0 context:&descFrameObservanceContext];
}
-(void) setDelegate:(id<DescriptionViewDelegate>)delegate
{
    [self.goToDialogBtn addTarget:delegate action:@selector(descriptionBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    _delegate = delegate;
}
-(void) setTitle:(NSString*) title andDescription:(NSString*) desc
{
    [lblTitle setText:title];
    [description setText:desc];
    
    [lblTitle sizeToFit];
    [lblTitle setFrame:CGRectMake(CGRectGetMinX(lblTitle.frame), CGRectGetMinY(lblTitle.frame), 284, CGRectGetHeight(lblTitle.frame))];
    
    if((description.contentSize.height + CGRectGetMaxY(lblTitle.frame) <= DEFAULT_CELL_SUMM_HEIGHT) && desc)
    {
        if(self.cellImageView.gestureRecognizers && self.cellImageView.gestureRecognizers.count)
            [self.cellImageView removeGestureRecognizer:[[self.cellImageView gestureRecognizers]lastObject]];
        if(tap2)
            [description removeGestureRecognizer:tap2];
        tap2=nil;
    }
    int descHeight = (description.contentSize.height + CGRectGetMaxY(lblTitle.frame) > DEFAULT_CELL_SUMM_HEIGHT) ? DEFAULT_CELL_SUMM_HEIGHT - CGRectGetMaxY(lblTitle.frame) : description.contentSize.height;
    [description setFrame:CGRectMake(10, CGRectGetHeight(lblTitle.frame)+10, 300, descHeight)];
        
    if(![self viewWithTag:ACTIVITY_INDICATOR_TAG])
    {
        if(!desc) {
            UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            activityIndicator.hidesWhenStopped = YES;
            [activityIndicator setCenter:CGPointMake(CGRectGetMidX(self.frame) , CGRectGetMaxY(lblTitle.frame)+10)];
            [self addSubview:activityIndicator];
            [activityIndicator setTag:ACTIVITY_INDICATOR_TAG];
            [activityIndicator startAnimating];
        }
    }
    else
    {
        [(UIActivityIndicatorView*)[self viewWithTag:ACTIVITY_INDICATOR_TAG] stopAnimating];
        [[self viewWithTag:ACTIVITY_INDICATOR_TAG] removeFromSuperview];
        
    }
    
    [(UIScrollView*)self.superview setContentSize:CGSizeMake(((UIScrollView*)self.superview).contentSize.width, self.frame.size.height+190+42)]; // карусель + таббар
    
}

-(void)cellDidTapped:(UIGestureRecognizer*) gesture
{
    
    if(description.frame.size.height==description.contentSize.height)
    {
        [UIView animateWithDuration:0.2f animations:^{
            description.frame = CGRectMake(description.frame.origin.x, description.frame.origin.y, description.frame.size.width, DEFAULT_CELL_SUMM_HEIGHT-CGRectGetMaxY(lblTitle.frame));
        } completion:^(BOOL finished) {
            
        }];
        
    }
    else
    {
        [UIView animateWithDuration:0.2f animations:^{
            description.frame = CGRectMake(description.frame.origin.x, description.frame.origin.y, description.frame.size.width, description.contentSize.height);
        } completion:^(BOOL finished) {
            
        }];
    }
}

-(void) removeAllObservers;
{
    [description removeObserver:self forKeyPath:@"frame"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &descFrameObservanceContext) {
        [UIView animateWithDuration:0.2f animations:^{
            [self.cellImageView setFrame:CGRectMake(self.cellImageView.frame.origin.x, self.cellImageView.frame.origin.y, self.cellImageView.frame.size.width,description.frame.size.height!=16 ? CGRectGetMaxY(description.frame)+20 : 66)];
            [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, CGRectGetMaxY(description.frame)+100)];
            [self.goToDialogBtn setCenter:CGPointMake(self.center.x, CGRectGetMaxY(self.cellImageView.frame)+40)];
            ((UIScrollView*)self.superview).contentOffset = CGPointMake(0, 0);
        } completion:^(BOOL finished) {
            [(UIScrollView*)self.superview setContentSize:CGSizeMake(((UIScrollView*)self.superview).contentSize.width, self.frame.size.height+190+42+30)]; // карусель + таббар
        }];
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
