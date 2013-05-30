//
//  PhotoItem.h
//  iSeller
//
//  Created by Чина on 22.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoItemDelegate;
@interface PhotoItem : UIView

@property (nonatomic,weak) id <PhotoItemDelegate> delegate;
@property(nonatomic,strong) UIButton* photoBtn;
@property(nonatomic,strong) UIButton* removeBtn;

- (id)initWithImage:(UIImage*) image;
- (void)addBtnToBeginForScroll;

- (void)removeFlag;
- (void)addFlag;
-(void)deleteRemoveBtn;

@end

@protocol PhotoItemDelegate <NSObject>
@optional

-(void)photoItemDidSelected:(PhotoItem*) didSelected;
-(void)photoItemRemoveButtonDidSelected:(PhotoItem *)didSelected;
-(void)playAnimation;
-(void)stopAnimation;
@end