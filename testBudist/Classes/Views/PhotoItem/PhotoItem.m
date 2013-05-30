//
//  PhotoItem.m
//  iSeller
//
//  Created by Чина on 22.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "PhotoItem.h"
#define PHOTO_ITEM_HEIGHT 77.0f
#define PHOTO_BTN_SIDE 77.0f
#define FLAG_IMAGE_TAG 500
#define REMOVE_BTN_TAG 501
@implementation PhotoItem
@synthesize photoBtn,removeBtn;
@synthesize delegate = _delegate;

- (id)initWithImage:(UIImage*) image
{
    self = [super initWithFrame:CGRectMake(0, 0, PHOTO_ITEM_HEIGHT, PHOTO_ITEM_HEIGHT)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [photoBtn setFrame:CGRectMake(0, 6, 67, 66)];
        //[photoBtn setImage:[UIImage imageNamed:@"create_add_photo_border.png"] forState:UIControlStateNormal];
        [photoBtn setImage:image forState:UIControlStateNormal];
        [self addSubview:photoBtn];
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(photoBtnTapped:)];
        [photoBtn addGestureRecognizer:tapGesture];
        UILongPressGestureRecognizer* longTapGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(photoBtnLongTapped:)];
        [photoBtn addGestureRecognizer:longTapGesture];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectInset(photoBtn.frame, -3, -3)];
        [imageView setCenter:CGPointMake(imageView.center.x, imageView.center.y+1)];
        [imageView setImage:[UIImage imageNamed:@"create_add_photo_border.png"]];
        [self addSubview:imageView];
    }
    return self;
}

-(void)addRemoveButton
{
    if(!removeBtn)
        removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [removeBtn setImage:[UIImage imageNamed:@"create_delete.png"] forState:UIControlStateNormal];
    [removeBtn setFrame:CGRectMake(0, 6, removeBtn.imageView.image.size.width, removeBtn.imageView.image.size.height)];
    [removeBtn setCenter:CGPointMake(CGRectGetMaxX(photoBtn.bounds)-4, photoBtn.frame.origin.y+4)];
    [removeBtn addTarget:self action:@selector(removeBtn:) forControlEvents:UIControlEventTouchUpInside];
    removeBtn.tag = REMOVE_BTN_TAG;
    [self addSubview:removeBtn];
}

-(void)photoBtnTapped:(UIGestureRecognizer*) gesture
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(photoItemDidSelected:)])
       [self.delegate photoItemDidSelected:self];
}

-(void)photoBtnLongTapped:(UIGestureRecognizer*) gesture
{
    
    for(PhotoItem* item in self.superview.subviews)
    {
        if ([item isKindOfClass:([PhotoItem class])]) {
            [item addRemoveButton];
        }
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(playAnimation)])
        [self.delegate playAnimation];
}
-(void)removeBtn:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(photoItemRemoveButtonDidSelected:)])
    {
        [self.delegate photoItemRemoveButtonDidSelected:self];
    }
    
    [self setHidden:YES];
    for(PhotoItem* item in self.superview.subviews)
    {
        if ([item isKindOfClass:([PhotoItem class])] && item.tag>self.tag) {
            item.tag--;
            [UIView animateWithDuration:0.5f animations:^{
                //[item setCenter:CGPointMake(item.frame.size.width*(item.tag-50)+45, 47)];
                [item setCenter:CGPointMake(item.frame.size.width*(item.tag-50)+45, item.center.y)];
            } completion:^(BOOL finished) {
                
            }];
        }
    }
    [self removeFromSuperview];
}

-(void)addBtnToBeginForScroll
{    
    for(PhotoItem* item in self.superview.subviews)
    {
        if ([item isKindOfClass:([PhotoItem class])])
        {
            item.tag++;
            [UIView animateWithDuration:0.5f animations:^{
                [item setCenter:CGPointMake(item.frame.size.width*(item.tag-50)+45, item.center.y)];
            } completion:^(BOOL finished) {
                
            }];
        }
    }
}

-(void)deleteRemoveBtn
{
    if([self viewWithTag:REMOVE_BTN_TAG])
        [[self viewWithTag:REMOVE_BTN_TAG] removeFromSuperview];
}

- (void)addFlag{
    if(![self viewWithTag:FLAG_IMAGE_TAG])
    {
        UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"create_main_image.png"]];
        [imageView setFrame:CGRectMake(-5, 0, imageView.image.size.width, imageView.image.size.height)];
        [self addSubview:imageView];
        [imageView setTag:FLAG_IMAGE_TAG];
    }
}
- (void)removeFlag{
    if([self viewWithTag:FLAG_IMAGE_TAG])
        [[self viewWithTag:FLAG_IMAGE_TAG] removeFromSuperview];
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
