//
//  DescriptionView.h
//  iSeller
//
//  Created by Чина on 15.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DescriptionViewDelegate;
@interface DescriptionView : UIView 
{
    UITapGestureRecognizer* tap2;
}
@property(nonatomic,strong) UIImageView* cellImageView;
@property(nonatomic,strong) UIButton* btnToDialog;
@property(nonatomic,strong) UILabel* lblTitle;
@property(nonatomic,strong) UITextView* description;
@property(nonatomic,strong) UIButton* goToDialogBtn;

@property (nonatomic, retain) id <DescriptionViewDelegate> delegate;

-(void) setTitle:(NSString*) title andDescription:(NSString*) desc;
-(void) removeAllObservers;

@end

@protocol DescriptionViewDelegate <NSObject>
@required
-(void)descriptionBtnClicked;
@end