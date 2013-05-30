//
//  TabBarController.m
//  iSeller
//
//  Created by Чина on 28.12.12.
//  Copyright (c) 2012 CloudTeam. All rights reserved.
//

#import "TabBarController.h"
#import "AppDelegate.h"
#import "Profile.h"
#import "MessagesController.h"
#import "AdvertisementController.h"

#import "NSDate+Extensions.h"

#import "LocationManager.h"

#define TABBAR_Y_ORIGIN 431+((IS_IPHONE5)?88.0f:0.0f)
#define SCREEN_HEIGHT 480+((IS_IPHONE5)?88.0f:0.0f)

#if NS_BLOCKS_AVAILABLE
typedef void(^ApplicationActive)();
#endif

@interface TabBarController ()
{
    int selectedIndex;
    int prevSelectedIndex;
}

@property (nonatomic, copy) ApplicationActive applicationActiveBlock;

@end

@implementation TabBarController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifierDidReceived:) name:@"DidReceiveMessage" object:[[UIApplication sharedApplication] delegate]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enteredFromSite:) name:@"EnteredFromSite" object:[[UIApplication sharedApplication] delegate]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarDidClicked:) name:CHINAS_NOTIFICATION_STATUSBAR_CLICKED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setBadgeValueFromProfile:) name:CHINAS_NOTIFICATION_UPDATE_BADGE_VALUE_FROM_PROFILE object:nil];
        
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allowRotatingInFullSize:) name:CHINAS_NOTIFICATION_ALLOW_ROTATING_IN_FULL_SIZE object:nil];
        
        self.allowRotatingFullSize = YES;//разрешаем ротацию для фуллсайза, будет отключатся только в пинч жесте для зумма в самОм фуллсайзе

        if([[UIApplication sharedApplication] statusBarOrientation]!=UIInterfaceOrientationPortrait)
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self tabBar] setBackgroundImage:[UIImage imageNamed:@"tabbar_bg.png"]];
    
    [[self tabBar] setSelectionIndicatorImage:[[UIImage alloc] init]];
    
    for(UIView *view in self.view.subviews)
    {
        if(![view isKindOfClass:[UITabBar class]])
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, SCREEN_HEIGHT)];
    }
    
    for(UINavigationController* nc in self.viewControllers)
    {
        int index = [self.viewControllers indexOfObject:nc];
        UITabBarItem *item = nc.tabBarItem;
        
        NSString* imageName = [NSString stringWithFormat:@"btn%d.png",( index > 2  ? index : index+1 )]; //так как в нумеровке картинок создание не учитывалось
        NSString * selectedImageName = [NSString stringWithFormat:@"btn%d_active.png",( index > 2  ? index : index+1 )];
        if(index==2)
        {
            [item setFinishedSelectedImage:[UIImage imageNamed:@"tabbar_create.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar_create.png"]];
            [item setImageInsets:UIEdgeInsetsMake(4, 0, -4, 0)];
        }
        else
        {
            [item setFinishedSelectedImage:[UIImage imageNamed:selectedImageName] withFinishedUnselectedImage:[UIImage imageNamed:imageName]];
            [item setImageInsets:UIEdgeInsetsMake(7, 0, -7, 0)];
        }
    }
    selectedIndex = 0;
    [self setAllAppearance];
    
    [self showLaunchAnimationWithView:self.view];
    
}

-(void) showLaunchAnimationWithView:(UIView*) view
{
    __block UIImageView *fadeAnimView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, (IS_IPHONE5)?568:480)];
    [fadeAnimView setImage:[UIImage imageNamed:IS_RETINA?(IS_IPHONE5?@"Default-568h@2x.png": @"Default@2x.png"):@"Default.png"]];
    [self.view addSubview:fadeAnimView];
    [UIView animateWithDuration:1.2f animations:^{
        [fadeAnimView setAlpha:0];
    } completion:^(BOOL finished) {
        [fadeAnimView removeFromSuperview];
        fadeAnimView = nil;
    }];
}

