//
//  EditAdController.m
//  iSeller
//
//  Created by Чина on 31.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "EditAdController.h"
#import "CustomCellForSelecting.h"
#import "LocationManager.h"
#import "PriceFormatter.h"
#import "NSString+Extensions.h"
#import "Advertisement.h"
#import "UIImage+scale.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "UIView+Extensions.h"

#define LABELTAG 51
#define SWITCHTAG 52
#define TEXTVIEWTAG 53

#define TEXT_FIELD_PRICE_TAG 49
#define TEXT_FIELD_TITLE_TAG 50

#define PANEL_TAG 58

@interface EditAdController ()

@end

@implementation EditAdController
@synthesize ad;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        attachments = [[NSMutableArray alloc] init];
        oldImages = [[NSMutableArray alloc] init];
        
    }
    return self;
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    
    [self.view endEditing:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setFrame:CGRectMake(0, self.tableView.frame.origin.y, self.tableView.frame.size.width, 450)];
    [self.scrollView setDelegate:self];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:BG_IMAGE]]];
    
	// Do any additional setup after loading the view.
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(create:)];
    [self.navigationItem setRightBarButtonItem:rightBtn animated:YES];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollTapped:)];
    [self.horizontalScrollView addGestureRecognizer:tapGesture];
    [tapGesture setCancelsTouchesInView:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redrawViewWithNotifier:) name:CHINAS_NOTIFICATION_AD_RECEIVED object:nil];
    if(ad.descriptionText && ad.descriptionText.length)
        [self redrawView];
    
    [self calculateStatusAd];
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width, 480-(enabledStatuses.count<3 ? 44*(3-enabledStatuses.count):0))];
    /*
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 311, 56)];
    [btn setBackgroundImage:[[UIImage imageNamed:@"auth_sign_in.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)] forState:UIControlStateNormal];
    [btn setBackgroundImage:[[UIImage imageNamed:@"auth_sign_in_sel.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)] forState:UIControlStateHighlighted];
    [btn setTitle:@"Удалить" forState:UIControlStateNormal];
    btn.titleLabel.textColor = [UIColor whiteColor];
    btn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0f];
    [btn setCenter:CGPointMake(self.view.center.x, 445+(enabledStatuses.count-2)*44)];
    
    [btn addTarget:self action:@selector(deleteAd) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:btn];
    */ //до лучших времен
    
    [self setDonePanel]; //панелька над клавиатурой с кнопкой готово
    
}

-(void) viewWillDisappear:(BOOL)animated {
    [self stopAnimation];
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    [super viewWillDisappear:animated];
}

