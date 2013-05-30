//
//  MessagesDataSource.m
//  iSeller
//
//  Created by Чина on 17.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "MessagesDataSource.h"
#import "MessageCell.h"
#import "Profile.h"
#import "NSDate+Extensions.h"

@implementation MessagesDataSource
@synthesize dialog;
-(id)init
{
    self = [super init];
    if(self)
    {
        messages = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetData:) name:CHINAS_NOTIFICATION_USER_DID_LOGOUT object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDialog:) name:CHINAS_NOTIFICATION_REFRESH_DIALOG_IF_NEED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReadMessages:) name:@"DidReadMessages" object:nil];
    }
    return self;
}

-(void)updateDataWithOption:(updateDataOption)option
{
    if(isFullList && option==updateDataLoadNext) //т.е. подгружать больше нечего
        return;
    
    if(option==updateDataLoadAfter)
    {
        [Message  getMessagesWithUID:[dialog.user.identifier stringValue] adID:[dialog.ad.identifier stringValue] firstIdentifier:(messages.count ? [[((Message*)messages.lastObject) identifier] stringValue] : @"") success:^(NSArray *ads) {
            [self recalculateData:ads withOption:option];
            [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_MESSAGES_DATA_SOURCE_UPDATED object:self];
        } failure:^(NSDictionary *dict, NSError *error) {
            NSLog(@"%@, %@",dict, error);
            [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_MESSAGES_DATA_SOURCE_UPDATED object:self];
        }];
    }else
    {
        [Message  getMessagesWithUID:[dialog.user.identifier stringValue] adID:[dialog.ad.identifier stringValue] lastIdentifier:(messages.count ? [[(Message*)messages[0] identifier] stringValue] : @"") success:^(NSArray *ads) {
            [self recalculateData:ads withOption:option];
            [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_MESSAGES_DATA_SOURCE_UPDATED object:self userInfo: option==updateDataLoadNext ? @{@"newCount":[NSNumber numberWithInt:ads.count]}:nil];
        } failure:^(NSDictionary *dict, NSError *error) {
            NSLog(@"%@, %@",dict, error);
            [[NSNotificationCenter defaultCenter] postNotificationName:CHINAS_NOTIFICATION_MESSAGES_DATA_SOURCE_UPDATED object:self];
        }];
    }
}

-(void)sendMessage:(NSString*) message
{
    Message* newMessage = [[Message alloc] initWithContents:@{ @"body" : message , @"created_at" : [[NSDate date] dateToUTCWithFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"], @"incoming" : @"0", @"fresh" : @"1"}];
    [messages addObject:newMessage];
    [Message postMessage:message withIdentifier:[dialog.ad.identifier stringValue] toUserWithIdentifier:[dialog.user.identifier stringValue] success:^(id object) {
        newMessage.identifier = [(NSDictionary*) object objectForKey:@"message_id"];
    } failure:^(id object, NSError *error) {
        //[(Message*)[messages lastObject] setIdentifier:[(NSDictionary*) object objectForKey:@"message_id"]];
    }];
}

-(void)recalculateData:(NSArray *)array withOption:(updateDataOption)option
{
    if(option == updateDataLoadAfter)
    {
        for(Message* message in messages)
            if(message.isFresh.boolValue)
            {
                [message setIsFresh:@NO];
                [self didReadMessages:nil];
            }
    }
    isFullList = array.count < 10 ? YES : NO;
    if(option == updateDataWithReset)
        [messages removeAllObjects];
    
    int index = option==updateDataLoadAfter ? messages.count : 0;
    for (Message* message in array) {
        if (![self isAlreadyInMessages:message]) {
            [messages insertObject:message atIndex:index];
        }
    }
}

-(BOOL)isAlreadyInMessages:(Message*)tempMessage
{
    for(Message* message in messages)
        if([message.identifier intValue] == [tempMessage.identifier intValue])
            return YES;
    return NO;
}

-(CGFloat)calculateHeightForRow:(int) index
{
    Message* message = messages[index];
    CGSize size = [message.body sizeWithFont:[UIFont systemFontOfSize:17.0f] constrainedToSize:CGSizeMake(247, 10000) lineBreakMode:NSLineBreakByWordWrapping];
    
    return size.height+([message.incoming boolValue] ? 43.0f : 25.0f) + 10.0f;
}

#pragma mark - TableViewDataSource Method's

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageCell *cell = (MessageCell*)[tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
   
    Message* message = messages[indexPath.row];
    
    [cell setMessageInfo:message];
    
    if([message.incoming boolValue])
    {
        cell.name.text = dialog.user.name;
        [cell.avatar setImageWithURL:[NSURL URLWithString:dialog.user.avatar] placeholderImage:[UIImage imageNamed:@"smile.png"]];
    }
    else
    {
        cell.name.text = @"";
        if([[Profile sharedProfile] avatarImage])
            [cell.avatar setImage:[[Profile sharedProfile] avatarImage]];
        else
            [cell.avatar setImage:[UIImage imageNamed:@"smile.png"]];
    }
        
    return cell;
}

-(void)resetData:(NSNotification*) notification
{
    [messages removeAllObjects];
    dialog = nil;
    isFullList = NO;
}

-(void)refreshDialog:(NSNotification*) notification
{
    NSDictionary* dict = notification.object;
    if(dict && (((NSNumber*)dict[@"data"][@"uid"]).intValue != dialog.user.identifier.intValue || ((NSNumber*)dict[@"data"][@"aid"]).intValue != dialog.ad.identifier.intValue))
        return;
    [self updateDataWithOption:updateDataLoadAfter];
}

-(void)didReadMessages:(NSNotification*) notification
{
    if([[dialog freshCount] integerValue]>0)
        dialog.freshCount = [NSString stringWithFormat:@"%d",dialog.freshCount.integerValue-1];
    
    if([Profile sharedProfile].messagesCount.integerValue>0)
        [[Profile sharedProfile] setMessagesCount:[NSString stringWithFormat:@"%d",([Profile sharedProfile].messagesCount.integerValue-1)]];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
