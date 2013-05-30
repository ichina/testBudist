//
//  CreateController.m
//  iSeller
//
//  Created by Чина on 21.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "CreateController.h"
#import "CustomCellForSelecting.h"
#import "LocationManager.h"
#import "PriceFormatter.h"
#import "NSString+Extensions.h"
#import "Advertisement.h"
#import "UIImage+scale.h"
#import "TabBarController.h"
#import "UIView+Extensions.h"
#import "CGSwitch.h"
#import "LoaderView.h"
#import "CreatingProgressView.h"
#import "MyItemsController.h"
#import "UIImageView+AFNetworking.h"

#import "Profile.h"

#define TEXT_FIELD_PRICE_TAG 490
#define TEXT_FIELD_TITLE_TAG 500
#define LABELTAG 510
#define SWITCHTAG 520
#define TEXTVIEWTAG 530

#define FB_SHARE_TAG 550
#define TW_SHARE_TAG 560
#define VK_SHARE_TAG 570

#define PANEL_TAG 580

@interface CreateController ()

@property (nonatomic, retain) NSMutableDictionary *social;
@property (nonatomic, assign) CLLocationCoordinate2D coordinates;

- (void)setLocationForLabel:(UILabel *)label;

@end

@implementation CreateController

@synthesize social;
//@synthesize coordinates;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        attachments = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    //с появлением контактного емайла, подтверждение емэйла не требуется. возможно скоро возобновится
    /*
    if(![Profile sharedProfile].isConfirmed) {
        
        CGAlertView *alert = [[CGAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"You haven't confirmed e-mail validation. Do you want us to resend the confirmation to your current e-mail?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
        [alert show];
        
    }
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self.tabBarController setHidden:YES animated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    descText = @"";
    [CGSocialManager sharedSocialManager];
    self.social = [NSMutableDictionary dictionary];
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width, 416)];
    [self.tableView setFrame:CGRectMake(0, self.tableView.frame.origin.y, self.tableView.frame.size.width, 400)];
    [self.scrollView setDelegate:self];
    
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self.scrollView setBounces:YES];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:BG_IMAGE]]];
    
	// Do any additional setup after loading the view.
    /*
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"Готово" style:UIBarButtonItemStyleDone target:self action:@selector(create:)];
    [self.navigationItem setRightBarButtonItem:rightBtn animated:YES];
    
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithTitle:@"Отмена" style:UIBarButtonItemStyleDone target:self action:@selector(cancel:)];
    [self.navigationItem setLeftBarButtonItem:leftBtn animated:YES];
    */
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollTapped:)];
    [self.horizontalScrollView addGestureRecognizer:tapGesture];
    [tapGesture setCancelsTouchesInView:NO];
    
    CGSwitch* cgSwitch1 = [[CGSwitch alloc] initWithToggleImage:[UIImage imageNamed:@"switch_fb.png"] sliderImage:[UIImage imageNamed:@"switch_slider.png"]];
    [cgSwitch1 setCenter:CGPointMake(64, 390)];
    [cgSwitch1 setTag:FB_SHARE_TAG];
    [self.scrollView addSubview:cgSwitch1];
    
    CGSwitch* cgSwitch2 = [[CGSwitch alloc] initWithToggleImage:[UIImage imageNamed:@"switch_twitter.png"] sliderImage:[UIImage imageNamed:@"switch_slider.png"]];
    [cgSwitch2 setCenter:CGPointMake(160, 390)];
    [cgSwitch2 setTag:TW_SHARE_TAG];

    [self.scrollView addSubview:cgSwitch2];
    
    CGSwitch* cgSwitch3 = [[CGSwitch alloc] initWithToggleImage:[UIImage imageNamed:@"switch_vk.png"] sliderImage:[UIImage imageNamed:@"switch_slider.png"]];
    [cgSwitch3 setCenter:CGPointMake(256, 390)];
    [cgSwitch3 setTag:VK_SHARE_TAG];

    [self.scrollView addSubview:cgSwitch3];
        
    [topImageView setImage:[[UIImage imageNamed:@"profile_alone.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15,15,15,15)]];
    
    [topSwitch setOnTintColor:[UIColor colorWithRed:153.0f/255 green:191.0f/255 blue:1.0f/255 alpha:1.0]];
    
    if([UIDevice currentDevice].systemVersion.floatValue>=6.0f)
    {
        [topSwitch setTintColor:[UIColor redColor]];
        [topSwitch setThumbTintColor:[UIColor whiteColor]];
    }
    
    [topSwitch setOn:NO];
    
    [(UIImageView*)[self.scrollView viewWithTag:33] setImage:[[(UIImageView*)[self.scrollView viewWithTag:33] image] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 0, 15, 0)]];
    
    [self setDonePanel]; //панелька над клавиатурой с кнопкой готово
    
    [topSwitch addTarget:self action:@selector(topSwitchDidChange:) forControlEvents:UIControlEventValueChanged];
}
-(IBAction)cancel:(id) sender
{
    
    [self sendEventWithCategory:@"CreateAdvertisement" action:@"Back button pressed" label:@"" value:nil];
    
    [self stopAnimation];
    [(TabBarController*)self.tabBarController closeCreateTab];
    [self.scrollView setContentSize:CGSizeMake(320, 416)];
    [self.scrollView setContentOffset:CGPointZero];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableViewDataSource Method's

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section ? 1 : 4;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row==2 && descCellEdited)? 88 : 44 ;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCellForSelecting *cell;// = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"<#Cell#>"];
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"PlaceHolderCell"];
                    [(UITextField*)[cell viewWithTag:TEXT_FIELD_TITLE_TAG] setPlaceholder:NSLocalizedString(@"Title", nil)];
                    [(UITextField*)[cell viewWithTag:TEXT_FIELD_TITLE_TAG] setDelegate:self];
                    [cell setHighlightionStyle:CellHighlightionNone];
                    break;
                case 1:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"PlaceHolderCell"];
                    [(UITextField*)[cell viewWithTag:TEXT_FIELD_TITLE_TAG] setTag:TEXT_FIELD_PRICE_TAG];
                    [(UITextField*)[cell viewWithTag:TEXT_FIELD_PRICE_TAG] setPlaceholder:NSLocalizedString(@"Price", nil)];
                    [(UITextField*)[cell viewWithTag:TEXT_FIELD_PRICE_TAG] setKeyboardType:UIKeyboardTypeDecimalPad];
                    [(UITextField*)[cell viewWithTag:TEXT_FIELD_PRICE_TAG] setDelegate:self];
                    [cell setHighlightionStyle:CellHighlightionNone];
                    break;
                case 2:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"DescriptionCell"];
                    [(UITextView*)[cell viewWithTag:TEXTVIEWTAG] setDelegate:self];
                    [cell setHighlightionStyle:CellHighlightionNone];
                    break;
                case 3:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"LocationCell"];
                    cell.textLabel.text = NSLocalizedString(@"Location", nil);
                    [cell setAccessoryView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dialog_accessory.png"]]];
                    [self setLocationForLabel:cell.detailTextLabel];
                }
                    break;
            }
            break;

    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setProsition:tableView withIndexPath:indexPath];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row==2)
        [[[self.tableView cellForRowAtIndexPath:indexPath] viewWithTag:TEXTVIEWTAG] becomeFirstResponder];
    else if(indexPath.row == 3){
        
        [self sendEventWithCategory:@"CreateAdvertisement" action:@"Custom geolocation button pressed" label:@"" value:nil];
        
    }
}

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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section==0)
    {
        return NSLocalizedString(@"Details", nil);
    }
    else
        return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = [self tableView:self.tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 10, 320, 20);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.font = [UIFont boldSystemFontOfSize:17];
    label.text = sectionTitle;
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor clearColor]];
    return view;
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
    //[textView setScrollEnabled:YES];

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
    //[textView setScrollEnabled:NO];
}