-(void)setAllAppearance
{
    //UINavbar
    [[UINavigationBar appearanceWhenContainedIn:[UINavigationController class], [UIView class], nil] setBackgroundImage:[[UIImage imageNamed:@"navbar_bg_main.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forBarMetrics:UIBarMetricsDefault];
    UIImage *backBtn = [[UIImage imageNamed:@"navbar_back.png"]
                             resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 5)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backBtn
                                                      forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"navbar_back_selected.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 5)] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
    UIImage *otherBtn = [[UIImage imageNamed:@"sale_navbar_filter.png"]
                         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)]; //-1 bottom
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class],nil] setBackgroundImage:otherBtn forState:UIControlStateNormal
                                          barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class],nil] setBackgroundImage:[[UIImage imageNamed:@"sale_navbar_filter_selected.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)] forState:UIControlStateHighlighted
                                                                                     barMetrics:UIBarMetricsDefault];
    
    
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setBackgroundImage:[[UIImage imageNamed:@"searchBar_cancel.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setBackgroundImage:[[UIImage imageNamed:@"searchBar_cancel_selected.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithWhite:1.0f alpha:1.0],
      UITextAttributeTextColor,
      [UIColor colorWithWhite:0.0f alpha:1.0],
      UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
      UITextAttributeTextShadowOffset,
      [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0f],
      UITextAttributeFont,
      nil] forState:UIControlStateNormal];
    
    [[UISearchBar appearance] setBackgroundImage:[UIImage imageNamed:@"sale_search_bg.png"]];
    
    /*
    UIImage *segmentSelected = [[UIImage imageNamed:@"segcontrol_sel"]resizableImageWithCapInsets:UIEdgeInsetsMake(1, 5, 1, 5)];
    UIImage *segmentUnselected = [[UIImage imageNamed:@"segcontrol_unsel"]resizableImageWithCapInsets:UIEdgeInsetsMake(1, 5, 1, 5)];
    UIImage *segmentSelectedUnselected = [UIImage imageNamed:@"segcontrol_sel-unsel"];
    UIImage *segUnselectedSelected = [UIImage imageNamed:@"segcontrol_unsel-sel"];
    UIImage *segmentUnselectedUnselected = [UIImage imageNamed:@"segcontrol_unsel-unsel"];
    
    [[UISegmentedControl appearance] setBackgroundImage:segmentUnselected
                                               forState:UIControlStateNormal
                                             barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setBackgroundImage:segmentSelected
                                               forState:UIControlStateSelected
                                             barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setDividerImage:segmentUnselectedUnselected
                                 forLeftSegmentState:UIControlStateNormal
                                   rightSegmentState:UIControlStateNormal
                                          barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setDividerImage:segmentSelectedUnselected
                                 forLeftSegmentState:UIControlStateSelected
                                   rightSegmentState:UIControlStateNormal
                                          barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setDividerImage:segUnselectedSelected
                                 forLeftSegmentState:UIControlStateNormal
                                   rightSegmentState:UIControlStateSelected
                                          barMetrics:UIBarMetricsDefault];
    */
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    prevSelectedIndex = selectedIndex;
    
    if([tabBar.items indexOfObject:item] == 2) {
        
        [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"TabBar" withAction:@"Create" withLabel:[NSString stringWithFormat:@"(%@)%@:%@", [[NSDate date] dateToUTCWithFormat:nil], [NSStringFromClass([self class]) substringToIndex:NSStringFromClass([self class]).length-10], @"press"] withValue:nil];
        
    }
    
    UIView * fromView = self.selectedViewController.view;
    UIView * toView = [[self.viewControllers objectAtIndex:[tabBar.items indexOfObject:item]] view];
    if(fromView==toView)
        return;

    [UIView transitionFromView:fromView
                        toView:toView
                      duration:0.2f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    completion:^(BOOL finished) {
                        selectedIndex = [tabBar.items indexOfObject:item]!=2? [tabBar.items indexOfObject:item]: selectedIndex;
                    }];
}

