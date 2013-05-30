//
//  DialogsDataSource.h
//  iSeller
//
//  Created by Чина on 16.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dialog.h"

@interface DialogsDataSource : NSObject <UITableViewDataSource>
{
    NSMutableArray* dialogs;
    BOOL isFullList;
    Dialog* tempDialog; //диалог для поиска из списка того что пришло в пуше
}

-(void)updateDataWithOption:(updateDataOption)option;

-(Dialog* )getAdAtIndex:(int)index;

@end
