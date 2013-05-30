//
//  FullSizeController.m
//  iSeller
//
//  Created by Чина on 29.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "FullSizeController.h"
#import <AFNetworking.h>
#import "UIImage+scale.h"
#import "OriginalPhotoView.h"
@interface FullSizeController ()

@end

@implementation FullSizeController
@synthesize imageUrls;
@synthesize ad;
@synthesize index;
@synthesize images;

@synthesize backButton;

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)viewDidLoad
{
    self.skipAuth = YES;
    
    [super viewDidLoad];
    
    [self drawImages];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewClicked)];
    [scrollView addGestureRecognizer:tapGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI:) name:CHINAS_NOTIFICATION_AD_RECEIVED object:nil];
    
    self.topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self.backButton setExclusiveTouch:YES];
    
}

-(void) drawImages
{
    OriginalPhotoView* prevImage;
    if (imageUrls && imageUrls.count==1)
    {
        prevImage = (OriginalPhotoView*) imageUrls[0];
        [imageUrls removeAllObjects];
        imageUrls = nil;
    }
    imageUrls = [[NSMutableArray alloc] init];
    images = [[NSMutableArray alloc] initWithArray:ad.images];
    
    if(images.count>index)
        for( int i = 0 ; i < index ; i++ )
        {
            [images addObject:images[0]];
            [images removeObjectAtIndex:0];
        }
    
    for(NSObject* object in images)
    {
        if(prevImage && [images indexOfObject:object]==0)
        {
            [imageUrls addObject:prevImage];
            continue;
        }
        if([object isKindOfClass:[NSDictionary class]])
        {
            NSURL* imageUrl = [NSURL URLWithString:[(NSString*) [(NSDictionary*)object objectForKey:@"url"] stringByReplacingOccurrencesOfString:@"/medium/" withString:@"/original/"]];
            [imageUrls addObject:[[OriginalPhotoView alloc] initWithURL:imageUrl]];
        }
        else //kindOfClass NSString))
        {
            NSURL* imageUrl = [NSURL URLWithString:[(NSString*)object stringByReplacingOccurrencesOfString:@"/medium/" withString:@"/original/"]];
            [imageUrls addObject: [[OriginalPhotoView alloc] initWithURL:imageUrl]];
        }
    }
    
    if(imageUrls.count!=1)
    {
        NSObject* object = images[0];
        if([object isKindOfClass:[NSDictionary class]])
        {
            NSURL* imageUrl = [NSURL URLWithString:[(NSString*) [(NSDictionary*)object objectForKey:@"url"] stringByReplacingOccurrencesOfString:@"/medium/" withString:@"/original/"]];
            [imageUrls addObject:[[OriginalPhotoView alloc] initWithURL:imageUrl]];
        }
        else //kindOfClass NSString))
        {
            NSURL* imageUrl = [NSURL URLWithString:[(NSString*)object stringByReplacingOccurrencesOfString:@"/medium/" withString:@"/original/"]];
            [imageUrls addObject: [[OriginalPhotoView alloc] initWithURL:imageUrl]];
        }
        object = images.lastObject;
        if([object isKindOfClass:[NSDictionary class]])
        {
            NSURL* imageUrl = [NSURL URLWithString:[(NSString*) [(NSDictionary*)object objectForKey:@"url"] stringByReplacingOccurrencesOfString:@"/medium/" withString:@"/original/"]];
            [imageUrls insertObject:[[OriginalPhotoView alloc] initWithURL:imageUrl] atIndex:0];
        }
        else //kindOfClass NSString))
        {
            NSURL* imageUrl = [NSURL URLWithString:[(NSString*)object stringByReplacingOccurrencesOfString:@"/medium/" withString:@"/original/"]];
            [imageUrls insertObject:[[OriginalPhotoView alloc] initWithURL:imageUrl] atIndex:0];
        }
    }
    
    self.lblTitle.text = ad.title;
    self.lblUserName.text = ad.user.name;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:ad.user.avatar]];
    [request setHTTPShouldHandleCookies:NO];
    if(!self.avatar.image)
        [self.avatar setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            [self.avatar setImage:[image roundCornerImageWithWidth:7 height:7]];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            [self.avatar setImage:[[UIImage imageNamed:@"smile.png"] roundCornerImageWithWidth:7 height:7]];
        }];
    
    
    [scrollView setContentSize:CGSizeMake((imageUrls.count+((imageUrls.count==1)?0:2))*scrollView.frame.size.width, 480)];
    
    [self.topView setFrame:CGRectMake(0, 0, scrollView.frame.size.width, 44)];
    [self.topView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7f]];
    
    for(int i = 0; i < imageUrls.count ; i++)
    {
        OriginalPhotoView* originalPhotoView = imageUrls[i];
        originalPhotoView.center = CGPointMake(originalPhotoView.center.x+i*320, scrollView.center.y+20);
        [scrollView addSubview:originalPhotoView];
    }
    /*
    for(UIView* view in imageUrls)
    {
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    */
    pageNumber = 1;
    if(imageUrls.count!=1)
    {
        [(OriginalPhotoView*)imageUrls[1] viewWillShow];
        [scrollView scrollRectToVisible:CGRectMake(320,0,320,416) animated:NO];
    }
    else
    {
        [(OriginalPhotoView*)imageUrls[0] viewWillShow];
    }
    
    
    [pageControl setNumberOfPages:images.count];
    [pageControl setCurrentPage:0];
}