-(void)redrawViewWithNotifier:(NSNotification*) notification
{
    ad = (Advertisement*)[notification object];
    [self redrawView];
}
-(void)redrawView
{
    if(!self.horizontalScrollView)
        return;
    else  ///obrabotka bleat' exception'a если пост прилетит между сеттом ad и viewDidLoad
    {
        for(UIView* view in self.horizontalScrollView.subviews)
        {
            if([view isKindOfClass:([PhotoItem class])])
                [view removeFromSuperview];
        }
        [attachments removeAllObjects];
    }
    
    [self.tableView reloadData];
    for(int i =0 ; i < ad.images.count ; i++)
    {
        UIImageView* imageView = [[UIImageView alloc] init];

        [attachments insertObject:[NSNumber numberWithInt:[ad.images[i][@"id"] intValue]] atIndex:0];
        PhotoItem* item = [[PhotoItem alloc] initWithImage:[[[UIImage imageNamed:@"placeholder.png"] imageByScalingAndCroppingForSize:CGSizeMake(150, 150)] roundCornerImageWithWidth:10 height:10]];
        [item setDelegate:self];
        item.tag = 49;
        
        [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:ad.images[i][@"url"]]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            [item.photoBtn setImage:[image roundCornerImageWithWidth:10 height:10] forState:UIControlStateNormal];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
        }];
        
        [item setCenter:CGPointMake(-50, 43)];
        [self.horizontalScrollView addSubview:item];
        [item addBtnToBeginForScroll];
        [self.horizontalScrollView setContentSize:CGSizeMake(item.frame.size.width*attachments.count, self.horizontalScrollView.contentSize.height)];
        
        if ([ad.images[i][@"main_image"] boolValue]) {
            [item addFlag];
            mainImg = [NSNumber numberWithInt:-i];
        }
    }
}
#pragma mark - TableViewDataSource Method's

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return !section ? 3 : enabledStatuses.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row==2 && !indexPath.section && descCellEdited)? 88 : 44;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCellForSelecting *cell;
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell = (CustomCellForSelecting*)[tableView dequeueReusableCellWithIdentifier:@"PlaceHolderCell"];
                    [(UITextField*)[cell viewWithTag:TEXT_FIELD_TITLE_TAG] setPlaceholder:@"Название"];
                    [(UITextField*)[cell viewWithTag:TEXT_FIELD_TITLE_TAG] setText:ad.title];
                    [(UITextField*)[cell viewWithTag:TEXT_FIELD_TITLE_TAG] setDelegate:self];
                    [cell setHighlightionStyle:CellHighlightionNone];
                    break;
                case 1:
                    cell = (CustomCellForSelecting*)[tableView dequeueReusableCellWithIdentifier:@"PlaceHolderCell"];
                    [(UITextField*)[cell viewWithTag:TEXT_FIELD_TITLE_TAG] setPlaceholder:@"Цена"];
                    [(UITextField*)[cell viewWithTag:TEXT_FIELD_TITLE_TAG] setTag:TEXT_FIELD_PRICE_TAG];

                    [(UITextField*)[cell viewWithTag:TEXT_FIELD_PRICE_TAG] setText:[[NSString stringWithFormat:@"%@",ad.price] stringByReplacingOccurrencesOfString:@"." withString:[[PriceFormatter sharedFormatter] countryDivider]]];
                    [(UITextField*)[cell viewWithTag:TEXT_FIELD_PRICE_TAG] setKeyboardType:UIKeyboardTypeDecimalPad];
                    [(UITextField*)[cell viewWithTag:TEXT_FIELD_PRICE_TAG] setDelegate:self];
                    [cell setHighlightionStyle:CellHighlightionNone];

                    break;
                case 2:
                    cell = (CustomCellForSelecting*)[tableView dequeueReusableCellWithIdentifier:@"DescriptionCell"];
                    [(UITextView*)[cell viewWithTag:TEXTVIEWTAG] setDelegate:self];
                    if (ad.descriptionText && ad.descriptionText.length) {
                        [(UITextView*)[cell viewWithTag:TEXTVIEWTAG] setText:ad.descriptionText];
                        [[cell viewWithTag:LABELTAG] setHidden:YES];
                    }
                    [cell setHighlightionStyle:CellHighlightionNone];

                    break;
            }
            break;
        case 1:
            cell = (CustomCellForSelecting*)[tableView dequeueReusableCellWithIdentifier:@"DefaultCell"];
            cell.textLabel.textColor = [UIColor whiteColor];
            //switch (indexPath.row) {
            
            cell.textLabel.text = NSLocalizedString(enabledStatuses[indexPath.row], nil);
            
            [cell setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"items_galka.png"]]];
            if(indexPath.row!=0)
            {
                [cell.accessoryView setAlpha:0.0f];
                [cell.accessoryView setHidden:YES];
            }
            /*
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewTap:)];
            [cell addGestureRecognizer:tapGesture];
            [tapGesture setCancelsTouchesInView:NO];
             */
            
            
            UIImageView* imageView = (UIImageView*)[cell viewWithTag:55];
            if(!imageView)
            {
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"items_galka_frame"]];
                [imageView setFrame:CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height)];
                [imageView setCenter:CGPointMake(294, 23)];
                [cell addSubview:imageView];
                [imageView setTag:55];
            }
            [cell setHighlightionStyle:CellHighlightionNone];