-(void) redrawCellHeight
{
    CustomCellForSelecting* descCell = (CustomCellForSelecting*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    UIImageView* imageView = [descCell backgroundImageView];
    UIImageView* separatorView = [descCell separator];
    [self.tableView bringSubviewToFront:descCell];
    //[descCell setClipsToBounds:!descCellEdited];
    
    CustomCellForSelecting* lastCell = (CustomCellForSelecting*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    
    static UITapGestureRecognizer* gesture;
    if (!gesture)
        gesture = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(geoCellTapped:)];
    if(descCellEdited)
        [lastCell addGestureRecognizer:gesture];
    else
        [lastCell removeGestureRecognizer:gesture];
    
    
    float lastCellCenterY = lastCell.center.y + self.tableView.frame.origin.y;
    [UIView animateWithDuration:0.3f animations:^{
        [imageView setFrame:CGRectMake(0, 0, 320, descCellEdited?88:44)];
        [[descCell viewWithTag:TEXTVIEWTAG] setFrame:CGRectMake(CGRectGetMinX([descCell viewWithTag:TEXTVIEWTAG].frame), CGRectGetMinY([descCell viewWithTag:TEXTVIEWTAG].frame), 270,  descCellEdited?74:30)];
        [separatorView setCenter:CGPointMake(separatorView.center.x, CGRectGetMaxY(imageView.frame)-1)];
        [lastCell setCenter:CGPointMake(lastCell.center.x, lastCell.center.y+(descCellEdited?44:-44))];
        for(UIView* view in self.scrollView.subviews)
        {
            if(view.center.y>lastCellCenterY)
                [view setCenter:CGPointMake(view.center.x, view.center.y+(descCellEdited?44:-44))];
        }
        [descCell viewWithTag:77].transform = CGAffineTransformMakeRotation(descCellEdited?M_PI/2:0);
        if(!descCellEdited)
            [(UITextView*)[descCell viewWithTag:TEXTVIEWTAG] setContentOffset:CGPointMake(0, 0)];

    }];
}


#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self stopAnimation];
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

-(IBAction)create:(id)sender
{
    [self sendEventWithCategory:@"CreateAdvertisement" action:@"Create button pressed" label:@"" value:nil];
    
    [sender setEnabled:NO];
    
    [self stopAnimation];
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    for(int i = 0 ; i < 4 ; i++)
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
                        case 3:
                            [dict setObject:cell.detailTextLabel.text forKey:@"address"];
                            if([dict[@"address"] isEqualToString:NSLocalizedString(@"No", nil)])
                            {
                                CGAlertView* alertView = [[CGAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please, set location manualy", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                                alertView.tag = 105;
                                [alertView show];
                                [sender setEnabled:YES];
                                return;
                            }
                            break;
                    }
                    break;
            }
        }
    }
    
    NSString* locationStr = [NSString stringWithFormat:@"%f,%f",self.coordinates.latitude,self.coordinates.longitude,nil];
    NSLog(@"%@",locationStr);
    if(locationStr)
        [dict setObject:locationStr forKey:@"ll"];
    //7.836578,98.345418
    /*if(error.code == -1011 && [[error localizedDescription] containsString:@"409"]) {
        
        [hud hide:YES];
        
        CGAlertView *alert = [[CGAlertView alloc] initWithTitle:@"Error" message:@"You are out of coins. Would you like to buy some?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert show];
        
    }*/
    
    if(topSwitch.isOn) {
        
        [self sendEventWithCategory:@"CreateAdvertisement:TopSwitch" action:@"Top switch ON while, creating advertisement" label:@"" value:nil];
        
    }
    
    if([[Profile sharedProfile].balance integerValue] == 0) {
        
        [dict setObject:@"0" forKey:@"make_top"];
        if(topSwitch.on)
        {
            CGAlertView *alert = [[CGAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"You are out of coins. Would you like to buy some?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
            [alert setTag:101];
            [alert show];
            
            [self sendEventWithCategory:@"CreateAdvertisement:TopSwitch" action:@"Top switch ON while, creating advertisement (Not enough coins)" label:@"" value:nil];
            
            [sender setEnabled:YES];
            return;
            
        }
        
        
    }else{
        
        [dict setObject:topSwitch.on?@"1":@"0" forKey:@"make_top"];
                
    }
    
    [self.view commitAnimationsBlock:^{
        [self.scrollView setContentOffset:CGPointMake(0, 0)];
    }];
    
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setSquare:YES];
    [hud setMinSize:CGSizeMake(126, 126)];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[LoaderView alloc] initWithMode:loaderViewModeDeterminate];
    [(LoaderView*)hud.customView startAnimating];
    [(LoaderView*)hud.customView setProgress:0];
    hud.labelText = NSLocalizedString(@"Uploading...", nil);
    [hud setDelegate:self];
        
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hudDidTapped:)];
    [tapGesture setNumberOfTapsRequired:2];
    [hud addGestureRecognizer:tapGesture];
    
    __block CreatingProgressView* creatingProgressView = [[CreatingProgressView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
    [creatingProgressView setProgress:0];
    [(TabBarController*)self.tabBarController drawCreatingProgressView:creatingProgressView];

    [sender setEnabled:NO];
    
    [self sendEventWithCategory:@"CreateAdvertisement" action:[NSString stringWithFormat:@"Create button pressed (photos taken: %i)", attachments.count] label:@"" value:nil];
    
    [Advertisement createAdvertisementWithImages:attachments params:dict progress:^(float progress) {
        
        if(hud.alpha == 0) {
            [hud show:YES];
            [hud setAlpha:1.0];
            hud.customView = nil;
            hud.customView = [[LoaderView alloc] initWithMode:loaderViewModeIndeterminate];
            [(LoaderView*)hud.customView startAnimating];
            hud.labelText = NSLocalizedString(@"Reuploading...", nil);
        }
        //Оставляю последние пять процентов на ожидание ответа от сервака
        [creatingProgressView setProgress:progress*0.95f];
        [(LoaderView*)hud.customView setProgress:progress*0.95f];

        if(progress == 1) {
            [hud.customView removeFromSuperview];
            hud.customView = nil;
            hud.customView = [[LoaderView alloc] initWithMode:loaderViewModeIndeterminate];
            [(LoaderView*)hud.customView startAnimating];
            hud.labelText = NSLocalizedString(@"Waiting...", nil);
        }
    } success:^(Advertisement *ad) {
        
        //if(dict[@"make_top"] && [dict[@"make_top"] isEqualToString:@"1"])
        [self postNotificationWithDict:dict andAd:ad];
           
        [creatingProgressView setProgress:1];
        [(LoaderView*)hud.customView setProgress:1];
        
        [self startPostingOnTheWalls:ad];

        
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"success.png"]];
        hud.labelText = NSLocalizedString(@"Success", nil);
        [hud setTag:1];
        
        [hud hide:YES afterDelay:2];
        
        [sender setEnabled:YES];
        
    } failure:^(NSDictionary *dict, NSError *error) {
        
        [creatingProgressView removeFromSuperview];
        //needMoveToSearch = NO;
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
        hud.labelText = NSLocalizedString(@"Failed", nil);
        [hud setTag:-1];
        
        [hud hide:YES afterDelay:2];
                
        [sender setEnabled:YES];
    }];
}

