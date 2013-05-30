//
//  FriendsPickerDataSource.m
//  iSeller
//
//  Created by Чингис on 29.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "FriendsPickerDataSource.h"
#import "ViewForViewerCell.h"
#import <FacebookSDK.h>
#import "UIImageView+AFNetworking.h"
#import "CGSocialManager.h"
#import "Advertisement.h"
#import "CGSocialManager+VKcom.h"
#import "Profile.h"
#import "NSDate+Extensions.h"

#define kVKFriendsFirstPackSize 20

@implementation FriendsPickerDataSource
@synthesize fbIsFullList;
@synthesize isVKFullList;
@synthesize isRequestFBSended;
@synthesize isRequestVKSended;

-(id)init
{
    self = [super init];
    if(self)
    {
        FBfriends = [[NSMutableArray alloc] init];
        VKfriends = [[NSMutableArray alloc] init];
        filteredFriends = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetData:) name:CHINAS_NOTIFICATION_USER_DID_LOGOUT object:nil];
    }
    return self;
}

-(void)updateDataWithOption:(updateDataOption)option
{
    if(self.selectedSegmentIndex==0)
    {
        
        if(fbIsFullList && option==updateDataLoadNext) {
            
            [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"FriendsPicker" withAction:[NSString stringWithFormat:@"Total Facebook friends count: %i", FBfriends.count] withLabel:[NSString stringWithFormat:@"(%@) %@", [[NSDate date] dateToUTCWithFormat:nil], [NSStringFromClass([self class]) substringToIndex:NSStringFromClass([self class]).length-10]] withValue:nil];
            
            //т.е. подгружать больше нечего
            return;
        }
        
        /*
        if(FBfriends.count==0)
        {
            //static BOOL isRequestSended;
            if (!isRequestFBSended) {
                [self sentRequest];
            };
            isRequestFBSended = YES;
        }
         */
        //else
        //    [self filter];offset=%i
        fbOption = option;
        [self sentRequestWithOffset:(option==updateDataWithReset)?0:FBfriends.count count:20];
        
    }
    else
    {
        if(isVKFullList && option==updateDataLoadNext) {
            
            [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"FriendsPicker" withAction:[NSString stringWithFormat:@"Total Vkontakte friends count: %i", VKfriends.count] withLabel:[NSString stringWithFormat:@"(%@) %@", [[NSDate date] dateToUTCWithFormat:nil], [NSStringFromClass([self class]) substringToIndex:NSStringFromClass([self class]).length-10]] withValue:nil];
            
            //т.е. подгружать больше нечего
            return;
        }
        
        if(!isVKFullList) {
        
            [self getVKFriends:kVKFriendsFirstPackSize andOffset:VKfriends.count];
            
        }
        
//        if(VKfriends.count==0)
//        {
//            //static BOOL isRequestSended;
//            if (!isRequestVKSended) {
//                [self getVKFriends:kVKFriendsFirstPackSize andOffset:0];
//                
//                isRequestVKSended = YES;
//                                
//            }
//        }else if(VKfriends.count == kVKFriendsFirstPackSize && option == updateDataLoadNext){
//            
//            [self getVKFriends:0 andOffset:kVKFriendsFirstPackSize];
//            
//        }else if(VKfriends.count > kVKFriendsFirstPackSize && option == updateDataLoadNext) {
//            
//            return;
//            
//        }
        
        //else
        //    [self filter];
    }
    
    //[self filter];
    
    [filteredFriends removeAllObjects];
    [filteredFriends addObjectsFromArray:(self.selectedSegmentIndex==0)?FBfriends:VKfriends];
    [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_FRIENDSPICK_DATA_SOURCE_UPDATED object:self userInfo:@{@"option": @"just_update"}];

}

-(void)sentRequestWithOffset:(int)offset count:(int)count
{
    // me or one of my friends that also uses the app
    NSString* user = @"me";
    
    
    FBRequest *request = [FBRequest requestForGraphPath:[NSString stringWithFormat:@"%@/friends", user]];
    [request setSession:[FBSession activeSession]];
    
    // Use field expansion to fetch a 100px wide picture if we're on a retina device.
    NSString *pictureField = (IS_RETINA) ? @"picture.width(100).height(100)" : @"picture";
    
    NSArray *allFields = [NSArray arrayWithObjects:
                          @"id",
                          @"name",
                          @"installed",
                          pictureField,
                          nil];
    
    [request.parameters setObject:[allFields componentsJoinedByString:@","] forKey:@"fields"];
    [request.parameters setObject:[NSString stringWithFormat:@"%d",count] forKey:@"limit"];
    [request.parameters setObject:[NSString stringWithFormat:@"%d",offset] forKey:@"offset"];

    
    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
    [connection addRequest:request
         completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             [self requestCompleted:connection result:result error:error];
         }];
    [connection start];
}


