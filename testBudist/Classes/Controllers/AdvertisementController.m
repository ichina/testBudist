//
//  AdvertisementController.m
//  iSeller
//
//  Created by Чина on 15.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "AdvertisementController.h"
#import "Profile.h"
#import "UIImageView+AFNetworking.h"
#import "PriceFormatter.h"
#import "NavigationHeaderView.h"
#import "MessagesController.h"
#import "Dialog.h"
#import "FullSizeController.h"
#import "UIImage+scale.h"
#import "EditAdController.h"
#import "LocationManager.h"
#import <MBProgressHUD.h>
#import "CGSocialManager+VKcom.h"
#import "LoaderView.h"
#import "NSString+Extensions.h"

#import "VLMHarlemShake.h"

#import "NSString+Extensions.h"

@interface AdvertisementController ()
{
    BOOL isMyAd;
    TabbarForAdView* tabbarForAd;
    DescriptionView* descriptionView;
    ContactsView* contactsView;
    ShareView* shareView;
    NSString* selectedImageUrl;
}

@property (nonatomic, assign) BOOL shake;

@end

@implementation AdvertisementController
@synthesize ad;

- (void)viewDidLoad
{
    self.skipAuth = YES;
    
    [super viewDidLoad];
    
    isMyAd = [[Profile sharedProfile] isMyId:[ad userID]];

    [self.scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.view.bounds)*(isMyAd ? 1:3), CGRectGetHeight(self.view.bounds))];
    [self.scrollView setPagingEnabled:YES];
    [self.scrollView setScrollEnabled:NO];
    //[self.scrollView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"no_noise_back.png"]]];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"preloader.png"]]];
    [self.scrollView setBackgroundColor:[UIColor clearColor]];
    [self.scrollView setDirectionalLockEnabled:YES];
    [self.scrollView setBounces:YES];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    [self.scrollView setDelegate:self];
    [ad setImages:[NSArray arrayWithObject:@{@"url" : ad.image ? ad.image: [UIImage imageNamed:@"placeholder.png"]}]];
    
    self.carousel.type = iCarouselTypeRotary;
    [self.carousel setScrollToItemBoundary:NO];
    [self.carousel setScrollEnabled:NO];
    [self.carousel reloadData];
    [self.carousel setCenterItemWhenSelected:NO];
    
    [self resizeleftNavItem];
    
    [self.birkaView setImage:[self.birkaView.image resizableImageWithCapInsets:UIEdgeInsetsMake(0,30,0,15)]];
    [self.birkaTextureView setImage:[self.birkaTextureView.image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)]];
    
    self.lblPrice.font = [UIFont fontWithName:@"Lobster 1.4" size:16.f];
    self.lblPrice.text = [[PriceFormatter sharedFormatter] formatPrice:[[ad price] floatValue]];//[NSString stringWithFormat:@"%@",[ad price]];//[[PriceFormatter sharedFormatter] formatPrice:[[ad price] floatValue]];
    [self.lblPrice setFrame:CGRectMake(32.0f, self.lblDistance.frame.origin.y-7, self.lblPrice.frame.size.width, self.lblPrice.frame.size.height)];
    
    [self.lblPrice sizeToFit];
    [self.birkaView setFrame:CGRectMake(self.birkaView.frame.origin.x, self.birkaView.frame.origin.y, self.lblPrice.frame.size.width+40, self.birkaView.frame.size.height)];
    [self.birkaTextureView setFrame:CGRectMake(self.birkaView.frame.origin.x+24, self.birkaView.frame.origin.y, self.birkaView.frame.size.width-25, self.birkaView.frame.size.height-2)];

    
    if(ad.isFavorite && ad.isFavorite.boolValue)
        //[self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"item_alreadyAddToFav.png"]];
        [self changeRightNavItemImage:@"item_alreadyAddToFav.png"];
    
    NavigationHeaderView *headerView = [[NavigationHeaderView alloc] initWithFrame:CGRectMake(0, 0, 180, 44)];
    [headerView setSingleLabelText:ad.title];
    [self.navigationItem setTitleView:headerView];
    
    tabbarForAd = [[TabbarForAdView alloc] initWithFrame:CGRectMake(0, 190, 320, TAB_BAR_HEIGHT) isMyAd:isMyAd];
    [self.topBannerView addSubview:tabbarForAd];
    [tabbarForAd setDelegate:self];
    
    [self addDescriptionView];
    if(!isMyAd)
    {
        [self addContactsView];
        [self addShareView];
        
        [self changeRightNavItemImage:(ad.isFavorite && ad.isFavorite.boolValue)?@"item_alreadyAddToFav.png":@"item_addToFav.png"];
    }
    else
    {
        [self.scrollView setScrollEnabled:NO];
        /*
        UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"Изменить" style:UIBarButtonItemStylePlain target:self action:@selector(goToEditAd:)];
        [self.navigationItem setRightBarButtonItem:rightBtn animated:YES];
        [self.navigationItem.rightBarButtonItem setImageInsets:UIEdgeInsetsMake(1, 0.5f, -1, -0.5f)];
        */
        
        /*UIButton *rightBtn = (UIButton*)self.navigationItem.rightBarButtonItem.customView;
         
         [rightBtn setImage:nil forState:UIControlStateNormal];
         
         [self.navigationItem.rightBarButtonItem setCustomView:nil];
         [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"Edit", nil)];*/
        
        UIButton *rightBtn = (UIButton*)self.navigationItem.rightBarButtonItem.customView;
        [rightBtn setImage:nil forState:UIControlStateNormal];
        [rightBtn setTitle:NSLocalizedString(@"Edit", nil) forState:UIControlStateNormal];
        
        CGSize size = [rightBtn.titleLabel.text sizeWithFont:rightBtn.titleLabel.font];
        
        CGFloat width = 0.0;
        
        if(size.width == 64) {
            
            width = size.width;
            
        }else if(size.width > 64) {
            
            width = 64;
            
        }else if(size.width < 64) {
            
            if(size.width + 10 <= 64) {
                
                width = size.width + 20;
                
            }else{
                
                width = size.width;
                
            }
            
        }
        
        [rightBtn setFrame:CGRectMake(0, 0, width, 30)];
        
        [self.navigationItem.rightBarButtonItem setCustomView:rightBtn];
        [self.navigationItem.rightBarButtonItem setWidth:80];
        
    }
    selectedImageUrl = ad.image;
    [Advertisement getAdvertisementWithIdentifier:[ad.identifier stringValue] success:^(Advertisement *_ad) {
        
        if(!ad.price) {
            
            self.lblPrice.text = [[PriceFormatter sharedFormatter] formatPrice:[[_ad price] floatValue]];//[NSString stringWithFormat:@"%@",[ad price]];//[[PriceFormatter sharedFormatter] formatPrice:[[ad price] floatValue]];
            [self.lblPrice setFrame:CGRectMake(32.0f, self.lblDistance.frame.origin.y-7, self.lblPrice.frame.size.width, self.lblPrice.frame.size.height)];
            
            [self.lblPrice sizeToFit];
            [self.birkaView setFrame:CGRectMake(self.birkaView.frame.origin.x, self.birkaView.frame.origin.y, self.lblPrice.frame.size.width+40, self.birkaView.frame.size.height)];
            [self.birkaTextureView setFrame:CGRectMake(self.birkaView.frame.origin.x+24, self.birkaView.frame.origin.y, self.birkaView.frame.size.width-25, self.birkaView.frame.size.height-2)];
            
        }
        
        ad = _ad;
        ad.image = selectedImageUrl;
        [contactsView setContactInfoWithAd:ad];
        
        [self findMainImage];
        
        [descriptionView setTitle:ad.title andDescription:ad.descriptionText];
        
        if([self.lblDistance.text isEqualToString:@"..."] && ad.location)
        {
            self.lblDistance.text = [[LocationManager sharedManager] calculateDistanceWithLocation:ad.location];
            [[LocationManager sharedManager] geocodingFromLocation:ad.location completion:^(NSString * address) {
                dispatch_async( dispatch_get_main_queue(), ^{
                    self.lblDistance.text = [NSString stringWithFormat:@"%@ (%@)",address,self.lblDistance.text];
                });
            }];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_AD_RECEIVED object:ad];
        
        if(ad.isFavorite.boolValue)
            //[self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"item_alreadyAddToFav.png"]];
            [self changeRightNavItemImage:@"item_alreadyAddToFav.png"];
        
    } failure:^(NSDictionary *dict, NSError *error) {
    }];
    
    if(![Profile sharedProfile].hasToken) {
        
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        
    }else{
        
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        
    }
    
    [self.scrollView bringSubviewToFront:self.topBannerView];
    
    if(IS_IPHONE5)
    {
        [self.topBannerView setFrame:CGRectMake(0, 0, self.topBannerView.frame.size.width, self.topBannerView.frame.size.height-88)];
        [descriptionView.superview setFrame:CGRectMake(CGRectGetMinX(descriptionView.superview.frame), CGRectGetMinY(descriptionView.superview.frame), CGRectGetWidth(descriptionView.superview.frame), CGRectGetHeight(descriptionView.superview.frame)+44)];
    }
	// Do any additional setup after loading the view.

    UISwipeGestureRecognizer *swipeLeftGesture = [[UISwipeGestureRecognizer alloc]
                                                  initWithTarget:self
                                                  action:@selector(handleSwipeLeft:)];
    [swipeLeftGesture setDirection: UISwipeGestureRecognizerDirectionLeft];
    
    UISwipeGestureRecognizer *swipeRightGesture = [[UISwipeGestureRecognizer alloc]
                                                   initWithTarget:self
                                                   action:@selector(handleSwipeRight:)];
    [swipeRightGesture setDirection: UISwipeGestureRecognizerDirectionRight];

    [self.carousel addGestureRecognizer:swipeLeftGesture];
    [self.carousel addGestureRecognizer:swipeRightGesture];
    
    [[CGSocialManager sharedSocialManager] setDelegate:self];
    
    if(ad.location)
    {
        self.lblDistance.text = [[LocationManager sharedManager] calculateDistanceWithLocation:ad.location];
        [[LocationManager sharedManager] geocodingFromLocation:ad.location completion:^(NSString * address) {
            dispatch_async( dispatch_get_main_queue(), ^{
                self.lblDistance.text = [NSString stringWithFormat:@"%@ (%@)",address,self.lblDistance.text];
                          });
        }];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socialPostingSucceeded:) name:PAULS_NOTIFICATION_SOCIAL_POSTING_SUCCEEDED object:self];
}

