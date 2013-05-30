//
//  MessagesControllerViewController.m
//  iSeller
//
//  Created by Чина on 17.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "MessagesController.h"
#import "NavigationHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "AdvertisementController.h"
#import "Profile.h"
#import "MessageCell.h"

static int profileTokenContext;

@interface MessagesController ()

@end

@implementation MessagesController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        messagesDataSource = [MessagesDataSource new];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataSource:) name:CHINAS_NOTIFICATION_MESSAGES_DATA_SOURCE_UPDATED object:messagesDataSource];
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillShow:)
													 name:UIKeyboardWillShowNotification
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillHide:)
													 name:UIKeyboardWillHideNotification
												   object:nil];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:messagesDataSource];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:BG_IMAGE]]];
    
    [self.tableView setContentOffset:CGPointMake(0,self.tableView.contentSize.height-self.tableView.frame.size.height) animated:YES];
    
    messagesDataSource.dialog = self.dialog;
    isDataLoading=YES;
    
    if([Profile sharedProfile].hasToken) {
        
        [self needUpdateDataWithOption:updateDataWithReset];
        
    }else{
        
        [[Profile sharedProfile] addObserver:self forKeyPath:@"token" options:NSKeyValueObservingOptionNew context:&profileTokenContext];
        
    }
        
    [self setContainerView];
    
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    [footerView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setTableFooterView:footerView];
    
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    [self setNavigationHeader];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dialogs_no_content.png"]];
    [backgroundView sizeToFit];
    [backgroundView setCenter:CGPointMake(self.tableView.center.x, self.tableView.center.y)];
    [backgroundView setTag:123654];
    [self.view insertSubview:backgroundView atIndex:0];
    
    //[self.tableView addObserver:self forKeyPath:@"contentSize" options:0 context:&tableContentSizeObservanceContext];
    //[self.tableView addObserver:self forKeyPath:@"frame" options:0 context:&tableFrameObservanceContext];

}

-(void)setNavigationHeader
{
    NavigationHeaderView *headerView = [[NavigationHeaderView alloc] initWithFrame:CGRectMake(0, 0, 180, 44)];
    [headerView setTitleLabelText:self.dialog.ad.title];
    [headerView setSubtitleLabelText:self.dialog.user.name];
    
    [self.navigationItem setTitleView:headerView];
    
    [self setRightImage];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController setHidden:YES animated:YES];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needUpdateUI:) name:CHINAS_NOTIFICATION_NEED_UPDATE_UI_IN_DIALOG object:nil];
}
-(void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHINAS_NOTIFICATION_NEED_UPDATE_UI_IN_DIALOG object:nil];
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    [super viewWillDisappear:animated];
}

-(void) needUpdateDataWithOption:(updateDataOption)updateDataOption
{
    if(updateDataOption==updateDataLoadNext)
        isDataLoading = YES;
    
    needScrollToBottom = updateDataOption!=updateDataLoadNext;
    
    [messagesDataSource updateDataWithOption:updateDataOption];
}