/*
                }
                    break;
                case 1:
                {
                    cell.textLabel.text = @"Продано";
                    [cell setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"items_galka.png"]]];
                    
                    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewTap2:)];
                    [cell addGestureRecognizer:tapGesture];
                    [tapGesture setCancelsTouchesInView:NO];
                    
                    UIImageView* imageView = (UIImageView*)[cell viewWithTag:55];
                    if(!imageView)
                    {
                        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"items_galka_frame"]];
                        [imageView setFrame:CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height)];
                        [imageView setCenter:CGPointMake(294, 23)];
                        [cell addSubview:imageView];
                        [imageView setTag:55];
                    }
                    [cell setHighlightionStyle:CellHighlightionNone];

                }
                    break;

            }
            break;
        */
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setProsition:tableView withIndexPath:indexPath];
    
    return cell;
}

-(void)tableViewTap:(UIGestureRecognizer*) gesture
{
    //[self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    [UIView animateWithDuration:0.1f animations:^{
        [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]].accessoryView setAlpha:1.0f];
        [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]].accessoryView setAlpha:0.0f];
    }];
}

/*
-(void)tableViewTap2:(UIGestureRecognizer*) gesture
{
    //[self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]].accessoryView setHidden:NO];
    [UIView animateWithDuration:0.1f animations:^{
        [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]].accessoryView setAlpha:1.0f];
        [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]].accessoryView setAlpha:0.0f];
    }];
}
*/

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==2 && indexPath.section==0)
        [[[self.tableView cellForRowAtIndexPath:indexPath] viewWithTag:TEXTVIEWTAG] becomeFirstResponder];
    
    if(indexPath.section==1)
    {
        for(int i = 0 ; i < enabledStatuses.count ; i++)
        {
            [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]].accessoryView.hidden = NO;
            [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]].accessoryView.alpha = (indexPath.row==i);
        }
    }
    selectedStatus = indexPath.row;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"  ";
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = (section==0)? NSLocalizedString(@"Details", nil): NSLocalizedString(@"Status", nil);
    if (sectionTitle == nil) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 8, 320, 20);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:188.0f/255.0f green:196.0f/255.0f blue:203.0f/255.0f alpha:1.0f];
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(0.0, -1.0);
    label.font = [UIFont boldSystemFontOfSize:17];
    label.text = sectionTitle;

    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor clearColor]];
    view.tag = 50 + !(section==0);
    return view;
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(scrollView==self.scrollView)
    {
        [self stopAnimation];
        [self.view endEditing:YES];
    }
    if([scrollView isKindOfClass:([UITextView class])])
    {
        [(UITextView*)scrollView becomeFirstResponder];
    }
}

#pragma mark - UITextViewDelegate

-(void)textViewDidChange:(UITextView *)textView
{
    [[textView.superview viewWithTag:LABELTAG] setHidden:textView.text.length];
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.view commitAnimationsBlock:^{
        [self.scrollView setContentOffset:CGPointMake(0,-[textView convertPoint:textView.frame.origin fromView:self.scrollView ].y-40.0f)];
    }];
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{    
    if(!descCellEdited)
    {
        descCellEdited=YES;
        [self redrawCellHeight];
        return YES;
    }
    
    return NO;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if(descCellEdited)
    {
        descCellEdited = NO;
        [self redrawCellHeight];
    }
}