- (void)requestCompleted:(FBRequestConnection *)connection
                  result:(id)result
                   error:(NSError *)error {
    if (error) {
        
        if(![FBSession activeSession].isOpen)
            [FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                if(status == FBSessionStateOpen || status == FBSessionStateOpenTokenExtended)
                    [self sentRequestWithOffset:0 count:20]; //бля палюбому только для первой двацатки 
                if(status == FBSessionStateClosedLoginFailed)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_FB_AUTH_CANCELED object:[CGSocialManager sharedSocialManager]];
                }
            }];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_FRIENDSPICK_DATA_SOURCE_UPDATED object:self];
        return;
    }
    if(fbOption==updateDataWithReset)
        [FBfriends removeAllObjects];
    
    NSDictionary *resultDictionary = (NSDictionary *)result;
    
    if(resultDictionary[@"data"] && [resultDictionary[@"data"] isKindOfClass:[NSArray class]])
    {
        NSArray* array = resultDictionary[@"data"];
    
        fbIsFullList = (array.count<20);
        
        for (NSDictionary* dict in array) {
            [FBfriends addObject:[[FBFriend alloc] initWithFBContents:dict]];
        }
    }
    /*
    if(resultDictionary[@"paging"] && resultDictionary[@"paging"][@"next"])
    {
        NSLog(@"next page %@",resultDictionary[@"paging"][@"next"]);
        fbNextPageUrl = resultDictionary[@"paging"][@"next"];
    }
     */
    [self filter];
    
}

#pragma mark - TableViewDataSource Method's

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return filteredFriends.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //ViewForViewerCell* cell = (ViewForViewerCell*)[tableView dequeueReusableCellWithIdentifier:self.selectedSegmentIndex==0? @"FriendPickerCell" : @"VKFriendPickerCell"];
    ViewForViewerCell* cell = (ViewForViewerCell*)[tableView dequeueReusableCellWithIdentifier:@"FriendPickerCell"];
    [cell setHighlightionStyle:CellHighlightionNone];
    
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setProsition:tableView withIndexPath:indexPath];
    
    //[cell.iconView setImage:[UIImage imageNamed:@"item_message.png"]];
    NSString* urlString = [(FBFriend*)filteredFriends[indexPath.row] imageUrl];
    [cell.iconView setImageWithURL:[NSURL URLWithString:urlString] placeholderfileName:@"smile.png"];
    cell.lblTitle.text = [(FBFriend*)filteredFriends[indexPath.row] name];
    cell.lblTitle.textColor = [UIColor whiteColor];
    cell.lblTitle.shadowColor = [UIColor blackColor];
    cell.lblTitle.shadowOffset = CGSizeMake(0, 1);
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    //if(self.selectedSegmentIndex==0)
    {
        if(!cell.accessoryView)
            [cell setAccessoryView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"items_galka.png"]]];
        [cell.accessoryView setHidden:![(FBFriend*)filteredFriends[indexPath.row] installed] && ![(FBFriend*)filteredFriends[indexPath.row] needInvite]];
        
        UIImageView *imageView = (UIImageView*)[cell viewWithTag:55];
        if(!imageView)
        {
            imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"items_galka_frame"]];
            [imageView setFrame:CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height)];
            [imageView setCenter:CGPointMake(294, 23)];
            [cell addSubview:imageView];
            [imageView setTag:55];
        }
        [imageView setHidden:[(FBFriend*)filteredFriends[indexPath.row] installed]];
    }
    /*
    else
    {
        UIButton* btn = (UIButton*)[cell viewWithTag:60];
        if(!btn)
        {
            btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [btn setFrame:CGRectMake(250, 4, 50, 36)];
            [btn setTitle:@"Позвать" forState:UIControlStateNormal];
            [btn setTag:60];
            [cell addSubview:btn];
            [btn addTarget:self action:@selector(inviteVKFriend2:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
     */
    
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:1000];
    if(!imageView)
    {
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dialog_avatar_frame.png"]];
        [imageView setFrame:CGRectInset(cell.iconView.frame, -2, -2)];
        //[imageView setCenter:CGPointMake(294, 23)];
        [cell addSubview:imageView];
        [imageView setTag:1000];
    }
    
    return cell;
}