- (void)viewDidUnload {
    [self stopAnimation];
    [self setTableView:nil];
    [self setScrollView:nil];
    [self setHorizontalScrollView:nil];
    topImageView = nil;
    topSwitch = nil;
    [super viewDidUnload];
}
- (IBAction)takePhoto:(id)sender {
    
    [self sendEventWithCategory:@"CreateAdvertisement" action:[NSString stringWithFormat:@"Take photo button pressed (already photos taken: %i)", attachments.count] label:@"" value:nil];
    
    [self stopAnimation];
    index = -1;
               
    [self performSegueWithIdentifier:kSegueFromCreateToCamOverlay sender:self];
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"kSegueFromCreateToCamOverlay"]) {
        
        [((CamOverlayController*)segue.destinationViewController) setIndex:index];
        [(CamOverlayController*)segue.destinationViewController setDelegate:self];
        
    }else if([segue.identifier isEqualToString:@"kSegueFromCreateToGeoPicker"]){
        
        [(GeoPickerController *)segue.destinationViewController setDelegate:self];
        
        [(UINavigationBar *)[[(GeoPickerController *)segue.destinationViewController view] viewWithTag:101] setBackgroundImage:[[UIImage imageNamed:@"navbar_bg_main.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forBarMetrics:UIBarMetricsDefault];
        
    }else{
        
        NSLog(@"Unknown segue");
        
    }
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
        
        [item setCenter:CGPointMake(-50, 46)];
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
    
    BOOL hasMainImage = NO;
    
    for(NSDictionary *photoItem in attachments) {
        
        if([photoItem objectForKey:@"main_image"]) {
            
            hasMainImage = YES;
            
            break;
            
        }
        
    }
    
    if(attachments.count > 1 && !hasMainImage) {
        
        [self photoItemDidSelected:(PhotoItem *)[self.horizontalScrollView viewWithTag:attachments.count - 1 + 50]];
        
    }
    
}

#pragma mark - photoItemDelegate

-(void)photoItemDidSelected:(PhotoItem *)item{
    [self stopAnimation];
    for(int i = 0 ; i < attachments.count ; i++)
    {
        [attachments[i] removeObjectForKey:@"main_image"];
        [((PhotoItem*)[self.horizontalScrollView viewWithTag:i+50]) removeFlag];
    }
    [item addFlag];
    [attachments[item.tag-50] setObject:@"1" forKey:@"main_image"];
}
-(void)photoItemRemoveButtonDidSelected:(PhotoItem *)item
{
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

-(UISwitch*)addSwitchToCell:(UITableViewCell*) cell
{
    UISwitch* tempSwitch = (UISwitch*)[cell viewWithTag:SWITCHTAG];
    if(!tempSwitch)
    {
        tempSwitch = [[UISwitch alloc] init];
        [tempSwitch setOnTintColor:[UIColor redColor]];
        [tempSwitch setTag:SWITCHTAG];
        [tempSwitch setCenter:CGPointMake(248, 22)];
        [cell addSubview:tempSwitch];
    }
    
    return tempSwitch;
}

-(void)scrollTapped:(UIGestureRecognizer*) gesture
{
    [self.view endEditing:YES];
    
    [self.view commitAnimationsBlock:^{
        [self.scrollView setContentOffset:CGPointMake(0, 0)];
    }];
        
}

-(void)hudDidTapped:(UITapGestureRecognizer*)gesture
{
    MBProgressHUD* progressHUD = (MBProgressHUD*)gesture.view;
    [progressHUD hide:YES];
    [Advertisement cancelLastRequest];
    [(UIButton*)self.navigationItem.rightBarButtonItem.customView setEnabled:YES];
}

-(void)moveToMyItems //теперь переход в фид 
{
    [self.tabBarController tabBar:self.tabBarController.tabBar didSelectItem:[self.tabBarController.tabBar.items objectAtIndex:0]];
    [self.tabBarController setSelectedIndex:0];
    //[[[self.tabBarController.viewControllers[4] viewControllers] objectAtIndex:0] performSegueWithIdentifier:kSegueFromProfileToMyItems sender:attachments];
    
    [self cleanContent];
}
-(void)cleanContent
{
    for(int i = 0 ; i < 3 ; i++)
    {
        for(int j = 0 ; j < 2 ; j++)
        {
            UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
            switch (j) {
                case 0:
                    switch (i) {
                        case 0:
                            ((UITextField*)[cell viewWithTag:TEXT_FIELD_TITLE_TAG]).text = @"";
                        case 1:
                            ((UITextField*)[cell viewWithTag:TEXT_FIELD_PRICE_TAG]).text = @"";
                            break;
                        case 2:
                            ((UITextView*)[cell viewWithTag:TEXTVIEWTAG]).text = @"";
                            [[cell viewWithTag:LABELTAG] setHidden:NO];
                            break;
                    }
                    break;
            }
        }
    }
    [attachments removeAllObjects];
    for(UIView* view in self.horizontalScrollView.subviews)
        if([view isKindOfClass:[PhotoItem class]])
            [view removeFromSuperview];
}

- (void)setLocationForLabel:(UILabel *)label {
                
    [[LocationManager sharedManager] getLocationWithSuccess:^(CLLocation *location) {
        
        NSString* locationStr = [NSString stringWithFormat:@"%f,%f",location.coordinate.latitude,location.coordinate.longitude,nil];
        self.coordinates = location.coordinate;
        NSLog(@"%@",locationStr);
        
        [[LocationManager sharedManager] geocodingFromLocation:locationStr completion:^(NSString *address) {
            
            if(address && ![address isEqualToString:@""]) {
                
                label.text = address;
                
            }else{
                
                label.text = NSLocalizedString(@"No", nil);
                
            }
            
        }];
        
    } failure:^(NSError *error) {
        
        label.text = NSLocalizedString(@"No", nil);
        
    }];
    
    label.text = NSLocalizedString(@"Receiving...", nil);
    
}

#pragma mark --
#pragma mark GeoPickerDelegate

-(void)geoCellTapped:(UIGestureRecognizer*)gesture
{
    //[self.view endEditing:YES];
    
    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    [self performSegueWithIdentifier:@"kSegueFromCreateToGeoPicker" sender:nil];
}

- (void)geoPickerWantsToDismissWithCancel {
    
    [self dismissModalViewControllerAnimated:YES];
    
}

- (void)geoPickerWantsToDismissWithPlacemark:(CLPlacemark *)placemark {
    
    if(placemark) {
        
        CustomCellForSelecting *cell = (CustomCellForSelecting *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:self.tableView.numberOfSections - 1] - 1 inSection:0]];
        
        cell.detailTextLabel.text = [placemark.addressDictionary objectForKey:@"City"]?[placemark.addressDictionary objectForKey:@"City"]:[placemark.addressDictionary objectForKey:@"Name"];
        //NSLog(@"%f, %f",placemark.location.coordinate.latitude, placemark.location.coordinate.longitude);
        self.coordinates = placemark.location.coordinate;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - sharing
#pragma mark - OWN_BTNS_ACTIONS


-(void)startPostingOnTheWalls:(Advertisement*) ad
{
    idOfLastCreatedAd = [NSString stringWithFormat:@"%@",ad.identifier]; //надо для функции написанной выше))
    
    BOOL needFB = [(CGSwitch*)[self.scrollView viewWithTag:FB_SHARE_TAG] isOn];
    BOOL needVK = [(CGSwitch*)[self.scrollView viewWithTag:VK_SHARE_TAG] isOn];
    BOOL needTW = [(CGSwitch*)[self.scrollView viewWithTag:TW_SHARE_TAG] isOn];
    
    [self sendEventWithCategory:@"CreateAdvertisement:Social" action:[NSString stringWithFormat:@"Share on: %@ %@ %@", needFB ? @"FB" : @"", needVK ? @"VK" : @"", needTW ? @"TW" : @""] label:@"" value:nil];
    
    socialCount = needTW + needVK + needFB;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socialPostingSucceeded:) name:PAULS_NOTIFICATION_SOCIAL_POSTING_SUCCEEDED object:self];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PAULS_NOTIFICATION_SOCIAL_POSTING object:self userInfo:@{@"fb": [NSNumber numberWithBool:needFB], @"vk":[NSNumber numberWithBool:needVK], @"tw":[NSNumber numberWithBool:needTW], @"adID":idOfLastCreatedAd,@"title":ad.title, @"price":ad.price}];
    //[[CGSocialManager sharedSocialManager] tryPost:idOfLastCreatedAd toFB:needFB toVK:needVK toTW:needTW];
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

#pragma mark - MBProgressHUD Delegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    
    if(hud.tag == 1) {
        
        [self moveToMyItems];
        
    }
    
    hud.tag = 0;
    
}