-(void)reloadDataSource:(NSNotification *) notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        isDataLoading = NO;
        if(notification.userInfo)
        {
            int newCount = [notification.userInfo[@"newCount"] integerValue];
            if(newCount)
            {
                //[self.tableView setTableHeaderView:nil];
                NSMutableArray* array = [NSMutableArray new];
                for (int i = 0 ; i < newCount ; i++) {
                    [array addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                }
                [[self.view viewWithTag:123654] removeFromSuperview];
                
                if([self.tableView numberOfRowsInSection:0]+newCount>=array.count)//слепая броня by china
                    [self.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationAutomatic];
                
                [self.tableView scrollToRowAtIndexPath:array.lastObject atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
            
        }
        else //это когда сам написал сообщение, обновляю таблицу
        {
//
            [self.tableView reloadData];
            /*
            if(self.tableView.contentSize.height<self.tableView.frame.size.height)
            {
                [self.tableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, self.tableView.frame.size.height-self.tableView.contentSize.height)]];
            }
            else
                [self.tableView setTableHeaderView:nil];
             */
            
            /*
            if([self.tableView numberOfRowsInSection:0]!=0)
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0]-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            */
            needScrollToBottom = YES;
            if([self.tableView numberOfRowsInSection:0] > 0) {
                
                [[self.view viewWithTag:123654] removeFromSuperview];
                
            }else{
                
                [[self.view viewWithTag:123654] removeFromSuperview];
                
                UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dialogs_no_content.png"]];
                [backgroundView sizeToFit];
                [backgroundView setCenter:CGPointMake(self.tableView.center.x, self.tableView.center.y)];
                [backgroundView setTag:123654];
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, backgroundView.frame.size.width + 100, 50)];
                [label setText:NSLocalizedString(@"Send message to begin dialog", nil)];
                [label setNumberOfLines:2];
                [label setBackgroundColor:[UIColor clearColor]];
                [label setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
                [label setTextColor:[UIColor colorWithRed:196.0/255.0 green:200.0/255.0 blue:207.0/255.0 alpha:1.0f]];
                [label setTextAlignment:NSTextAlignmentCenter];
                [label setCenter:CGPointMake(backgroundView.frame.size.width/2, backgroundView.frame.size.height + label.frame.size.height/2)];
                [label setShadowColor:[UIColor blackColor]];
                [label setShadowOffset:CGSizeMake(0, 1)];
                
                [backgroundView addSubview:label];
                
                //[self.view addSubview:backgroundView];
                [self.view insertSubview:backgroundView atIndex:0];
            }
        }
        
        if(needScrollToBottom) {
            if(self.tableView.contentSize.height>=self.tableView.frame.size.height)
                [self.tableView setContentOffset:CGPointMake(0,self.tableView.contentSize.height-self.tableView.frame.size.height) animated:YES];
        }

    });
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [messagesDataSource calculateHeightForRow:indexPath.row];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - CONTAINER_VIEW Definition & Delegating