-(void)closeCreateTab
{
    if(self.selectedIndex==2)
    {
        [self tabBar:self.tabBar didSelectItem:[self.tabBar.items objectAtIndex:selectedIndex]];
        [self setSelectedIndex:selectedIndex];
    }
}

- (void)returnToPreviousTab {
    
    int prevSelection = prevSelectedIndex;
    
    [self tabBar:self.tabBar didSelectItem:[self.tabBar.items objectAtIndex:prevSelection]];
    [self setSelectedIndex:prevSelection];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setBadgeValueFromProfile:(NSNotification*) notification
{
    [self setBadgeValue:[NSString stringWithFormat:@"%@",[[Profile sharedProfile] messagesCount]] forBadgeAtIndex:3];
    [UIApplication sharedApplication].applicationIconBadgeNumber = [[[Profile sharedProfile] messagesCount] integerValue];
}

- (void)setBadgeValue:(NSString *)value forBadgeAtIndex:(NSInteger)index {
    
    [self removeBadgeFromItemAtIndex:index];
    if(value.integerValue==0)
        return;
    
    UIImageView *badgeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar_badge.png"]];
    [badgeImageView setFrame:CGRectMake(190+40, 0, 28.5, 28.5)];
    [badgeImageView setBackgroundColor:[UIColor clearColor]];
    [badgeImageView sizeToFit];
    
    //UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 5, 14, 14)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
    [label setFont:[UIFont boldSystemFontOfSize:15.0]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor whiteColor]];
    label.text = value;
    
    [label sizeToFit];
    
    [badgeImageView addSubview:label];
    
    if(value.length > 1 && value.length != 3) {
        [badgeImageView setFrame:CGRectMake(badgeImageView.frame.origin.x - 4, badgeImageView.frame.origin.y, badgeImageView.frame.size.width + 10, badgeImageView.frame.size.height)];
        [badgeImageView setImage:[badgeImageView.image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 14)]];
    }else if(value.length >= 3) {
        [badgeImageView setFrame:CGRectMake(badgeImageView.frame.origin.x - 6, badgeImageView.frame.origin.y, badgeImageView.frame.size.width + 10, badgeImageView.frame.size.height)];
        [badgeImageView setImage:[badgeImageView.image resizableImageWithCapInsets:UIEdgeInsetsMake(14, 14, 14, 14)]];
    }
    
    [label setFrame:CGRectMake(badgeImageView.frame.size.width / 2 - label.frame.size.width / 2, badgeImageView.frame.size.height / 2 - label.frame.size.height / 2 - 3, label.frame.size.width, label.frame.size.height)];
    
    badgeImageView.tag = 100 + index;
    
    [self.tabBar addSubview:badgeImageView];
}

- (void)removeBadgeFromItemAtIndex:(NSInteger)index {
    [[self.tabBar viewWithTag:100+index] removeFromSuperview];
}

-(void)statusBarDidClicked:(NSNotification*) notification
{
    NSDictionary* userInfo = [notification object];
    
    MessagesController* messController = [self.storyboard instantiateViewControllerWithIdentifier:@"MessagesController"];
    messController.dialog = [[Dialog alloc] initWithContents:@{@"ad" : @{@"id":userInfo[@"data"][@"aid"]},@"user":@{@"id" : userInfo[@"data"][@"uid"]}}];
    [((UINavigationController*)[[self viewControllers]objectAtIndex:self.selectedIndex]) pushViewController:messController animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_DID_RECEIVE_NOTIFICATION object:userInfo];
}

-(BOOL) isNeededDialogOpen:(NSDictionary*) dict
{
    id someViewController = [[self.viewControllers[self.selectedIndex] viewControllers] lastObject];
    if (![someViewController isKindOfClass:[MessagesController class]])
        return NO;
    MessagesController* dialogViewController = (MessagesController*) someViewController;
    if((((NSNumber*)dict[@"data"][@"aid"]).intValue == dialogViewController.dialog.ad.identifier.intValue) &&
       (((NSNumber*)dict[@"data"][@"uid"]).intValue == dialogViewController.dialog.user.identifier.intValue))
        return YES;
    return NO;
}

