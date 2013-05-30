//
//  ShareView.m
//  iSeller
//
//  Created by Чина on 16.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "ShareView.h"
#import "ViewForViewerCell.h"
#import "LoaderView.h"

@implementation ShareView
@synthesize tableView = _tableView;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialSetting];
    }
    return self;
}

-(void) initialSetting
{
    CGRect rect = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height+10);
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStyleGrouped];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setBackgroundView:nil];
    [self.tableView setScrollEnabled:NO];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setRowHeight: !IS_IPHONE5 ? 42 : 44];
    [self.tableView setCenter:CGPointMake(self.tableView.center.x, self.tableView.center.y-5)];

    [self addSubview:self.tableView];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"ShareCell";
    ViewForViewerCell *cell = (ViewForViewerCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ViewForViewerCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setProsition:tableView withIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
            cell.lblTitle.text = @"Facebook";
            [cell.iconView setImage:[UIImage imageNamed:@"item_fb.png"]];
            break;
        case 1:
            cell.lblTitle.text = @"Twitter";
            [cell.iconView setImage:[UIImage imageNamed:@"item_twitter.png"]];
            break;
        case 2:
            cell.lblTitle.text = @"Email";
            [cell.iconView setImage:[UIImage imageNamed:@"item_mail.png"]];
            break;
        case 3:
            cell.lblTitle.text = @"Вконтакте";
            [cell.iconView setImage:[UIImage imageNamed:@"item_vk.png"]];
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
    if(indexPath.row!=2)
    {
        ViewForViewerCell *cell = (ViewForViewerCell*)[tableView cellForRowAtIndexPath:indexPath];
        LoaderView* loader = [[LoaderView alloc] initWithMode:loaderViewModeIndeterminate];
        [loader setFrame:CGRectMake(0, 0, loader.frame.size.width*5/8, loader.frame.size.height*5/8)];
        [loader startAnimating];
        [cell setAccessoryView:loader];
    }
    
    switch (indexPath.row) {
        case 0:
            [_delegate fbClicked];
            break;
        case 1:
            [_delegate twitterClicked];
            break;
        case 2:
            [_delegate emailClicked];
            break;
        case 3:
            [_delegate vkClicked];
    }
}

-(void)socialPostingSucceded:(NSDictionary*) userInfo
{
    ViewForViewerCell *cell;
    
    if([userInfo[@"provider"] isEqualToString:@"fb"])
        cell = (ViewForViewerCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    else if([userInfo[@"provider"] isEqualToString:@"vk"])
        cell = (ViewForViewerCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    else if([userInfo[@"provider"] isEqualToString:@"tw"])
        cell = (ViewForViewerCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    else
        return;
    
    UIImageView* accessory = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dialog_accessory.png"]];
    __block CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI/2);
    [accessory setTransform:transform];
    [cell setAccessoryView:accessory];
    [UIView animateWithDuration:0.5f delay:0.5f options:0 animations:^{
        [accessory setTransform:CGAffineTransformMakeRotation(0)];
    } completion:nil
     ];
}


@end