- (BOOL)canBecomeFirstResponder {
    
    return YES;
    
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
    if(motion == UIEventSubtypeMotionShake) {
        
        if(self.shake) {
            
            self.shake = NO;
            
            __block VLMHarlemShake *harlemShake = [[VLMHarlemShake alloc] initWithLonerView:descriptionView.goToDialogBtn];
            
            [harlemShake shakeWithCompletion:^{
                
                harlemShake = nil;
                                
            }];
            
        }else{
            
            self.shake = YES;
            
        }
        
    }
    
}

-(void)changeRightNavItemImage:(NSString*)imageName
{
    [(UIButton*)self.navigationItem.rightBarButtonItem.customView setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

-(void)addDescriptionView
{
    UIScrollView* firstScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, self.scrollView.frame.size.height+50)];
    [firstScrollView setDelegate:self];
    //[firstScrollView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"no_noise_back.png"]]];
    [firstScrollView setBackgroundColor:[UIColor clearColor]];
    [firstScrollView setContentSize:CGSizeMake(320, 800)];
    descriptionView = [[DescriptionView alloc] initWithFrame:CGRectMake(0, 232, 320, 204)];
    [firstScrollView addSubview:descriptionView];
    [descriptionView setTitle:[ad title] andDescription:[ad descriptionText]];
    [descriptionView setDelegate:self];
    [self.scrollView addSubview:firstScrollView];
    [descriptionView.goToDialogBtn setTitle:(isMyAd ? NSLocalizedString(@"Up to the TOP", nil): NSLocalizedString(@"Buy", nil)) forState:UIControlStateNormal];    
}

