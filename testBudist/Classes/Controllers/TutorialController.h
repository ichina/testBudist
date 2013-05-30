//
//  TutorialController.h
//  iSeller
//
//  Created by Чингис on 26.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "TutorialImageView.h"
#import "TutorialBGView.h"
#import "TutorialPageView.h"
#import "TutorialPageControl.h"
#import "TutorialLabel.h"
@interface TutorialController : UIViewController <UIScrollViewDelegate,UIActionSheetDelegate>
{
    __weak IBOutlet TutorialBGView *backgroundView;
    TutorialPageControl* pageControl;
    NSMutableArray* pages;
}
- (IBAction)closeBtnClicked:(id)sender;
- (IBAction)authWithFB:(id)sender;
- (IBAction)authWithVk:(id)sender;
- (IBAction)authWithOther:(id)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
//- (IBAction)closeTutorial:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *fbBtn;
@property (weak, nonatomic) IBOutlet UIButton *otherBtn;
@property (weak, nonatomic) IBOutlet UIButton *vkBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

@property (nonatomic) BOOL isFirstPresentTutorial;

@end