- (void)becomeActive {
    pageControl.alpha = 1.0f;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.topView setAlpha:1.0f];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - scrollview delegate method's

-(void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
    int tempindex = CGRectGetMidX(scrollView.bounds)/CGRectGetWidth(scrollView.frame);
    //NSLog(@"%d",tempindex);
    if(tempindex!=pageNumber)
    {
        //NSLog(@"index %d",tempindex);
        if(tempindex==0)
        {
            [scrollView setContentOffset:CGPointMake(scrollView.frame.size.width*(imageUrls.count-2)+scrollView.contentOffset.x, 0)];
            [(OriginalPhotoView*)imageUrls[tempindex] viewWillShow];
            tempindex=imageUrls.count-2;
        }
        else
        if(tempindex==imageUrls.count-1)
        {
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x-(CGRectGetWidth(scrollView.frame)*(tempindex-1)), 0)];
            [(OriginalPhotoView*)imageUrls[tempindex] viewWillShow];
            tempindex=1;
        }
        pageNumber = tempindex;
        [pageControl setCurrentPage:(pageNumber-1)%images.count];
        
        if(pageNumber<imageUrls.count)
            [(OriginalPhotoView*)imageUrls[pageNumber] viewWillShow];
        
    }
}

- (IBAction)backBtnClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewClicked
{
    if(pageControl.alpha==0.0f)
    {
        [UIView animateWithDuration:0.3f animations:^{
            pageControl.alpha = 1.0f;
            [self.topView setAlpha:1.0f];
        }];
        

        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
    else
    {
        [UIView animateWithDuration:0.3f animations:^{
            pageControl.alpha = 0.0f;
            [self.topView setAlpha:0.0f];
        }];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
}


-(void)updateUI:(NSNotification*) notification
{
    [self updateUIWithDict:(Advertisement*)[notification object]];
}
-(void)updateUIWithDict:(Advertisement*)_ad
{
    ad = _ad;
    [self drawImages];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate {
    return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [scrollView setDelegate:nil];
    
    float neededWidht = (toInterfaceOrientation==UIInterfaceOrientationLandscapeLeft||toInterfaceOrientation==UIInterfaceOrientationLandscapeRight)? (IS_IPHONE5?568:480):320;
    //[(OriginalPhotoView*)imageUrls[(imageUrls.count==1)?0:pageNumber] frame].size.width==320?(IS_IPHONE5?568:480):320;
    float neededHeight = neededWidht==320 ? (IS_IPHONE5?568:480) : 320;
    
    [scrollView setContentSize:CGSizeMake(neededWidht*imageUrls.count, neededHeight)];
    
    [UIView animateWithDuration:duration animations:^{
        
        [scrollView setContentOffset:CGPointMake(neededWidht*((imageUrls.count==1)?0:pageNumber), 0)];
        
        for (UIView* view in imageUrls) {
            [view setFrame:CGRectMake(neededWidht*([imageUrls indexOfObject:view]), [UIApplication sharedApplication].statusBarHidden?20:0, neededWidht, neededHeight)];
        }
        if([UIApplication sharedApplication].statusBarHidden)
        {
            [self.topView setCenter:CGPointMake(self.topView.center.x, self.topView.frame.size.height/2+20)];
        }
        else
        {
            [self.topView setCenter:CGPointMake(self.topView.center.x, self.topView.frame.size.height/2)];
        }
        
    }];
    
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [scrollView setDelegate:self];
}

- (void)viewDidUnload {
    scrollView = nil;
    scrollView = nil;
    pageControl = nil;
    [self setTopView:nil];
    [self setAvatar:nil];
    [self setLblTitle:nil];
    [self setLblUserName:nil];
    [self setBackButton:nil];
    [super viewDidUnload];
}
@end
