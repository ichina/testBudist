//
//  AdvertisementController.h
//  iSeller
//
//  Created by Чина on 15.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "BaseController.h"
#import "iCarousel.h"
#import "Advertisement.h"
#import "TabbarForAdView.h"
#import "DescriptionView.h"
#import "ContactsView.h"
#import "ShareView.h"
#import "CGSocialManagerProtocol.h"
#import "CGSocialManager.h"

@interface AdvertisementController : BaseController<iCarouselDataSource,iCarouselDelegate,TabbarForAdDelegate,UIScrollViewDelegate, CGAlertViewDelegate,ContactsViewDelegate,ShareViewDelegate, CGSocialManagerProtocol,DescriptionViewDelegate>
@property (nonatomic,strong) Advertisement* ad;
@property (weak, nonatomic) IBOutlet iCarousel *carousel;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;
@property (weak, nonatomic) IBOutlet UILabel *lblDistance;
@property (weak, nonatomic) IBOutlet UIImageView *birkaView;
@property (weak, nonatomic) IBOutlet UIImageView *birkaTextureView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *topBannerView;

@property (nonatomic, assign) BOOL isFromLaunch;

-(void)fbClicked;
-(void)twitterClicked;
-(void)emailClicked;

@end