-(void) notifierDidReceived:(NSNotification*) notification
{
    NSDictionary* userInfo = (NSDictionary*)[notification userInfo];
    
    /*
     types:
    0 - message
    1 - global
    2 - balance
    */
    if([userInfo[@"type"] isEqualToNumber:@0])
    {
        
        BOOL isBackGroundState = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).isBackGroundState;
        
        if(isBackGroundState || userInfo[@"isBackgroundState"]) //если пуш пришел при выключенном и свернутом состоянии
        {
            [self setSelectedIndex:3];
            if([[[[self viewControllers]objectAtIndex:3] viewControllers] count]==1 && [Profile sharedProfile].token) //если в стеке диалогов тока один контроллер
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_DID_RECEIVE_NOTIFICATION object:userInfo];
                
                MessagesController* messController = [self.storyboard instantiateViewControllerWithIdentifier:@"MessagesController"];
                messController.dialog = [[Dialog alloc] initWithContents:@{@"ad" : @{@"id":userInfo[@"data"][@"aid"]},@"user":@{@"id" : userInfo[@"data"][@"uid"]}}];
                [((UINavigationController*)[[self viewControllers]objectAtIndex:3]) pushViewController:messController animated:YES];
            }
            else
                [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_REFRESH_DIALOG_IF_NEED object:userInfo]; 
        }
        else //уже были в приложении при получении пуша
        {
            if([self isNeededDialogOpen:userInfo]) //открыт ли соответствующий диалог
                [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_REFRESH_DIALOG_IF_NEED object:userInfo];
            else
                [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_SHOW_TEXT_IN_STATUSBAR object:userInfo];
        }
        
        if([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
            [self removeBadgeFromItemAtIndex:3];
            [[Profile sharedProfile] setMessagesCount:(NSString*)userInfo[@"badge"]];
        }else
            [self removeBadgeFromItemAtIndex:3];
    }
    else if ([userInfo[@"type"] isEqualToNumber:@1]) //@1 глобальный тип пуша
    {
        //баланс там всякая хуйня
        if(userInfo[@"data"])
        {
            [[[CGAlertView alloc] initWithTitle:@"iSeller" message:[NSString stringWithFormat:@"%@",userInfo[@"data"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
    else if ([userInfo[@"type"] isEqualToNumber:@2]) //@2 баланс
    {
        if(userInfo[@"data"])
        {
            if([Profile sharedProfile].balance)
            {
                [[[CGAlertView alloc] initWithTitle:@"iSeller" message:[NSString stringWithFormat:@"%@",userInfo[@"aps"][@"alert"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            
                if([userInfo[@"data"] isKindOfClass:[NSNumber class]])
                    [[Profile sharedProfile] setBalance: userInfo[@"data"]];
            }
        }
    }
}

- (void)enteredFromSite:(NSNotification *)notification {
    
    __weak __typeof(&*self)weakSelf = self;
    
    self.applicationActiveBlock = ^{
        
        if([[Profile sharedProfile] hasToken]) {
            
            UIView *blackView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
            
            [blackView setBackgroundColor:[UIColor blackColor]];
            
            UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            
            [activityView setCenter:blackView.center];
            
            [blackView addSubview:activityView];
            
            [activityView setHidden:NO];
            
            [activityView startAnimating];
            
            [([UIApplication sharedApplication].delegate).window addSubview:blackView];
                        
            AdvertisementController* adController = [weakSelf.storyboard instantiateViewControllerWithIdentifier:@"AdvertisementController"];
            
            [Advertisement getAdvertisementWithIdentifier:[notification userInfo][@"object"] success:^(Advertisement *ad) {
                
                for(NSDictionary *image in ad.images) {
                    
                    if(image[@"main_image"] && [image[@"main_image"] isEqualToNumber:@1]) {
                        
                        ad.image = image[@"url"];
                        
                    }
                    
                }
                
                adController.ad = [[Advertisement alloc] initWithContents:@{@"id" : ad.identifier, @"user_id" : ad.user.identifier, @"price" : ad.price, @"title" : ad.title, @"image" : ad.image.length && ad.image ? ad.image : @""}];
                                
                [blackView removeFromSuperview];
                
                [((UINavigationController*)[[weakSelf viewControllers] objectAtIndex:0]) pushViewController:adController animated:NO];
                                
            } failure:^(NSDictionary *dict, NSError *error) {
                
                [blackView removeFromSuperview];
                
            }];
                        
        }else{
            
            NSLog(@"Unauthorized");
            
        }
        
        
    };
    
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:@"EnteredFromSite"];
        
        if(self.applicationActiveBlock) {
                
            self.applicationActiveBlock();
            
            self.applicationActiveBlock = nil;
        }
    
    }else{
        
        [[NSNotificationCenter defaultCenter] removeObserver:@"EnteredFromSite"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAdvertisement) name:UIApplicationDidBecomeActiveNotification object:nil];
        
    }
}

- (void)showAdvertisement {
    
    if(self.applicationActiveBlock) {
        
        self.applicationActiveBlock();
        
        self.applicationActiveBlock = nil;
    }

    [[NSNotificationCenter defaultCenter] removeObserver:UIApplicationDidBecomeActiveNotification];

}

-(void)drawCreatingProgressView:(CreatingProgressView*)creatingProgressView
{
    if([self.tabBar.subviews containsObject:creatingProgressView]) {
        
        [creatingProgressView removeFromSuperview];
        
    }
    
    [self.tabBar addSubview:creatingProgressView];
    [creatingProgressView setCenter:CGPointMake(161, 25)];

}

#pragma mark - handling rotating 
-(BOOL)shouldAutorotate {
    
    return ([[[(UINavigationController*)self.selectedViewController viewControllers] lastObject]isKindOfClass:NSClassFromString(@"FullSizeController")] && self.allowRotatingFullSize);
}

//for iOS 5 

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    /*
    NSLog(@"%d",([[[(UINavigationController*)self.selectedViewController viewControllers] lastObject]isKindOfClass:NSClassFromString(@"FullSizeController")] && self.allowRotatingFullSize)?YES:((UIInterfaceOrientationPortrait==toInterfaceOrientation)?YES:NO));
    return ([[[(UINavigationController*)self.selectedViewController viewControllers] lastObject]isKindOfClass:NSClassFromString(@"FullSizeController")] && self.allowRotatingFullSize?YES:((UIInterfaceOrientationPortrait==toInterfaceOrientation)?YES:NO));
     */
    return (toInterfaceOrientation==UIInterfaceOrientationPortrait);
}

- (NSUInteger)supportedInterfaceOrientations {
    
    return ([[[(UINavigationController*)self.selectedViewController viewControllers] lastObject]isKindOfClass:NSClassFromString(@"FullSizeController")] && self.allowRotatingFullSize)?UIInterfaceOrientationMaskAll:UIInterfaceOrientationMaskPortrait;//Which is actually a default value
}

-(void)allowRotatingInFullSize:(NSNotification*)notification
{
    if(notification && notification.userInfo && notification.userInfo[@"allowRotate"])
        self.allowRotatingFullSize = [notification.userInfo[@"allowRotate"] boolValue];
}
@end


@implementation UITabBarController (ShowHide)

-(void)setHidden:(BOOL)hidden animated:(BOOL)animated
{
    static BOOL _hidden = NO;
    if(hidden==_hidden)
        return;
    dispatch_async( dispatch_get_main_queue(), ^{
        if(animated)
        {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            
            [self animation:hidden];
            
            [UIView commitAnimations];
        }
        else
            [self animation:hidden];
        _hidden = hidden;
    });
}

-(void)animation:(BOOL)hidden
{
    
    for(UIView *view in self.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
            [view setFrame:CGRectMake(view.frame.origin.x, (hidden) ? SCREEN_HEIGHT : TABBAR_Y_ORIGIN , view.frame.size.width, view.frame.size.height)];
        
        if(![view isKindOfClass:NSClassFromString(@"UITransitionView")])
            [view setAlpha:(!hidden)?1.0f:0.0f];
    }
}




@end


