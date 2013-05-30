//
//  MessagesDataSource.h
//  iSeller
//
//  Created by Чина on 17.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"
#import "Dialog.h"
@interface MessagesDataSource : NSObject <UITableViewDataSource>
{
    NSMutableArray* messages;
    BOOL isFullList;
}

@property(nonatomic,strong) Dialog* dialog;

-(void)updateDataWithOption:(updateDataOption)option;
-(CGFloat)calculateHeightForRow:(int) index;
-(void)sendMessage:(NSString*) message;

@end