-(void) redrawCellHeight
{
    CustomCellForSelecting* descCell = (CustomCellForSelecting*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    UIImageView* imageView = [descCell backgroundImageView];
    [self.tableView bringSubviewToFront:descCell];
    //[descCell setClipsToBounds:!descCellEdited];
    
    CustomCellForSelecting* lastCell1 = (CustomCellForSelecting*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    CustomCellForSelecting* lastCell2 = (CustomCellForSelecting*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    UIView* headerView = [self.tableView viewWithTag:51];
    
    float lastCellCenterY = lastCell1.center.y + self.tableView.frame.origin.y;
    [UIView animateWithDuration:0.3f animations:^{
        [imageView setFrame:CGRectMake(0, 0, 320, descCellEdited?93:49)];
        [[descCell viewWithTag:TEXTVIEWTAG] setFrame:CGRectMake(CGRectGetMinX([descCell viewWithTag:TEXTVIEWTAG].frame), CGRectGetMinY([descCell viewWithTag:TEXTVIEWTAG].frame), 270,  descCellEdited?74:30)];
        [lastCell1 setCenter:CGPointMake(lastCell1.center.x, lastCell1.center.y+(descCellEdited?44:-44))];
        [lastCell2 setCenter:CGPointMake(lastCell2.center.x, lastCell2.center.y+(descCellEdited?44:-44))];
        [headerView setCenter:CGPointMake(headerView.center.x, headerView.center.y+(descCellEdited?44:-44))];
        for(UIView* view in self.scrollView.subviews)
        {
            if(view.center.y>lastCellCenterY)
                [view setCenter:CGPointMake(view.center.x, view.center.y+(descCellEdited?44:-44))];
        }
        [descCell viewWithTag:77].transform = CGAffineTransformMakeRotation(descCellEdited?M_PI/2:0);
        if(!descCellEdited)
            [(UITextView*)[descCell viewWithTag:TEXTVIEWTAG] setContentOffset:CGPointMake(0, 0)];
        
    }];
    CustomCellForSelecting* lastCell = (CustomCellForSelecting*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    if (![lastCell viewWithTag:600]) {
        UIImageView* separator = [[UIImageView alloc] initWithFrame:lastCell.separator.frame];
        [separator setImage:[[UIImage imageNamed:@"profile_devider.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)]];
        [lastCell addSubview:separator];
        separator.tag=600;
    }
    

}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self.view commitAnimationsBlock:^{
        [self.scrollView setContentOffset:CGPointMake(0,-[textField convertPoint:textField.frame.origin fromView:self.scrollView ].y-40.0f)];
    }];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if(([textField.text containsString:[[PriceFormatter sharedFormatter] countryDivider]] && [string isEqualToString:[[PriceFormatter sharedFormatter] countryDivider]]) || (textField.text.length == 0 && [string isEqualToString:[[PriceFormatter sharedFormatter] countryDivider]])) {
        return NO;
    }else{
        return YES;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField.tag==TEXT_FIELD_TITLE_TAG)
        [[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] viewWithTag:TEXT_FIELD_PRICE_TAG] becomeFirstResponder];
    return YES;
}

-(void)create:(id)sender
{
    
    [self sendEventWithCategory:@"EditAdvertisement" action:@"Apply button pressed" label:@"" value:nil];
    
    [self stopAnimation];
    [sender setEnabled:NO];
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    for(int i = 0 ; i < 3 ; i++)
    {
        for(int j = 0 ; j < 2 ; j++)
        {
            UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
            switch (j) {
                case 0:
                    switch (i) {
                        case 0:
                            [dict setObject:((UITextField*)[cell viewWithTag:TEXT_FIELD_TITLE_TAG]).text forKey:@"title"];
                            [(UITextField*)[cell viewWithTag:TEXT_FIELD_TITLE_TAG] resignFirstResponder];
                            break;
                        case 1:
                            [dict setObject:[[PriceFormatter sharedFormatter] formatPriceString:((UITextField*)[cell viewWithTag:TEXT_FIELD_PRICE_TAG]).text dividerWithString:@"."] forKey:@"price"];
                            [(UITextField*)[cell viewWithTag:TEXT_FIELD_PRICE_TAG] resignFirstResponder];
                            break;
                        case 2:
                            [dict setObject:((UITextView*)[cell viewWithTag:TEXTVIEWTAG]).text forKey:@"description"];
                            [(UITextView*)[cell viewWithTag:TEXTVIEWTAG] resignFirstResponder];
                            break;
                    }
                    break;
            }
            break;
        }
    }
    
    [self.view commitAnimationsBlock:^{
        [self.scrollView setContentOffset:CGPointMake(0, 0)];
    }];
        
    if(![enabledStatuses[selectedStatus] isEqualToString:ad.status])
        [dict setObject:enabledStatuses[selectedStatus] forKey:@"status"];
    
    for(int i = 0, j= 0 ; i < attachments.count+j ; i++ )
        if([attachments[i-j] isKindOfClass:([NSNumber class])])
        {
            [attachments removeObjectAtIndex:i-j];
            j++;
        }
    
    for(NSNumber* identifier in oldImages)
        [attachments addObject:@{@"id" : [identifier stringValue] , @"_destroy" : @"1"}];
    
    if(mainImg.integerValue > 0)
        [attachments addObject:@{@"id" : [mainImg stringValue] , @"main_image" : @"1"}];
    else
        if(mainImg.intValue<attachments.count)
            [attachments[mainImg.intValue] setObject:@"1" forKey:@"main_image"];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setSquare:YES];
    [hud setMinSize:CGSizeMake(126, 126)];
    hud.mode = MBProgressHUDModeDeterminate;
    hud.labelText = NSLocalizedString(@"Upload...", nil);
    
    [Advertisement editAdvertisementWithID:[ad.identifier stringValue] images:attachments params:dict progress:^(float progress) {
        hud.progress = progress;
        
        if(progress == 1) {
            
            hud.mode = MBProgressHUDModeIndeterminate;
            hud.labelText = NSLocalizedString(@"Waiting...", nil);
            
        }
        
    } success:^(Advertisement *tempAd) {
        
        //[self postNotificationWithAd:tempAd];
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"success.png"]];
        hud.labelText = NSLocalizedString(@"Success", nil);
        
        [hud hide:YES afterDelay:2];
        [sender setEnabled:YES];
        [self.navigationController popToRootViewControllerAnimated:YES];
    } failure:^(NSDictionary *dict, NSError *error) {
        
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
        hud.labelText = NSLocalizedString(@"Failed", nil);
        
        [hud hide:YES afterDelay:2];
        NSLog(@"Error: %@", [error localizedDescription]);
        [sender setEnabled:YES];
    }];
    
}

- (void)viewDidUnload {
    [self stopAnimation];
    [self setTableView:nil];
    [self setScrollView:nil];
    [self setHorizontalScrollView:nil];
    [super viewDidUnload];
}
- (IBAction)takePhoto:(id)sender {
    
    [self sendEventWithCategory:@"EditAdvertisement" action:[NSString stringWithFormat:@"Take photo button pressed (photos in advertisement: %i)", attachments.count] label:@"" value:nil];
    
    [self stopAnimation];
    index = -1;
    [self performSegueWithIdentifier:kSegueFromEditAdToCamOverlay sender:self];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [((CamOverlayController*)segue.destinationViewController) setIndex:index];
    [(CamOverlayController*)segue.destinationViewController setDelegate:self];
}
#pragma mark - CamOverlayDelegate
-(void)imagePickerControllerDidCancel:(CamOverlayController *)picker
{
    
}

-(void)imagePickerController:(CamOverlayController *)picker didFinishPickingMediaWithInfo:(NSMutableDictionary *)info
{
    UIImage* editedImage = [info objectForKey:@"editedImage"];
    [info removeObjectForKey:@"editedImage"];
    PhotoItem* item;
    if(picker.index<0)
    {
        [attachments insertObject:info atIndex:0];
        
        item = [[PhotoItem alloc] initWithImage:[[editedImage imageByScalingAndCroppingForSize:CGSizeMake(150, 150)] roundCornerImageWithWidth:10 height:10]];
        [item setDelegate:self];
        item.tag = 49;
        
        [item setCenter:CGPointMake(-50, 43)];
        [self.horizontalScrollView addSubview:item];
        [item addBtnToBeginForScroll];
        [self.horizontalScrollView setContentSize:CGSizeMake(item.frame.size.width*attachments.count, self.horizontalScrollView.contentSize.height)];
    }else
    {
        [attachments replaceObjectAtIndex:picker.index withObject:info];
        
        item = (PhotoItem*)[self.horizontalScrollView viewWithTag:picker.index+50];
        [item.photoBtn setImage:[[editedImage imageByScalingAndCroppingForSize:CGSizeMake(150, 150)] roundCornerImageWithWidth:10 height:10] forState:UIControlStateNormal];
    }
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark - photoItemDelegate

-(void)photoItemDidSelected:(PhotoItem *)item{
    [self stopAnimation];
    for(int i = 0 ; i < attachments.count ; i++)
    {
        [((PhotoItem*)[self.horizontalScrollView viewWithTag:i+50]) removeFlag];
    }
    [item addFlag];
    mainImg = [attachments[item.tag-50] isKindOfClass:([NSDictionary class])] ? [NSNumber numberWithInt:-(item.tag-50)]  :  attachments[item.tag-50];
}
-(void)photoItemRemoveButtonDidSelected:(PhotoItem *)item
{
    if([attachments[item.tag-50] isKindOfClass:([NSNumber class])])
        [oldImages addObject:attachments[item.tag-50]];
    [attachments removeObjectAtIndex:item.tag-50];
    [UIView animateWithDuration:0.4f animations:^{
        [self.horizontalScrollView setContentSize:CGSizeMake(attachments.count*item.frame.size.width, self.horizontalScrollView.frame.size.height)];
    }];
}

-(void)playAnimation
{
    if(isPhotoItemsAnimated)
        return;
    isPhotoItemsAnimated = YES;
    for(UIView* view in self.horizontalScrollView.subviews)
    {
        if([view isKindOfClass:[PhotoItem class]])
        {
            CGAffineTransform transform = CGAffineTransformMakeRotation(-M_PI/90);
            view.transform = transform;
            
            
        }
    }
    [UIView animateWithDuration:0.08 delay:0.0 options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse |UIViewAnimationOptionAllowUserInteraction) animations:^{
        for(UIView* view in self.horizontalScrollView.subviews)
        {
            if([view isKindOfClass:[PhotoItem class]])
            {
                CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI/90);
                view.transform = transform;
            }
        }
    } completion:NULL];
}