-(void)addContactsView
{
    
    UIScrollView* secondScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height+50 + (IS_IPHONE5?88:0))];
    [secondScrollView setDelegate:self];
    //[secondScrollView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"no_noise_back.png"]]];
    [secondScrollView setBackgroundColor:[UIColor clearColor]];

    [secondScrollView setContentSize:CGSizeMake(320, self.view.frame.size.height+10)];
    
    contactsView = [[ContactsView alloc] initWithFrame:CGRectMake(0, 232, 320, 190)];
    contactsView.delegate = self;
    [secondScrollView addSubview:contactsView];
    
    [self.scrollView addSubview:secondScrollView];
     
}

-(void)addShareView
{
    UIScrollView* thirdScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height+50 + (IS_IPHONE5?88:0))];
    [thirdScrollView setDelegate:self];
    //[thirdScrollView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"no_noise_back.png"]]];
    [thirdScrollView setBackgroundColor:[UIColor clearColor]];
    [thirdScrollView setBounces:YES];
    shareView = [[ShareView alloc] initWithFrame:CGRectMake(0, 232, 320, 184)];
    [thirdScrollView addSubview:shareView];
    [shareView setDelegate:self];
    [self.scrollView addSubview:thirdScrollView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tabBarController setHidden:YES animated:YES];
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        [descriptionView removeAllObservers];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:PAULS_NOTIFICATION_SOCIAL_POSTING_SUCCEEDED object:self];
    }
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - iCarousel delegate's methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    
    switch ([ad images].count) {
        case 2:case 3:
            return [ad images].count*2;
            break;
        default:
            return [ad images].count;
            break;
    }
    return [[ad images] count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UIImageView* imageView = nil;
    UIImageView* leftAlphaView = nil;
    UIImageView* rightAlphaView = nil;;
    if (view == nil)
    {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 190.0f, 190.0f)];
        [view setBackgroundColor:[UIColor clearColor]];
        view.contentMode = UIViewContentModeCenter;
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 190.0f, 190.0f)];
        [imageView setCenter:view.center];
        imageView.tag = 2;
        [view addSubview:imageView];
        
        leftAlphaView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 190.0f, 190.0f)];
        [leftAlphaView setImage:[UIImage imageNamed:@"item_image_left_shadow.png"]];
        [leftAlphaView setTag:5];
        [leftAlphaView setAlpha:index==0?0:0.5f];
        [view addSubview:leftAlphaView];
        
        rightAlphaView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 190.0f, 190.0f)];
        [rightAlphaView setImage:[UIImage imageWithCGImage:[UIImage imageNamed:@"item_image_left_shadow.png"].CGImage scale:1.0f orientation:UIImageOrientationUpMirrored]];
        [rightAlphaView setTag:6];
        [rightAlphaView setAlpha:index==0?0:0.5f];
        [view addSubview:rightAlphaView];
    }
    else
    {
        imageView = (UIImageView*)[view viewWithTag:2];
        leftAlphaView = (UIImageView*)[view viewWithTag:5];
        rightAlphaView = (UIImageView*)[view viewWithTag:6];
    }
    
    if ([[ad images] count] > 0) {
        if([[ad images][ (index % [[ad images]count]) ][@"url"] isKindOfClass:[NSString class]])
            [imageView setImageWithURL:[NSURL URLWithString:[ad images][ (index % [[ad images]count]) ][@"url"] ] placeholderfileName:@"placeholder.png"];
        else
            [imageView setImage:[ad images][ (index % [[ad images]count]) ][@"url"]];
    }
    
    return view;
}

