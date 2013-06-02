//
//  LoaderPlayView.h
//  testBudist
//
//  Created by Чингис on 03.06.13.
//  Copyright (c) 2013 Чингис. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LoaderPlayViewDelegate <NSObject>
@optional
-(void)loaderPlayBtnDidClicked;
@end

@interface LoaderPlayView : UIView

@property (nonatomic, weak) id <LoaderPlayViewDelegate> delegate;

@property(nonatomic,weak) IBOutlet UIImageView* finalStateImageView;
@property(nonatomic,weak) IBOutlet UIButton* loadingBtn;

@property (nonatomic) CGFloat progress;

-(void)setProgress:(CGFloat)progress;
-(IBAction)loadingBtnClicked:(UIButton*)sender;
@end