-(void)stopAnimation
{
    for(UIView* view in self.horizontalScrollView.subviews)
    {
        if([view isKindOfClass:[PhotoItem class]])
        {
            [(PhotoItem*)view deleteRemoveBtn];
            CGAffineTransform transform = CGAffineTransformMakeRotation(0);
            view.transform = transform;
            [view.layer removeAllAnimations];
        }
    }
    isPhotoItemsAnimated = NO;
}

-(void)scrollTapped:(UIGestureRecognizer*) gesture
{
    [self.view endEditing:YES];
    
    [self.view commitAnimationsBlock:^{
        [self.scrollView setContentOffset:CGPointMake(0, 0)];
    }];
    
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
}

-(void)deleteAd
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setSquare:YES];
    [hud setMinSize:CGSizeMake(126, 126)];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.dimBackground = YES;
    hud.labelText = NSLocalizedString(@"Deleting...", nil);
    
    [Advertisement deleteAdvertisementWithID:ad.identifier.stringValue success:^(Advertisement *ad) {
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"success.png"]];
        hud.labelText = NSLocalizedString(@"Success...", nil);
        
        [self performSelector:@selector(hideHud:) withObject:hud afterDelay:2];
        //[hud hide:YES afterDelay:2];
        
    } failure:^(NSDictionary *dict, NSError *error) {
        [hud hide:YES afterDelay:0.5f];
    }];
}