- (void)alertView:(CGAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(alertView.tag == 1 || alertView.tag == 0) {
        
        [super alertView:alertView clickedButtonAtIndex:buttonIndex];
        
        return;
        
    }
    
    if(alertView.tag==105)
    {
        if(buttonIndex==1)
            [self geoCellTapped:nil];
        return;
    }
    
    if(alertView.tag == 1009)
    {
        if (buttonIndex==0) {
            [topSwitch setOn:NO animated:YES];
        }
        if (buttonIndex==2){
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:DONT_SHOW_ALERT_WITH_PRICE_OF_TOP];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        return;
    }
    
    switch (buttonIndex) {
            
        case 0:
            
            if(alertView.tag == 101) {
            
                [topSwitch setOn:NO animated:YES];
                
                [self sendEventWithCategory:@"CreateAdvertisement:TopSwitchAlert" action:@"Accepted offer to buy coins: NO" label:@"" value:nil];
                
            }
            
            break;
            
        case 1:
            
            if(alertView.tag == 101) {
                
                [self performSegueWithIdentifier:kSegueFromCreateToPurchase sender:self];
                
                [self sendEventWithCategory:@"CreateAdvertisement:TopSwitchAlert" action:@"Accepted offer to buy coins: YES" label:@"" value:nil];
                
            }
            else{
                
                [self sendEventWithCategory:@"CreateAdvertisement:EmailConfirmation" action:@"Accepted offer to resend email confirmation: YES" label:@"" value:nil];
                
                [[Profile sharedProfile] sendConfirmationWithProgress:nil success:^{
                    
                    NSLog(@"Sended confirmation.");
                    
                } failure:^(NSError *error) {
                    
                    NSLog(@"Error, while sending confirmation: %@", [error localizedDescription]);
                    
                }];
                
            }
                        
            break;
            
        default:
            break;
    }
    
    if(alertView.tag != 101) {
        
        [self sendEventWithCategory:@"CreateAdvertisement:EmailConfirmation" action:@"Accepted offer to resend email confirmation: NO" label:@"" value:nil];
        
        [self cancel:self];
        
    }
    
}

