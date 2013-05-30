//
//  FriendsPickerDataSource.h
//  iSeller
//
//  Created by Чингис on 29.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBFriend.h"

@interface FriendsPickerDataSource : NSObject <UITableViewDataSource>
{
    NSMutableArray* FBfriends;
    NSMutableArray* VKfriends;
    NSMutableArray* filteredFriends;
    NSString* nextPageUrl;
    NSString* fbNextPageUrl;
    updateDataOption fbOption;
    //BOOL isRequestVKSended,isRequestFBSended;
}
@property (nonatomic) BOOL isRequestVKSended;
@property (nonatomic) BOOL isRequestFBSended;

@property(nonatomic) BOOL isVKFullList;
@property(nonatomic) BOOL fbIsFullList;

@property (retain, nonatomic) NSString *searchText;
@property( nonatomic) NSInteger selectedSegmentIndex;

-(void)inviteFriends;

-(void)updateDataWithOption:(updateDataOption)option;

-(void)filter;

-(FBFriend* )getAdAtIndex:(int)index;
@end
