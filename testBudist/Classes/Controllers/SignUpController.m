//
//  SignUpController.m
//  iSeller
//
//  Created by Чина on 28.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "SignUpController.h"
#import "CustomCellForSelecting.h"
#import "Profile.h"
#import "NSString+Extensions.h"
#import "NSDate+Extensions.h"
#import <MBProgressHUD.h>

@interface SignUpController ()

@end

@implementation SignUpController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad
{
    self.skipAuth = YES;
    
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:BG_IMAGE]]];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)]];
}

#pragma mark - TableViewDataSource Method's

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCellForSelecting *cell = (CustomCellForSelecting*)[tableView dequeueReusableCellWithIdentifier:@"SingUpCell"];
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];
    UITextField* textField = (UITextField*)[cell viewWithTag:20];
    switch (indexPath.row) {
        case 0:
            //cell.textLabel.text = @"Email";
            textField.placeholder = NSLocalizedString(@"Email", nil);
            textField.keyboardType = UIKeyboardTypeEmailAddress;
            break;
        case 1:
            //cell.textLabel.text = NSLocalizedString(@"Name", nil);
            textField.placeholder = NSLocalizedString(@"Name", nil);
            break;
        case 2:
            //cell.textLabel.text = NSLocalizedString(@"Password", nil);
            textField.placeholder = NSLocalizedString(@"Password (at least 6 characters)", nil);
            [textField setSecureTextEntry:YES];
            break;
    }
    cell.textLabel.textColor = [UIColor whiteColor];
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setProsition:tableView withIndexPath:indexPath];
    [cell setHighlightionStyle:CellHighlightionNone];
    return cell;
}


- (IBAction)singUP:(id)sender {
    
    [self sendEventWithCategory:@"Registration" action:@"Register button pressed" label:@"" value:nil];
    
    NSMutableArray* array = [[NSMutableArray alloc] initWithCapacity:3];
    for(int i = 0; i < 3 ; i++)
    {
        [array addObject:((UITextField*)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]] viewWithTag:20]).text];
    }
    
    if(![((NSString*)array[0]) isValidEmail] || ((NSString*)array[1]).length<6 || ((NSString*)array[2]).length<6)
    {
        [self showWarningHUD];
        return;
    }
    
    [self showHUDForWaiting];
    
    [[Profile sharedProfile] signUpWithEmail:array[0] name:array[1] pass:array[2] success:^{
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_NEED_UPDATE_FEED_DATA_SOURCE object:self];
            [[MBProgressHUD HUDForView:self.view] hide:YES];
            
            NSString *date = [[NSDate date] dateToUTCWithFormat:@"dd.MM.yyyy"];
            
            [[GAI sharedInstance].defaultTracker setCustom:2 dimension:date];
                        
        }];
    } failure:^(NSError *error) {
        [[MBProgressHUD HUDForView:self.view] hide:YES];
    }];
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showWarningHUD
{
    UIView* tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
    [tempView setBackgroundColor:[UIColor clearColor]];
    [tempView setCenter:self.view.center];
    [self.view addSubview:tempView];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setMode:MBProgressHUDModeText];
    [hud setLabelText:NSLocalizedString(@"Fill in all fields...", nil)];
    [hud setAnimationType:MBProgressHUDAnimationFade];
    [hud hide:YES afterDelay:1.0f];
    [hud setMargin:10];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setNavigationItem2:nil];
    [super viewDidUnload];
}

- (IBAction)backTapped:(id)sender {
    
    [self sendEventWithCategory:@"Registration" action:@"Back button pressed" label:@"" value:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)showHUDForWaiting
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setSquare:YES];
    [hud setMinSize:CGSizeMake(126, 126)];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[LoaderView alloc] initWithMode:loaderViewModeIndeterminate];
    [(LoaderView*)hud.customView startAnimating];
    [(LoaderView*)hud.customView setProgress:0];
    hud.labelText = NSLocalizedString(@"Waiting...", nil);
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hudDidTapped:)];
    [tapGesture setNumberOfTapsRequired:2];
    [hud addGestureRecognizer:tapGesture];
}


-(void)hudDidTapped:(UITapGestureRecognizer*)gesture
{
    MBProgressHUD* progressHUD = (MBProgressHUD*)gesture.view;
    [progressHUD hide:YES];
    [Profile cancelLastRequest];
}

@end