-(void) hideHud:(MBProgressHUD*) hud
{
    [hud hide:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


-(void)setDonePanel
{
    UIToolbar *tools=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    tools.barStyle = UIBarStyleBlackOpaque;
    //[tools setTranslucent:YES];
    
    //[tools setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7f]];
    UIBarButtonItem *doneButton=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(returnActionFroFirstResponder:)];
    doneButton.imageInsets=UIEdgeInsetsMake(200, 6, 50, 25);
    [tools setCenter:CGPointMake(160, CGRectGetMaxY(self.view.frame)+15)];
    [doneButton setStyle:UIBarButtonItemStyleBordered];
    UIBarButtonItem *flexSpace= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray *array = [[NSArray alloc] initWithObjects:flexSpace, flexSpace, flexSpace, doneButton,nil];
    
    [tools setItems:array];
    [self.view addSubview:tools];
    [tools setTag:PANEL_TAG];
}

-(void)returnActionFroFirstResponder:(id) sender
{
    UIView* view = [self.view findFirstResponder];
    switch (view.tag) {
        case TEXT_FIELD_TITLE_TAG:
            [view resignFirstResponder];
            break;
        case TEXT_FIELD_PRICE_TAG:
            [[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] viewWithTag:TEXTVIEWTAG] becomeFirstResponder];
            break;
        case TEXTVIEWTAG:
            [view resignFirstResponder];
            break;
        default:
            break;
    }
}