-(void)setContainerView
{
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 40, 320, 40)];
    
	textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 3, 240, 40)];
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
	textView.minNumberOfLines = 1;
	textView.maxNumberOfLines = 4;
	textView.returnKeyType = UIReturnKeyGo; //just as an example
	textView.font = [UIFont systemFontOfSize:15.0f];
	textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor whiteColor];
    
    // textView.text = @"test\n\ntest";
	// textView.animateHeightChange = NO; //turns off animation
    
    [self.view addSubview:containerView];
	
    UIImage *rawEntryBackground = [UIImage imageNamed:@"MessageEntryInputField.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView.frame = CGRectMake(5, 0, 248, 40);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
    [containerView addSubview:imageView];
    [containerView addSubview:textView];
    [containerView addSubview:entryImageView];
    
    UIImage *sendBtnBackground = [[UIImage imageNamed:@"dialog_sendBtn.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(29, 15, 29, 15)];
    //UIImage *selectedSendBtnBackground = [UIImage imageNamed:@"dialog_sendBtn.png"];
    
	sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	sendBtn.frame = CGRectMake(containerView.frame.size.width - 69, 7, 65, 29);
    sendBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	//[doneBtn setTitle:@"Done" forState:UIControlStateNormal];
    
	[sendBtn addTarget:self action:@selector(sentMessage:) forControlEvents:UIControlEventTouchUpInside];
    [sendBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
    [sendBtn setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    
    [sendBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
    
    [sendBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    //[doneBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
	[containerView addSubview:sendBtn];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [textView becomeFirstResponder];
    
    UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sentBtnTapped:)];
    [sendBtn addGestureRecognizer:tapGestureRecognizer];
    
}


-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	containerView.frame = containerFrame;
	[self.tableView setFrame:CGRectMake(0, 0, 320, containerFrame.origin.y)];
    [self.tableView scrollRectToVisible:self.tableView.tableFooterView.frame animated:NO];
    // commit animations
    
    if([self.view viewWithTag:123654])
    {
        [[self.view viewWithTag:123654] setCenter:CGPointMake(self.tableView.center.x, self.tableView.center.y)];;
    }
    
	[UIView commitAnimations];
}


-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	// get a rect for the textView frame
	CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
	containerView.frame = containerFrame;
    [self.tableView setFrame:CGRectMake(0, 0, 320, containerFrame.origin.y)];
    [self.tableView scrollRectToVisible:self.tableView.tableFooterView.frame animated:NO];
    
    if([self.view viewWithTag:123654])
    {
        [[self.view viewWithTag:123654] setCenter:CGPointMake(self.tableView.center.x, self.tableView.center.y-42)];;
    }
    
    if(needScrollToBottom) {
        
        if(self.tableView.contentSize.height>=self.tableView.frame.size.height)
            [self.tableView setContentOffset:CGPointMake(0,self.tableView.contentSize.height-self.tableView.frame.size.height) animated:YES];
    
    }
    
    
	[UIView commitAnimations];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	containerView.frame = r;
}

-(void)sentBtnTapped:(UIGestureRecognizer *)sender
{
    if(textView.text.length > 0 && ![textView.text isEqualToString:@" "] && ![textView.text isEqualToString:@"\n"] && ![textView.text hasPrefix:@"\n"]) {
        
        if(sendBtn.isEnabled) {
            
            NSLog(@"SentBtn enabled");
            
            switch (sender.state) {
                case UIGestureRecognizerStateBegan:
                {
                    [sendBtn setHighlighted:YES];
                }
                    break;
                case UIGestureRecognizerStateEnded:
                {
                    [sendBtn setHighlighted:NO];
                    [self sentMessage:nil];
                }
                default:
                    break;
            }
        }
    }
}

-(void)sentMessage:(id) sender
{
    
    [self sendEventWithCategory:@"Messages" action:@"Send button pressed" label:@"" value:nil];
    
    NSString* textBody = [self processMessageText:textView.text];
    if(textBody)
    {
        [messagesDataSource sendMessage:[self processMessageText:textView.text]];
        
        [self reloadDataSource:nil];

        textView.text = @"";
        
        //[self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height-(self.tableView.contentSize.height>self.tableView.bounds.size.height ? self.tableView.bounds.size.height : 0)+44) animated:YES];
        
        //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0]-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_DIALOG_NEED_MOVE_TO_TOP object:self.dialog];
    }
}
-(NSString*)processMessageText:(NSString*) text
{
    if(textView.text.length > 0 && ![textView.text isEqualToString:@" "] && !([textView.text isEqualToString:@"\n"] && textView.text.length==1)) {
        for(int i = 0 ; i < textView.text.length ; i++ )
        {
            NSString* charStr = [text substringToIndex:1];
            if([charStr isEqualToString:@" "] || [charStr isEqualToString:@"\n"])
                text = [text substringFromIndex:1];
            else
                return text.length!=0? text : nil;
        }
    }else
        return nil;
    return text.length!=0? text : nil;
}

-(void)dismissKeyboard {
    
    [textView resignFirstResponder];
}

- (void)setRightImage {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder.png"]];
    [imageView.layer setCornerRadius:4.0f];
    [imageView.layer setBorderWidth:0.5f];
    [imageView.layer setBorderColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:7.0].CGColor];
    [imageView.layer setMasksToBounds:YES];
    [imageView setImageWithURL:[NSURL URLWithString:self.dialog.ad.smallImage] placeholderImage:imageView.image];
    
    [imageView setUserInteractionEnabled:YES];
    [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemPicturePressed)]];
    
    [imageView setFrame:CGRectMake(0, 0, 34, 34)];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    [self.navigationItem setRightBarButtonItem:item];
}
-(void)itemPicturePressed
{
    if([self.navigationController.viewControllers[self.navigationController.viewControllers.count-2] isKindOfClass:([Advertisement class])])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }else
    {
        [self performSegueWithIdentifier:kSegueFromDialogToAd sender:nil];
    }
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:kSegueFromDialogToAd])
    {
        ((AdvertisementController*)segue.destinationViewController).ad = self.dialog.ad;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)needUpdateUI:(NSNotification*)notification
{
    self.dialog = (Dialog*) notification.object;
    messagesDataSource.dialog = self.dialog;
    
    [self setNavigationHeader];
    
    [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!isDataLoading && self.tableView.contentOffset.y==0) {
        [self needUpdateDataWithOption:updateDataLoadNext];

    }
}
- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    
    if (action == @selector(copy:))
    {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *) tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    MessageCell *cell = (MessageCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    if(action == @selector(copy:))
    {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:cell.body.text];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &profileTokenContext) {
        
        if([[change objectForKey:@"new"] length] > 0) {
            
            [self needUpdateDataWithOption:updateDataWithReset];
            
            [[Profile sharedProfile] removeObserver:self forKeyPath:@"token"];
            
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