- (void)socialPostingSucceeded:(NSNotification *)notification {
    
    NSLog(@"%@",notification.userInfo);
    
    [self.social setValue:notification.userInfo[@"status"] forKey:NSLocalizedString(notification.userInfo[@"provider"],nil)];
    
    if([self.social allKeys].count == socialCount) {
        NSMutableArray* errorsOfSocial = [NSMutableArray array];
        for(NSString* key in self.social.allKeys)
            if([self.social[key] isEqualToString:@"error"])
                [errorsOfSocial addObject:key];
        
        if (errorsOfSocial.count>0) {
            NSString* message = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Publishing fail in", nil), [errorsOfSocial componentsJoinedByString:@", "]];
            [[[CGAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        [self.social removeAllObjects];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:PAULS_NOTIFICATION_SOCIAL_POSTING_SUCCEEDED object:[CGSocialManager sharedSocialManager]];
    }
    
}


-(void)topSwitchDidChange:(UISwitch*)sender
{
    if(sender.isOn)
    {
        if( ![[NSUserDefaults standardUserDefaults] objectForKey:DONT_SHOW_ALERT_WITH_PRICE_OF_TOP])
        {
            NSString* coins = [NSLocalizedString(@"locale", nil) isEqualToString:@"en"]?@"coins":[[[Profile sharedProfile].currentPrice stringValue] rusSklonenieCoins];
            
            CGAlertView* alert = [[CGAlertView alloc] initWithTitle:NSLocalizedString(@"iSeller", nil) message:[NSString stringWithFormat:NSLocalizedString(@"BILLING_ALERT_TEXT", nil),[[Profile sharedProfile].currentPrice stringValue],coins] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil),NSLocalizedString(@"OK, don't show again", nil), nil];
            alert.tag = 1009;
            [alert show];
        }
    }
    
}

-(void)postNotificationWithDict:(NSDictionary*) dict andAd:(Advertisement*) ad
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
        
    for(NSDictionary* tempDict in ad.images)
        if (tempDict[@"main_image"] && [tempDict[@"main_image"] isEqualToNumber:@1] ) {
            [[UIImageView af_sharedImageCache] cacheImage:mainImage forKey:tempDict[@"url"]];
        }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_NEED_UPDATE_FEED_DATA_SOURCE object:self];
}

@end
