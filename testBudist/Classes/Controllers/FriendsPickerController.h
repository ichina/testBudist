//
//  FriendsPickerController.h
//  iSeller
//
//  Created by Чингис on 29.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendsPickerDataSource.h"
#import "BinarySegmentControl.h"

@interface FriendsPickerController : UIViewController <UITableViewDelegate,UISearchBarDelegate,BinarySegmentDelegate>
{
    BOOL fbIsDataLoading;
    BOOL vkIsDataLoading;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (retain, nonatomic) NSString *searchText;
@property (strong, nonatomic) BinarySegmentControl *segmentedControl;

- (IBAction)inviteFriends:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) FriendsPickerDataSource* dataSource;
@end
