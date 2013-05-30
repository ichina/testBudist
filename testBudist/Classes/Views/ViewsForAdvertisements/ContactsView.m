//
//  ContactsView.m
//  iSeller
//
//  Created by Чина on 16.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "ContactsView.h"
#import "ViewForViewerCell.h"

#import "NSDate+Extensions.h"

@implementation ContactsView
@synthesize tableView = _tableView;
@synthesize contactInfo;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialSetting];
        contactInfo = [NSMutableDictionary dictionary];
    }
    return self;
}
-(void) initialSetting
{
    self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setBackgroundView:nil];
    [self.tableView setScrollEnabled:NO];
    [self.tableView setRowHeight: !IS_IPHONE5 ? 42 : 44];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setCenter:CGPointMake(self.tableView.center.x, self.tableView.center.y-5)];
    [self addSubview:self.tableView];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[contactInfo allKeys] count]+1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"ContactsCell";
    ViewForViewerCell *cell = (ViewForViewerCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ViewForViewerCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setProsition:tableView withIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
            [cell.iconView setImage:[UIImage imageNamed:@"item_message.png"]];
            cell.lblTitle.text = @"Сообщение";
            break;
        case 1:
            [cell.iconView setImage:[UIImage imageNamed:contactInfo[@"email"]?@"item_mail.png":(contactInfo[@"skype"]?@"item_skype.png":@"item_iphone.png")]];
            cell.lblTitle.text = contactInfo[@"email"]?@"Email":(contactInfo[@"skype"]?@"Skype":@"Phone number");
            break;
        case 2:
            [cell.iconView setImage:[UIImage imageNamed:(contactInfo[@"skype"])?@"item_skype.png":@"item_iphone.png"]];
            cell.lblTitle.text = (contactInfo[@"skype"])?@"Skype":@"Phone number";
            break;
        case 3:
            [cell.iconView setImage:[UIImage imageNamed:@"item_iphone.png"]];
            cell.lblTitle.text = @"Phone number";
            break;
        default:
            break;
    }
    cell.lblTitle.textColor = [UIColor whiteColor];
    cell.lblTitle.shadowColor = [UIColor blackColor];
    cell.lblTitle.shadowOffset = CGSizeMake(0, 1);
    [cell setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dialog_accessory.png"]]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //ViewForViewerCell* cell = (ViewForViewerCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 2:
        {
            if(contactInfo[@"skype"])
            {
                [self callToSkype];
                break;
            }
            else
            {
                [self callToPhone];
            }
            
        }
        case 3:
        {
            [self callToPhone];
        }
            break;
            
        case 1:
        {
            if(contactInfo[@"email"])
                [self sendEmail:contactInfo[@"email"]];
            else if(contactInfo[@"skype"])
                [self callToSkype];
            else if(contactInfo[@"phone"])
                [self callToPhone];
        }
            break;
            
        case 0:
        {
            
            [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Advertisement:Contact" withAction:@"Internal dialogs button pressed" withLabel:[NSString stringWithFormat:@"(%@) %@", [[NSDate date] dateToUTCWithFormat:nil], [NSStringFromClass([self class]) substringToIndex:NSStringFromClass([self class]).length-10]] withValue:nil];
            
            if(delegate && [delegate respondsToSelector:@selector(descriptionBtnClicked)])
                [delegate descriptionBtnClicked];
        }
            break;
        default:
            break;
    }
    
    
}

-(void)callToSkype
{
    
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Advertisement:Contact" withAction:@"Skype button pressed" withLabel:[NSString stringWithFormat:@"(%@) %@", [[NSDate date] dateToUTCWithFormat:nil], [NSStringFromClass([self class]) substringToIndex:NSStringFromClass([self class]).length-10]] withValue:nil];

    
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"skype:%@?chat",contactInfo[@"skype"]]]] )
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"skype:%@?chat",contactInfo[@"skype"]]]];
    }
    else
    {

        CGAlertView *alert = [[CGAlertView alloc] initWithTitle:NSLocalizedString(@"iSeller", nil)
                                                        message:NSLocalizedString(@"Please, install Skype.", nil)
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}
-(void)callToPhone
{
    
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Advertisement:Contact" withAction:@"Phone button pressed" withLabel:[NSString stringWithFormat:@"(%@) %@", [[NSDate date] dateToUTCWithFormat:nil], [NSStringFromClass([self class]) substringToIndex:NSStringFromClass([self class]).length-10]] withValue:nil];

    
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",contactInfo[@"phone"]]]] )
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",contactInfo[@"phone"]]]];
    }
    else
    {
        CGAlertView *alert = [[CGAlertView alloc] initWithTitle:nil
                                                        message:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"It is impossible to call from the device, the contact person who posted this advertisement:", nil),contactInfo[@"phone"]]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }

}

-(void) sendEmail:(NSString*) receiver
{
    
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Advertisement:Contact" withAction:@"Email button pressed" withLabel:[NSString stringWithFormat:@"(%@) %@", [[NSDate date] dateToUTCWithFormat:nil], [NSStringFromClass([self class]) substringToIndex:NSStringFromClass([self class]).length-10]] withValue:nil];

    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        
        //Тема письма
        [picker setSubject:@"Hello"];
        
        //Получатели
        NSArray *toRecipients = [NSArray arrayWithObject:receiver];
        
        [picker setToRecipients:toRecipients];
        
        
        [(UIViewController*)delegate presentModalViewController:picker animated:YES];
    } else {
        NSString *ccRecipients = receiver;
        NSString *subject = @"Hello";
        NSString *recipients = [NSString stringWithFormat:
                                @"mailto:%@?subject=%@",
                                ccRecipients, subject];
        NSString *body = @"&body=Это пример отправки Email из iSeller'a";
        
        NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
        email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    /*
     NSString *message = nil;
     
     switch (result)
     {
     case MFMailComposeResultCancelled:
     message = @"Result: canceled";
     break;
     case MFMailComposeResultSaved:
     message = @"Result: saved";
     break;
     case MFMailComposeResultSent:
     message = @"Result: sent";
     break;
     case MFMailComposeResultFailed:
     message = @"Result: failed";
     break;
     default:
     message = @"Result: not sent";
     break;
     }
     */
    
    [(UIViewController*)delegate dismissModalViewControllerAnimated:YES];
}

-(void)setContactInfoWithAd:(Advertisement*) ad
{
    if(ad.user.contactEmail && ad.user.contactEmail.length)
        [contactInfo setObject:ad.user.contactEmail forKey:@"email"];
    if(ad.user.phone && ad.user.phone.length)
        [contactInfo setObject:ad.user.phone forKey:@"phone"];
    if(ad.user.skype && ad.user.skype.length)
        [contactInfo setObject:ad.user.skype forKey:@"skype"];
    [self.tableView reloadData];
}

@end
