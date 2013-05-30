//
//  DialogsDataSource.m
//  iSeller
//
//  Created by Чина on 16.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "DialogsDataSource.h"
#import "DialogMainCell.h"
#import "Profile.h"
@implementation DialogsDataSource

-(id)init
{
    self = [super init];
    if(self)
    {
        dialogs = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetData:) name:CHINAS_NOTIFICATION_USER_DID_LOGOUT object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotificationInBackground:) name:CHINAS_NOTIFICATION_DID_RECEIVE_NOTIFICATION object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMessage:) name:@"DidReceiveMessage" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dialogNeedMoveToTop:) name:CHINAS_NOTIFICATION_DIALOG_NEED_MOVE_TO_TOP object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkActualityOfDialogs:) name:CHINAS_NOTIFICATION_DIALOGS_CHECK_ACTUALLITY object:[Profile sharedProfile]];
    }
    return self;
}

-(void)updateDataWithOption:(updateDataOption)option
{
    if(isFullList && option==updateDataLoadNext) //т.е. подгружать больше нечего
        return;
    
    [Dialog  getDialogsWithLastIdentifier:(dialogs.count && option!=updateDataWithReset ? [[(Dialog*)dialogs.lastObject identifier] stringValue] : @"") success:^(NSArray *ads) {
        [self recalculateData:ads withOption:option];
        [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_DIALOGS_DATA_SOURCE_UPDATED object:nil];
        if(tempDialog)
            [self tryFindDialog];
    } failure:^(NSDictionary *dict, NSError *error) {
        NSLog(@"%@, %@",dict, error);
        [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_DIALOGS_DATA_SOURCE_UPDATED object:nil];
    }];
    
    if(updateDataWithReset==option)
        [[Profile sharedProfile] checkMessagesStateAfterUpdateDialogs];
}

-(void)recalculateData:(NSArray *)array withOption:(updateDataOption)option
{
    isFullList = array.count < 10 ? YES : NO;
    
    if(option==updateDataWithReset){
        
        for(Dialog* newDialog in array)
        {
            for(int i = 0 ; i < dialogs.count; i++ )
            {
                Dialog* oldDialog = dialogs[i];
                if([newDialog isEqualToDialog:oldDialog])
                {
                    [dialogs removeObjectAtIndex:i];
                    break;
                }
            }
            [dialogs insertObject:newDialog atIndex:[array indexOfObject:newDialog]];
        }
        //hdjsk
    }
    else
        [dialogs addObjectsFromArray:array];
}

#pragma mark - TableViewDataSource Method's

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dialogs.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DialogMainCell *cell = (DialogMainCell*)[tableView dequeueReusableCellWithIdentifier:@"DialogMainCell"];
    
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setProsition:tableView withIndexPath:indexPath];
    if(dialogs.count<=indexPath.row)
        return cell;
    [cell setDialogInfo:dialogs[indexPath.row]];
    
    return cell;
}

-(Dialog*)getAdAtIndex:(int)index
{
    return index<dialogs.count ? dialogs [index] : [[Dialog alloc] initWithContents:nil];
}

-(void)resetData:(NSNotification*) notification
{
    [dialogs removeAllObjects];
    isFullList = NO;
}


#pragma mark - методы для обработки получения пуш нотификаций

-(void)didReceiveNotificationInBackground:(NSNotification*) notification
{
    NSDictionary* tempDict = (NSDictionary*)notification.object;
    
    tempDialog = [[Dialog alloc] initWithContents:@{@"ad" : @{@"id":tempDict[@"data"][@"aid"]}, @"user" :@{@"id" : tempDict[@"data"][@"uid"]}}];

    [self updateDataWithOption:updateDataWithReset];
}

-(void)tryFindDialog
{
    for(Dialog* dialog in dialogs)
    {
        if(([dialog.ad.identifier integerValue] == [tempDialog.ad.identifier integerValue]) && ([dialog.user.identifier integerValue] == [tempDialog.user.identifier integerValue]))
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_NEED_UPDATE_UI_IN_DIALOG object:dialog];
            tempDialog = nil;
            break;
        }
    }
}

-(void)didReceiveMessage:(NSNotification*) notification
{
    //NSLog(@"%@",notification.userInfo);
    if(![notification.userInfo[@"type"] isEqualToNumber:@0])
        return;
    NSLog(@"%@",notification.userInfo[@"type"]);
    NSDictionary* dict = [notification.userInfo objectForKey:@"data"];
    Dialog* _tempDialog;
    for(Dialog* dialog in dialogs)
    {
        if(([dialog.ad.identifier integerValue] == [dict[@"aid"] integerValue]) && ([dialog.user.identifier integerValue] == [dict[@"uid"] integerValue]))
        {
            _tempDialog = dialog;
            break;
        }
    }
    if(_tempDialog)
    {
        NSString *aps = [[notification.userInfo objectForKey:@"aps"] objectForKey:@"alert"];
        NSMutableArray *array = [NSMutableArray arrayWithArray:[aps componentsSeparatedByString:@": "]];
        [array removeObjectAtIndex:0];
        NSString *message = [array componentsJoinedByString:@": "];
        _tempDialog.incoming = @YES;
        _tempDialog.body = message;
        _tempDialog.freshCount = [NSString stringWithFormat:@"%d",_tempDialog.freshCount.integerValue+1];
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[dialogs indexOfObject:_tempDialog] inSection:0];
        [dialogs removeObject:_tempDialog];
        [dialogs insertObject:_tempDialog atIndex:0];
        [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_MOVE_ROW_TO_TOP object:self userInfo:@{@"indexPath" : indexPath, @"message" : message}];
       
    }
    else
        [self updateDataWithOption:updateDataWithReset];
}

-(void)dialogNeedMoveToTop:(NSNotification*) notification
{
    Dialog* _tempDialog = (Dialog*) notification.object;
    for(int i = 1 ; i< dialogs.count ; i++)   // для нулевого не имеет смысла
    {
        Dialog* dialog = dialogs[i];
        if(([dialog.ad.identifier integerValue] == [_tempDialog.ad.identifier integerValue]) && ([dialog.user.identifier integerValue] == [_tempDialog.user.identifier integerValue]))
        {
            [dialogs removeObject:dialog];
            [dialogs insertObject:dialog atIndex:0];
        }
    }
}

-(void)checkActualityOfDialogs:(NSNotification*) notification
{
    NSDictionary* userInfo = notification.userInfo;
    if(dialogs.count>0 && [userInfo[@"latest"] integerValue]>[[(Dialog*)dialogs[0] identifier] integerValue])
    {
        [self updateDataWithOption:updateDataWithReset];
    }
}

@end