- (void)carousel:(iCarousel *)localCarousel didSelectItemAtIndex:(NSInteger)index
{
    if(index%ad.images.count != localCarousel.currentItemIndex%ad.images.count)
    {
        if(localCarousel.currentItemIndex==0)
        {
            if(index%ad.images.count!=(ad.images.count-1))
            {
                //NSLog(@"right");
                [self handleSwipeLeft:nil];
            }
            else
            {
                //NSLog(@"left");
                [self handleSwipeRight:nil];
            }
        }
        else
        {
            if(index==0)
            {
                if(localCarousel.currentItemIndex%ad.images.count!=ad.images.count-1)
                {
                    //NSLog(@"left");
                    [self handleSwipeRight:nil];
                }
                else
                {
                    //NSLog(@"right");
                    [self handleSwipeLeft:nil];

                }
            }
            else
            {
                if(localCarousel.currentItemIndex>index)
                {
                    //NSLog(@"left");
                    [self handleSwipeRight:nil];
                }else
                {
                    //NSLog(@"right");
                    [self handleSwipeLeft:nil];

                }
            }
        }
        
    }
    else
        [self performSegueWithIdentifier:kSegueFromAdToFullSize sender:nil];
    
}

- (NSUInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
    //note: placeholder views are only displayed on some carousels if wrapping is disabled
    return 1;
}

- (UIView *)carousel:(iCarousel *)carousel placeholderViewAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UIImageView* imageView = nil;
    UIImageView* leftAlphaView = nil;
    UIImageView* rightAlphaView = nil;
    
    if (view == nil)
    {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 190.0f, 190.0f)];
        [view setBackgroundColor:[UIColor clearColor]];
        view.contentMode = UIViewContentModeCenter;
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 190.0f, 190.0f)];
        [imageView setCenter:view.center];
        imageView.tag = 2;
        [view addSubview:imageView];
        
    }
    else
    {
        imageView = (UIImageView*)[view viewWithTag:2];
        leftAlphaView = (UIImageView*)[view viewWithTag:5];
        rightAlphaView = (UIImageView*)[view viewWithTag:6];
    }
    
    
    if ([[ad images] count] > 0) {
        if([[ad images][ (index % [[ad images]count]) ][@"url"] isKindOfClass:[NSString class]])
            [imageView setImageWithURL:[NSURL URLWithString:[ad images][ (index % [[ad images]count]) ][@"url"] ] placeholderfileName:@"placeholder.png"];
        else
            [imageView setImage:[ad images][ (index % [[ad images]count]) ][@"url"]];
    }
    
    [leftAlphaView setAlpha:1];
    [rightAlphaView setAlpha:1];
    return view;
}

