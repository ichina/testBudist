//
//  TutorialController.m
//  iSeller
//
//  Created by Чингис on 26.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "TutorialController.h"


@interface TutorialController ()

@end

@implementation TutorialController

@synthesize isFirstPresentTutorial;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    if(IS_IPHONE5)
    {
        [backgroundView setFrame:CGRectMake(0, 0, 320, 568)];
        [self.scrollView setFrame:CGRectMake(0, 0, 320, 568)];
    }
    
    pages = [NSMutableArray new];
    
    int pageNumber = 3;
    
    [self.scrollView setDelegate:self];
    [self.scrollView setPagingEnabled:YES];
    [self.scrollView setContentSize:CGSizeMake(320*pageNumber, CGRectGetHeight(self.scrollView.frame))];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    
    [self setFirstPage];
    [self setSecondPage];
    //[self setThirdPage];
    [self setFourthPage];
    
    [self setPageControl];
    
    if(isFirstPresentTutorial)
    {
        [self.closeBtn setHidden:YES];
        [self setButtons];
        [backgroundView setIsFirstPresentTutorial:isFirstPresentTutorial];
        if(IS_IPHONE5)
            [pageControl setCenter:CGPointMake(pageControl.center.x, pageControl.center.y+44)];
    }else{
        //[self.scrollView setFrame:CGRectOffset(self.scrollView.frame, 0, 20)];
        [self.vkBtn removeFromSuperview];
        [self.fbBtn removeFromSuperview];
        [self.otherBtn removeFromSuperview];
        [self.scrollView setCenter:CGPointMake(self.scrollView.center.x, self.scrollView.center.y+30)];
        [pageControl setCenter:CGPointMake(pageControl.center.x, pageControl.center.y+(IS_IPHONE5?88:40))];
        
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setFirstPage
{
    TutorialPageView* pageView1 = [[TutorialPageView alloc] initWithFrame:self.scrollView.frame];
    [pageView1 addTitle:NSLocalizedString(@"PAGE_1_TITLE", nil)];
    [pageView1 addMirroredImage:(IS_RETINA?@"tutorial_1@2x.jpg":@"tutorial_1.jpg")];
    [pageView1 addContentOffset:-30];
    [pageView1 addLabel:NSLocalizedString(@"PAGE_1_LABEL_1", nil)];
    [pageView1 addLabel:NSLocalizedString(@"PAGE_1_LABEL_2", nil)];
    [pageView1 addLabel:NSLocalizedString(@"PAGE_1_LABEL_3", nil)];
    [self.scrollView addSubview:pageView1];
    [self hideAllSubviewForView:pageView1];
    [pages addObject:pageView1];
    
    [self beginAnimationForView:pageView1];

}

-(void)setSecondPage
{
    TutorialPageView* pageView1 = [[TutorialPageView alloc] initWithFrame:CGRectOffset(self.scrollView.frame, 320, 0)];
    [pageView1 addTitle:NSLocalizedString(@"PAGE_2_TITLE", nil)];
    [pageView1 addContentOffset:-30];
    [pageView1 addMirroredImage:(IS_RETINA?@"tutorial_2@2x.jpg":@"tutorial_2.jpg") withGradientToTopOffset:55]; // отступ сверху
    [pageView1 addContentOffset:-40];

    [pageView1 addLabel:NSLocalizedString(@"PAGE_2_LABEL_1", nil)];
    [pageView1 addLabel:NSLocalizedString(@"PAGE_2_LABEL_2", nil)];
    //[pageView1 addLabel:NSLocalizedString(@"PAGE_2_LABEL_3", nil)];
    //[pageView1 addLabel:NSLocalizedString(@"PAGE_2_LABEL_4", nil)];

    [self.scrollView addSubview:pageView1];
    [self hideAllSubviewForView:pageView1];
    [pages addObject:pageView1];
}

-(void)setThirdPage
{
    TutorialPageView* pageView1 = [[TutorialPageView alloc] initWithFrame:CGRectOffset(self.scrollView.frame, 320*2, 0)];
    [pageView1 addTitle:NSLocalizedString(@"PAGE_3_TITLE", nil)];
    
    [pageView1 addMirroredImage:(IS_RETINA?@"tutorial_3@2x.jpg":@"tutorial_3.jpg")];
    [pageView1 addContentOffset:-30];
    [pageView1 addLabel:NSLocalizedString(@"PAGE_3_LABEL_1", nil)];
    
    [self.scrollView addSubview:pageView1];
    [self hideAllSubviewForView:pageView1];
    [pages addObject:pageView1];
}

-(void)setFourthPage
{
    TutorialPageView* pageView1 = [[TutorialPageView alloc] initWithFrame:CGRectOffset(self.scrollView.frame, 320*2, 0)]; //было 320*3
    
    [pageView1 addTitle:NSLocalizedString(@"PAGE_4_TITLE", nil)];
    
    [pageView1 addLabel:NSLocalizedString(@"PAGE_4_LABEL_1", nil)];
    [pageView1 addContentOffset:-30];
    [pageView1 addMirroredImage:(IS_RETINA ? @"tutorial_4@2x.jpg":@"tutorial_4.jpg") withGradientToTopOffset:50];
    [pageView1 addContentOffset:-20];
    [pageView1 addLabel:NSLocalizedString(@"PAGE_4_LABEL_2", nil)];
    [pageView1 addLabel:NSLocalizedString(@"PAGE_4_LABEL_3", nil)];
    //[pageView1 addLabel:NSLocalizedString(@"PAGE_4_LABEL_4", nil)];
    
    [self.scrollView addSubview:pageView1];
    
    [self hideAllSubviewForView:pageView1];
    [pages addObject:pageView1];
}

-(void)setPageControl
{
    pageControl = [[TutorialPageControl alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    [pageControl setNumberOfPages:3]; //было 4
    [pageControl setCenter:CGPointMake(160+10, (IS_IPHONE5?568:480) - 60 - (IS_IPHONE5?88:0))];
    [self.view addSubview:pageControl];
}

-(void)setButtons
{
    //self.fbBtn.titleLabel.text = @"Facebook";
    UILabel* title = [[UILabel alloc] init];
    title.text = @"Войти";
    title.shadowColor = [UIColor colorWithWhite:0 alpha:0.7f];
    title.shadowOffset = CGSizeMake(0, 1);
    title.textColor = [UIColor whiteColor];
    [title sizeToFit];
    [title setFrame:CGRectOffset(title.frame, 48, 7)];
    [title setBackgroundColor:[UIColor clearColor]];
    title.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    [self.fbBtn addSubview:[self labelWithTitle:NSLocalizedString(@"Tutorial Sign In", nil)]];
    [self.vkBtn addSubview:[self labelWithTitle:NSLocalizedString(@"Tutorial Sign In", nil)]];
    [self.otherBtn addSubview:[self labelWithTitle:NSLocalizedString(@"More", nil)]];
    //[self.vkBtn addSubview:title.copy];
    //[self.otherBtn addSubview:title.copy];
}

-(UILabel*)labelWithTitle:(NSString*)titleStr
{
    UILabel* title = [[UILabel alloc] init];
    title.text = titleStr;
    title.shadowColor = [UIColor colorWithWhite:0 alpha:0.7f];
    title.shadowOffset = CGSizeMake(0, 1);
    title.textColor = [UIColor whiteColor];
    [title sizeToFit];
    //[title setFrame:CGRectOffset(title.frame, 48, 7)];
    [title setCenter:CGPointMake(73, title.center.y+7)];
    [title setBackgroundColor:[UIColor clearColor]];
    title.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    return title;
}

- (void)viewDidUnload {
    backgroundView = nil;
    [self setScrollView:nil];
    [self setFbBtn:nil];
    [self setVkBtn:nil];
    [self setOtherBtn:nil];
    [self setCloseBtn:nil];
    [super viewDidUnload];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int currentPage = (int)(scrollView.contentOffset.x+160)/320;
    //static int prevPage;
    
    if(currentPage>2)//за пределы максимального индекса
        currentPage = 2;
    
    if(pageControl.currentPage != currentPage)
        [pageControl setCurrentPage:currentPage];
    
    //currentPage = (int)(scrollView.contentOffset.x-30)/320;
    
    float distance = scrollView.contentOffset.x-currentPage*320;
    
    if(distance<0)
        distance = -distance;
    float ratio = 1 - distance/320;
    ratio = ratio<=0?0:ratio;
    [(TutorialPageView*)pages[currentPage] setAlpha:ratio];
    if(currentPage+1<pages.count)
        [(TutorialPageView*) pages[currentPage+1] setAlpha:1-ratio];
    if(currentPage-1>=0)
        [(TutorialPageView*) pages[currentPage-1] setAlpha:1-ratio];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int currentPage = (int)(scrollView.contentOffset.x)/320;
    TutorialPageView* currentPageView = pages[currentPage];
    
    [self beginAnimationForView:currentPageView];
}

-(void)beginAnimationForView:(TutorialPageView*) pageView
{
    [UIView animateWithDuration:0.3f animations:^{
        [pageView.subviews[1] setAlpha:1.0f];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.6f animations:^{
            for(UIView* view in pageView.subviews)
                if([view isKindOfClass:[TutorialImageView class]])
                    [view setAlpha:1.0f];
            if(pageView == pages[2])    // было pages[3] 
                [pageView.subviews[2] setAlpha:1.0f];
        } completion:^(BOOL finished) {
            [self animateToFullAlphaForIndex:2 inView:pageView];
        }];
    }];
}

-(void)animateToFullAlphaForIndex:(int)index inView:(TutorialPageView*) pageView
{
    if(index<pageView.subviews.count)
    {
        if([pageView.subviews[index] isKindOfClass:[TutorialLabel class]])
            [UIView animateWithDuration:0.6f animations:^{
                [pageView.subviews[index] setAlpha:1.0f];
            } completion:^(BOOL finished) {
                
                [self animateToFullAlphaForIndex:index+1 inView:pageView];
            }];
        else
            [self animateToFullAlphaForIndex:index+1 inView:pageView];
    }
}

-(void)hideAllSubviewForView:(UIView*)view
{
    for(UIView* subview in view.subviews)
        [subview setAlpha:0];
}

- (IBAction)closeTutorial:(id)sender {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (IBAction)closeBtnClicked:(id)sender {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)authWithFB:(id)sender {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_NEED_AUTH_WITH_SOCIAL object:self userInfo:@{@"provider":@"fb"}];
    }];
}

- (IBAction)authWithVk:(id)sender {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_NEED_AUTH_WITH_SOCIAL object:self userInfo:@{@"provider":@"vk"}];
    }];
}

- (IBAction)authWithOther:(id)sender {
    //[[UIApplication sharedApplication] setStatusBarHidden:NO];
    /*[self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_NEED_AUTH_WITH_SOCIAL object:self];
    }];*/
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    NSArray* array = @[NSLocalizedString(@"Sign in", nil),NSLocalizedString(@"Sign up", nil)];
    for (NSString *fruit in array) {
        [actionSheet addButtonWithTitle:fruit];
    }
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet showInView:self.view];
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
        if(buttonIndex==0)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_NEED_AUTH_WITH_SOCIAL object:self];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_NEED_AUTH_WITH_SOCIAL object:self userInfo:@{@"provider":@"own"}];
        }
    }
}

@end
