//
//  FullSizeController.h
//  iSeller
//
//  Created by Чина on 29.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "BaseController.h"
#import "Advertisement.h"
@interface FullSizeController : BaseController <UIScrollViewDelegate>
{
    int pageNumber;
    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet UIPageControl *pageControl;
}
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (nonatomic,strong) NSMutableArray* imageUrls;
@property (nonatomic,strong) NSMutableArray* images;

@property (nonatomic,strong) Advertisement* ad;
@property (nonatomic) int index;

@end