#pragma mark - UIScrollViewDelegate method's
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    static CGPoint scrollContentOffset;
    static CGPoint prevContentOffset;
    if(scrollView!=self.scrollView)
    {
        scrollContentOffset = scrollView.contentOffset;
        [self.scrollView setScrollEnabled: scrollContentOffset.y==0 ];  //запрещаю горизотальный скролл если вертикальный отступ не 0
        
        [scrollView setBounces:(prevContentOffset.y<scrollView.contentOffset.y || scrollView.contentOffset.y+scrollView.bounds.size.height>=scrollView.contentSize.height)];
        prevContentOffset = scrollView.contentOffset;
    }
   
    
    if(scrollView!=self.topBannerView.superview)
    {
        [scrollView addSubview:self.topBannerView];            
    }
    [self.topBannerView setCenter:CGPointMake(CGRectGetMidX(scrollView.bounds), CGRectGetMidY(self.topBannerView.bounds))];
}
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if(scrollView == self.scrollView)
        [tabbarForAd setUserInteractionEnabled:NO];
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(scrollView==self.scrollView)
        [tabbarForAd setUserInteractionEnabled:NO];
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView==self.scrollView)
        [tabbarForAd setUserInteractionEnabled:YES];
    if(!isMyAd && scrollView==self.scrollView)
    {
        int page = scrollView.contentOffset.x/320;
        [tabbarForAd selectTabIndex:page];
    }
}

#pragma mark - TabbarForAd delegate's methods

-(void)tabbarForAd:(TabbarForAdView *)tabbarForAd didSelectIndex:(NSNumber *)indexNumber
{
    if(isMyAd)
    {
        switch (indexNumber.integerValue) {
            case 0:
                [self sendEventWithCategory:@"Advertisement:Social" action:[NSString stringWithFormat:@"Share on Twitter button pressed (is my advertisement: %@)", isMyAd ? @"YES" : @"NO"] label:@"" value:nil];
                [self twitterClicked];
                break;
            case 1:
                [self sendEventWithCategory:@"Advertisement:Social" action:[NSString stringWithFormat:@"Share on Facebook button pressed (is my advertisement: %@)", isMyAd ? @"YES" : @"NO"] label:@"" value:nil];

                [self fbClicked];
                break;
            case 2:
                [self sendEventWithCategory:@"Advertisement:Social" action:[NSString stringWithFormat:@"Share with Email button pressed (is my advertisement: %@)", isMyAd ? @"YES" : @"NO"] label:@"" value:nil];
                
                [self emailClicked];
                break;
            case 3:
                [self sendEventWithCategory:@"Advertisement:Social" action:[NSString stringWithFormat:@"Share on Vkontakte button pressed (is my advertisement: %@)", isMyAd ? @"YES" : @"NO"] label:@"" value:nil];

                [self vkClicked];
        }
    }
    else
    {
        int currentPage = self.scrollView.contentOffset.x/CGRectGetWidth(self.scrollView.bounds);
        if(indexNumber.integerValue!=currentPage)
        {
            if(self.topBannerView.superview==self.scrollView)
            {
                [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.scrollView.bounds)*indexNumber.integerValue, self.scrollView.contentOffset.y) animated:YES];
            }
            else
            {
                
                UIScrollView* superScroll = (UIScrollView*)self.topBannerView.superview;
                CGPoint contentOffset = superScroll.contentOffset;
                [self.scrollView addSubview:self.topBannerView];

                [UIView animateWithDuration:0.2f animations:^{
                    [superScroll setContentOffset:CGPointMake(contentOffset.x, 0)];
                    
                    
                } completion:^(BOOL finished) {
                    [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.scrollView.bounds)*indexNumber.integerValue, self.scrollView.contentOffset.y) animated:YES];
                }];
            }
        }
    }
}

-(IBAction)addToFavorites:(id)sender
{
    [self sendEventWithCategory:@"Advertisement" action:[NSString stringWithFormat:@"Add to favourites button pressed (was favourite: %@)", ad.isFavorite.boolValue ? @"YES" : @"NO"] label:@"" value:nil];
    
    if(!ad.isFavorite.boolValue)
    {
        //[self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"item_alreadyAddToFav.png"]];
        [Advertisement addAdvertisementToFavouritesWithIdentifier:[ad.identifier stringValue] success:^(id object) {
            
            [self changeRightNavItemImage:@"item_alreadyAddToFav.png"];
            
            [ad setIsFavorite:[NSNumber numberWithBool:1]];
            
        } failure:^(id object, NSError *error) {
            if (![[error.localizedDescription substringFromIndex:(error.localizedDescription.length-3)] isEqualToString:@"409"])
                //[self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"item_addToFav.png"]];
                [self changeRightNavItemImage:@"item_addToFav.png"];
        }];
    }else{
        
        [Advertisement deleteFavouriteWithIdentifier:[ad.identifier stringValue] success:^(id object) {
            
            [self changeRightNavItemImage:@"item_addToFav.png"];
            
            [ad setIsFavorite:[NSNumber numberWithBool:0]];
            
        } failure:^(id object, NSError *error) {
            
            
            
        }];
    }
}


