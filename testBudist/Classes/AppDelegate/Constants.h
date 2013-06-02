//
//  AppDelegate.h
//  seller
//
//  Created by Чина on 01.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#pragma mark --
#pragma mark NOTIFICATIONS_CONSTANTS

#define CHINAS_NOTIFICATION_DATA_SOURCE_UPDATED @"CHINAS_NOTIFICATION_DATA_SOURCE_UPDATED"


#pragma mark --
#pragma mark CONSTANTS

#ifdef DEBUG

    #define HOST @"http://budist.ru"

#else

    #define HOST @"http://budist.ru"

#endif


#define IS_IPHONE5 CGSizeEqualToSize([[UIScreen mainScreen] preferredMode].size,CGSizeMake(640, 1136))
#define IS_RETINA !CGSizeEqualToSize([[UIScreen mainScreen] preferredMode].size,CGSizeMake(320, 480)) && !CGSizeEqualToSize([[UIScreen mainScreen] preferredMode].size,CGSizeMake(1024, 768))

#define IS_IPHONE UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone
#define IS_IPAD !IS_IPHONE

#define IS_SIMULATOR [[[UIDevice currentDevice] model]isEqualToString:@"iPhone Simulator"]


///api path's
#define CHECK_PHONE_PATH @"records/list"//@"auth/login/check"
#define AUTH_PATH @"auth/login"
#define ALARM_LIST_PATH @"records/list"

#pragma mark SEGUES
#define kSegueFromTableToAlarm @"kSegueFromTableToAlarm"

typedef enum
{
    updateDataWithReset = 0,
    updateDataLoadNext,
    updateDataLoadAfter
}
updateDataOption;