#pragma mark - KEYBOARD OBSERVING

-(void)keyboardWillShow:(NSNotification*) notification
{
    [self.scrollView setContentSize:CGSizeMake(320, (IS_IPHONE5)?656:568)];
    [self.view commitAnimationsBlock:^{
        [[self.view viewWithTag:PANEL_TAG] setCenter:CGPointMake(160, CGRectGetMaxY(self.view.frame)-236)];
    }];
}

-(void)keyboardDidHide:(NSNotification*) notification
{
    [self.view commitAnimationsBlock:^{
        [self.scrollView setContentSize:CGSizeMake(320, 416)];
    }];
}

-(void)keyboardWillHide:(NSNotification*) notification
{
    [self.view commitAnimationsBlock:^{
        [[self.view viewWithTag:PANEL_TAG] setCenter:CGPointMake(160, CGRectGetMaxY(self.view.frame)+50)];
    }];
}

#pragma mark - calculating status ad section

-(void)calculateStatusAd
{
    NSArray* array = @[@"moderation",@"active",@"sold",@"inactive",@"rejected"];
    selectedStatus = 0;
    int status = [array indexOfObject:ad.status];
    switch (status) {
        case 0:
            enabledStatuses = @[];
            break;
        case 1:
            enabledStatuses = @[@"active",@"inactive",@"sold"];
            break;
        case 2:
            enabledStatuses = @[@"sold",@"active"];
            break;
        case 3:
            enabledStatuses = @[@"inactive",@"active"];
            break;
        case 4:
            enabledStatuses = @[@"rejected",@"moderation"];
            break;
        default:
            break;
    }
    if([self.tableView numberOfRowsInSection:1]==0)
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
}


-(void)postNotificationWithAd:(Advertisement*) tempAd
{
    UIImage* mainImage;
    int i = 0;
    
    for(NSDictionary* tempDict in attachments)
    {
        if(tempDict[@"main_image"] && [tempDict[@"main_image"] isEqualToString:@"1"])
        {
            //mainImage = [(PhotoItem*)[self.horizontalScrollView viewWithTag:50+i] photoBtn].imageView.image;
            CGRect cropRect = CGRectMake([tempDict[@"x"] floatValue], [tempDict[@"y"] floatValue], [tempDict[@"side"] floatValue], [tempDict[@"side"] floatValue]);
            
            mainImage = [tempDict[@"attachment"] imageByScalingAndCroppingForRect:cropRect];
            mainImage = [mainImage imageByScalingAndCroppingForSize:CGSizeMake(320, 320)];
            
            break;
        }
        i++;
    }
    if(!mainImage && attachments.count==1)
    {
        CGRect cropRect = CGRectMake([attachments[0][@"x"] floatValue], [attachments[0][@"y"] floatValue], [attachments[0][@"side"] floatValue], [attachments[0][@"side"] floatValue]);
        
        mainImage = [attachments[0][@"attachment"] imageByScalingAndCroppingForRect:cropRect];
        mainImage = [mainImage imageByScalingAndCroppingForSize:CGSizeMake(320, 320)];
        //mainImage = [(PhotoItem*)[self.horizontalScrollView viewWithTag:50] photoBtn].imageView.image;
    }
    
    for(NSDictionary* tempDict in tempAd.images)
        if (tempDict[@"main_image"] && [tempDict[@"main_image"] isEqualToNumber:@1] ) {
            [[UIImageView af_sharedImageCache] cacheImage:mainImage forKey:tempDict[@"url"]];
        }
    
}

@end