-(void)goToEditAd:(id)sender
{
    [self performSegueWithIdentifier:kSegueFromAdToEdit sender:sender];
}

#pragma mark - uigestureSWIPE
- (void)handleSwipeLeft:(UISwipeGestureRecognizer *)recognizer   // Вызывается из свайпу вверх
{
    if(_carousel.numberOfItems==1)
        return;
    UIView* tempView = [_carousel itemViewAtIndex:(_carousel.currentItemIndex+1)%_carousel.numberOfItems];
    UIView* leftView = [_carousel itemViewAtIndex:(_carousel.currentItemIndex)%_carousel.numberOfItems];
    UIView* rightView = [_carousel itemViewAtIndex:(_carousel.currentItemIndex+2)%_carousel.numberOfItems];

    [UIView animateWithDuration:0.4f animations:^{
        [[tempView viewWithTag:5] setAlpha:0];
        [[tempView viewWithTag:6] setAlpha:0];
        [[leftView viewWithTag:5] setAlpha:1];
        [[leftView viewWithTag:6] setAlpha:0];
        [[rightView viewWithTag:5] setAlpha:0];
        [[rightView viewWithTag:6] setAlpha:1];
    }];
    [_carousel scrollToItemAtIndex:_carousel.currentItemIndex+1 animated:YES];
}

- (void)handleSwipeRight:(UISwipeGestureRecognizer *)recognizer   // Вызывается из свайпу вниз
{
    if(_carousel.numberOfItems==1)
        return;
    UIView* tempView = [_carousel itemViewAtIndex:(_carousel.currentItemIndex-1+_carousel.numberOfItems)%_carousel.numberOfItems];
    UIView* leftView = [_carousel itemViewAtIndex:(_carousel.currentItemIndex-2+_carousel.numberOfItems)%_carousel.numberOfItems];
    UIView* rightView = [_carousel itemViewAtIndex:(_carousel.currentItemIndex)%_carousel.numberOfItems];
    
    [UIView animateWithDuration:0.4f animations:^{
        [[tempView viewWithTag:5] setAlpha:0];
        [[tempView viewWithTag:6] setAlpha:0];
        [[leftView viewWithTag:5] setAlpha:1];
        [[leftView viewWithTag:6] setAlpha:0];
        [[rightView viewWithTag:5] setAlpha:0];
        [[rightView viewWithTag:6] setAlpha:1];
    }];

    [_carousel scrollToItemAtIndex:_carousel.currentItemIndex-1 animated:YES];
}

-(void)findMainImage
{
    NSMutableArray* array = ad.images.mutableCopy;
    for ( ; ; )
        if(![array[0][@"main_image"] boolValue])
        {
            [array insertObject:array[0] atIndex:array.count];
            [array removeObjectAtIndex:0];
        }
        else
            break;
    
    ad.images = array.copy;
    
    
    if(array.count==2||array.count==3)
        [array addObjectsFromArray:array];

    for (int i = 1 ; i < array.count ; i++)
            [self.carousel insertItemAtIndex:self.carousel.numberOfItems animated:YES];
        /*
        if([dict[@"main_image"] boolValue] && !mainAlreadyAdded)
        {
            mainAlreadyAdded = YES;
        }
        else
            [self.carousel insertItemAtIndex:self.carousel.numberOfItems animated:YES];
         */
}