-(FBFriend* )getAdAtIndex:(int)index
{
    return index<filteredFriends.count ? [filteredFriends objectAtIndex:index] : nil;
}

-(void)resetData:(NSNotification*) notification
{
    [FBfriends removeAllObjects];
    [VKfriends removeAllObjects];
    fbIsFullList = NO;
    isVKFullList = NO;
}

-(void)filter
{
    [filteredFriends removeAllObjects];
    if (self.searchText && ![self.searchText isEqualToString:@""])
    {
        NSArray* array = (self.selectedSegmentIndex==0)?FBfriends:VKfriends;
        for(FBFriend* friend in array)
        {
            NSRange result = [[friend.name lowercaseString]
                              rangeOfString:[self.searchText lowercaseString]];
            if (result.location != NSNotFound) {
                [filteredFriends addObject:friend];
            }
        }
    }
    else
    {
        [filteredFriends addObjectsFromArray:(self.selectedSegmentIndex==0)?FBfriends:VKfriends];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_FRIENDSPICK_DATA_SOURCE_UPDATED object:self];
}

-(void)inviteFriends
{
    
    NSMutableArray* array = [[NSMutableArray alloc] init];
    for(FBFriend* friend in FBfriends)
    {
        if(friend.needInvite && !friend.installed)
        {
            [array addObject:friend.identifier];
        }
    }
    if(array.count>0) {
        
        [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"FriendsPicker" withAction:[NSString stringWithFormat:@"Invited %i friends from Facebook in one round", array.count] withLabel:[NSString stringWithFormat:@"(%@) %@", [[NSDate date] dateToUTCWithFormat:nil], [NSStringFromClass([self class]) substringToIndex:NSStringFromClass([self class]).length-10]] withValue:nil];
        
        [[CGSocialManager sharedSocialManager] inviteFriendFB:array];
    }

    NSMutableArray* array2 = [[NSMutableArray alloc] init];
    for(FBFriend* friend in VKfriends)
    {
        if(friend.needInvite && !friend.installed)
        {
            [array2 addObject:friend.identifier];
        }
    }
    if(array2.count>0) {
        
        [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"FriendsPicker" withAction:[NSString stringWithFormat:@"Invited %i friends from Vkontakte in one round", array2.count] withLabel:[NSString stringWithFormat:@"(%@) %@", [[NSDate date] dateToUTCWithFormat:nil], [NSStringFromClass([self class]) substringToIndex:NSStringFromClass([self class]).length-10]] withValue:nil];
        
        [[CGSocialManager sharedSocialManager] inviteFriendVK:array2];
    }
    
    if((array.count+array2.count)==0)
    {
        [[[CGAlertView alloc] initWithTitle:NSLocalizedString(@"Error",nil) message:NSLocalizedString(@"Select At least one other", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

/*
-(void)inviteVKFriend:(int) index
{
    if(self.selectedSegmentIndex)
    {
        FBFriend* vkFriend = (FBFriend*)filteredFriends[index];
        [[CGSocialManager sharedSocialManager] postOnVKFeed:nil userID:vkFriend.identifier notification:nil];
    }
}


-(void)inviteVKFriend2:(UIButton*)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GET_INDEX_VK_FRIEND_CELL" object:self userInfo:@{@"cell": sender.superview}];
}
*/

- (void)getVKFriends:(NSInteger)count andOffset:(NSInteger)offset
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vkFriendsRecieved:) name:@"VK_FRIENDS_RECEIVED" object:[CGSocialManager sharedSocialManager]];
    [[CGSocialManager sharedSocialManager] getVKFriends:count andOffset:offset];
}

-(void)vkFriendsRecieved:(NSNotification*) notification
{
    if(notification.userInfo[@"friends"])
    {
        NSLog(@"%@",notification.userInfo[@"friends"]);
        NSArray* array = notification.userInfo[@"friends"][@"response"];
        if(array)
        {
            for (NSDictionary* dict in array) {
                [VKfriends addObject:[[FBFriend alloc] initWithVKContents:dict]];
            }
            
            if(array.count < kVKFriendsFirstPackSize) {
                
                isVKFullList = YES;
                
            }
        }
    }
    
    if(notification.userInfo[@"error"])
    {
        [[[CGAlertView alloc] initWithTitle:@"Vkontakte" message:NSLocalizedString(@"Fail to get friends.", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VK_FRIENDS_RECEIVED" object:[CGSocialManager sharedSocialManager]];
    [self filter];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VK_FREIND_RECEIVED" object:[CGSocialManager sharedSocialManager]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHINAS_NOTIFICATION_USER_DID_LOGOUT object:nil];
}
@end