#pragma mark - OWN_BTNS_ACTIONS
-(NSDictionary*)socialManagerDataSourceForPosting
{
    NSMutableDictionary* dict = [@{@"screenShots" : ad.image?ad.image : @"",
                                 @"userName" : ad.user.name,
                                 @"title" : ad.title,
                                 @"price" : ad.price,
                                 @"adid" : ad.identifier.stringValue,
                                 @"description" : ad.descriptionText ? ad.descriptionText : @""} mutableCopy];
    UIImage* image = ((UIImageView*)[[_carousel itemViewAtIndex:0] viewWithTag:2]).image;
    if (image) {
        [dict setObject:image forKey:@"image"];
    }
    return dict;
}
#pragma mark - CGSocialDelegate
-(void)fbClicked
{
    
    [self sendEventWithCategory:@"Advertisement:Social" action:[NSString stringWithFormat:@"Share on Facebook button pressed (is my advertisement: %@)", isMyAd ? @"YES" : @"NO"] label:@"" value:nil];
    
    if(isMyAd)
    {
        [self showHUDForPublishing];
    }
    
    //[[CGSocialManager sharedSocialManager] tryPost:[ad.identifier stringValue] toFB:YES toVK:NO toTW:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:PAULS_NOTIFICATION_SOCIAL_POSTING object:self userInfo:@{@"fb": [NSNumber numberWithBool:YES], @"vk":[NSNumber numberWithBool:NO], @"tw":[NSNumber numberWithBool:NO], @"adID":[ad.identifier stringValue],@"title":ad.title, @"price":ad.price}];
    
    
}
-(void)twitterClicked
{
    
    [self sendEventWithCategory:@"Advertisement:Social" action:[NSString stringWithFormat:@"Share on Twitter button pressed (is my advertisement: %@)", isMyAd ? @"YES" : @"NO"] label:@"" value:nil];
    
    if(isMyAd)
    {
        [self showHUDForPublishing];
    }
   
    [[NSNotificationCenter defaultCenter] postNotificationName:PAULS_NOTIFICATION_SOCIAL_POSTING object:self userInfo:@{@"fb": [NSNumber numberWithBool:NO], @"vk":[NSNumber numberWithBool:NO], @"tw":[NSNumber numberWithBool:YES], @"adID":[ad.identifier stringValue],@"title":ad.title, @"price":ad.price}];
    
    
}
-(void)emailClicked
{
    [self sendEventWithCategory:@"Advertisement:Social" action:@"Share with email button pressed" label:@"" value:nil];
    
    [[CGSocialManager sharedSocialManager] showPeoplePickerController];
    
}
-(void)vkClicked
{
    
    [self sendEventWithCategory:@"Advertisement:Social" action:[NSString stringWithFormat:@"Share on Vkontakte button pressed (is my advertisement: %@)", isMyAd ? @"YES" : @"NO"] label:@"" value:nil];
    
    if(isMyAd)
    {
        [self showHUDForPublishing];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PAULS_NOTIFICATION_SOCIAL_POSTING object:self userInfo:@{@"fb": [NSNumber numberWithBool:NO], @"vk":[NSNumber numberWithBool:YES], @"tw":[NSNumber numberWithBool:NO], @"adID":[ad.identifier stringValue],@"title":ad.title, @"price":ad.price}];
    
    
}

-(void)showHUDForPublishing
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setSquare:YES];
    [hud setMinSize:CGSizeMake(126, 126)];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[LoaderView alloc] initWithMode:loaderViewModeIndeterminate];
    [(LoaderView*)hud.customView startAnimating];
    hud.labelText = NSLocalizedString(@"Publishing...", nil);
}

-(void)postingCGSocialInFBDidCancel
{
    [tabbarForAd deselectTabIndex:0];
}
-(void)postingCGSocialInTwitterDidCancel
{
    [tabbarForAd deselectTabIndex:1];
}
-(void)sendingCGSocialToEmailDidCancel
{
    [tabbarForAd deselectTabIndex:2];
}
-(void)sendingCGSocialToVkDidCancel
{
    [tabbarForAd deselectTabIndex:3];
}

-(void)socialPostingSucceeded:(NSNotification*) notification
{
    NSLog(@"%@",notification.userInfo);
    
    [shareView socialPostingSucceded:notification.userInfo];
    
    if(!isMyAd)
    {
        [[[CGAlertView alloc] initWithTitle:NSLocalizedString(notification.userInfo[@"provider"], nil)  message:([notification.userInfo[@"status"] isEqualToString:@"error"])?NSLocalizedString(@"Publishing fail", nil):NSLocalizedString(@"Publishing success", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
    else
    {
        MBProgressHUD* hud = [MBProgressHUD HUDForView:self.view];
        
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:([notification.userInfo[@"status"] isEqualToString:@"error"] ? @"error.png" : @"success.png")]];
        hud.labelText = NSLocalizedString(([notification.userInfo[@"status"] isEqualToString:@"error"]?@"Error":@"Success"), nil);
        
        dispatch_async( dispatch_get_main_queue(), ^{
            [hud hide:YES afterDelay:1];
        });

    }
}

#pragma mark - DescriptionViewDelegate

-(void) descriptionBtnClicked
{
    if(isMyAd)
    {
        if([[NSUserDefaults standardUserDefaults] objectForKey:DONT_SHOW_ALERT_WITH_PRICE_OF_TOP])
            [self upToTheTop];
        else
        {
            
            NSString* coins = [NSLocalizedString(@"locale", nil) isEqualToString:@"en"]?@"coins":[[[Profile sharedProfile].currentPrice stringValue] rusSklonenieCoins];
            
            CGAlertView* alert = [[CGAlertView alloc] initWithTitle:NSLocalizedString(@"iSeller", nil) message:[NSString stringWithFormat:NSLocalizedString(@"BILLING_ALERT_TEXT", nil),[[Profile sharedProfile].currentPrice stringValue], coins] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil),NSLocalizedString(@"OK, don't show again", nil), nil];
            alert.tag = 1009;
            [alert show];
        }
    }
    else
    {
        
        [self sendEventWithCategory:@"Advertisement" action:@"Buy button pressed" label:@"" value:nil];
        
        if([self.navigationController.viewControllers[self.navigationController.viewControllers.count-2] isKindOfClass:([MessagesController class])])
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            MessagesController* messController = [self.storyboard instantiateViewControllerWithIdentifier:@"MessagesController"];
            NSDictionary* dict = @{
                                   @"user" : @{@"id" : ad.user.identifier ? ad.user.identifier : ad.userID, @"name" : ad.user.name ? ad.user.name : @"", @"avatar":ad.user.avatar?ad.user.avatar:@""},
            @"ad" : @{@"id" : ad.identifier , @"title":ad.title, @"image" :ad.image}};
            messController.dialog = [[Dialog alloc] initWithContents:dict];
            [self.navigationController pushViewController:messController animated:YES];
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:kSegueFromAdToFullSize])
    {
        FullSizeController* fullsizeCont = (FullSizeController*)segue.destinationViewController;
        fullsizeCont.index = self.carousel.currentItemIndex >=ad.images.count ? self.carousel.currentItemIndex-ad.images.count : self.carousel.currentItemIndex;
        fullsizeCont.ad = ad;
    }
    if([segue.identifier isEqualToString:kSegueFromAdToEdit])
    {
        EditAdController* EditAdCont = (EditAdController*)segue.destinationViewController;
        EditAdCont.ad = ad;
    }
}

-(void)showWarningHUD:(NSString*)message
{
    UIView* tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
    [tempView setBackgroundColor:[UIColor clearColor]];
    [tempView setCenter:self.view.center];
    [self.view addSubview:tempView];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setMode:MBProgressHUDModeText];
    [hud setLabelText:message];
    [hud setAnimationType:MBProgressHUDAnimationFade];
    [hud hide:YES afterDelay:1.0f];
    [hud setMargin:10];
}

- (void)viewDidUnload {
    [self setTopBannerView:nil];
    [self setCarousel:nil];
    [self setLblPrice:nil];
    [self setLblDistance:nil];
    [self setBirkaView:nil];
    [self setScrollView:nil];
    [self setBirkaTextureView:nil];
    [super viewDidUnload];
}

-(void)resizeleftNavItem
{
    UIButton* btn = (UIButton*)self.navigationItem.rightBarButtonItem.customView;
    [btn setBackgroundImage:[[UIImage imageNamed:@"sale_navbar_filter.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)] forState:UIControlStateNormal];
    
    [btn addTarget:self action:(isMyAd?@selector(goToEditAd:) : @selector(addToFavorites:))forControlEvents:UIControlEventTouchUpInside];
}

- (void)alertView:(CGAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(alertView.tag == 1009)
    {
        if(buttonIndex==0)
            return;
        
        if(buttonIndex==2)
        {
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:DONT_SHOW_ALERT_WITH_PRICE_OF_TOP];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        [self upToTheTop];
         
         
    }
    if(alertView.tag==1010)
    {
        switch (buttonIndex) {
            case 1:
                
                [self performSegueWithIdentifier:kSegueFromAdvertisementToPurchase sender:self];
                
                break;
                
            default:
                break;
    }
    }
}

-(void)upToTheTop
{
    
    [self sendEventWithCategory:@"Advertisement" action:@"Up to top button pressed" label:@"" value:nil];
    
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setSquare:YES];
    [hud setMinSize:CGSizeMake(126, 126)];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[LoaderView alloc] initWithMode:loaderViewModeIndeterminate];
    [(LoaderView*)hud.customView startAnimating];
    hud.labelText = NSLocalizedString(@"Waiting...", nil);
    
    
    [Advertisement upToTopWithID:[ad.identifier stringValue] success:^(Advertisement *ad) {
        
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"success.png"]];
        hud.labelText = NSLocalizedString(@"Success", nil);
        
        [hud hide:YES afterDelay:1];
        [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_NEED_UPDATE_FEED_DATA_SOURCE object:self];
        
    } failure:^(NSDictionary *dict, NSError *error) {
        
        if(error.code == -1011 && [[error localizedDescription] containsString:@"409"]) {
            
            [self sendEventWithCategory:@"Advertisement" action:@"Up to top button pressed (Not enough coins)" label:@"" value:nil];
            
            [hud hide:YES];
            
            CGAlertView *alert = [[CGAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"You are out of coins. Would you like to buy some?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
            alert.tag = 1010;
            [alert show];
            
        }else{
            
            hud.mode = MBProgressHUDModeCustomView;
            hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
            hud.labelText = NSLocalizedString(@"Failed", nil);
            
            [hud hide:YES afterDelay:1];
            
        }
        
    }];
}

@end
