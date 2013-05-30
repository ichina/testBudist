//
//  AppDelegate.h
//  seller
//
//  Created by Чина on 01.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#pragma mark --
#pragma mark NOTIFICATIONS_CONSTANTS

#define CHINAS_NOTIFICATION_SOCIAL_ACCESS_TOKEN_RECEIVED @"CHINAS_NOTIFICATION_SOCIAL_ACCESS_TOKEN_RECEIVED"
#define PAULS_NOTIFICATION_VK_WILL_SHOW_WINDOW @"PAULS_NOTIFICATION_VK_WILL_SHOW_WINDOW"
#define PAULS_NOTIFICATION_SOCIAL_POSTING_SUCCEEDED @"PAULS_NOTIFICATION_POSTING_SUCCEEDED"
#define PAULS_NOTIFICATION_SOCIAL_POSTING @"PAULS_NOTIFICATION_SOCIAL_POSTING"
#define CHINAS_NOTIFICATION_SESSION_IS_OPEN @"CHINAS_NOTIFICATION_SESSION_IS_OPEN"
#define CHINAS_NOTIFICATION_AD_RECEIVED @"CHINAS_NOTIFICATION_AD_RECEIVED"
#define CHINAS_NOTIFICATION_DEVICE_TOKEN_DID_REGISTERED @"CHINAS_NOTIFICATION_DEVICE_TOKEN_DID_REGISTERED"
#define CHINAS_NOTIFICATION_PROFILE_AVATAR_DID_CHANGED @"CHINAS_NOTIFICATION_PROFILE_AVATAR_DID_CHANGED"
#define CHINAS_NOTIFICATION_DID_RECEIVE_NOTIFICATION @"CHINAS_NOTIFICATION_DID_RECEIVE_NOTIFICATION"
#define CHINAS_NOTIFICATION_NEED_UPDATE_UI_IN_DIALOG @"CHINAS_NOTIFICATION_NEED_UPDATE_UI_IN_DIALOG"
#define CHINAS_NOTIFICATION_SHOW_TEXT_IN_STATUSBAR @"CHINAS_NOTIFICATION_SHOW_TEXT_IN_STATUSBAR"
#define CHINAS_NOTIFICATION_STATUSBAR_CLICKED @"CHINAS_NOTIFICATION_STATUSBAR_CLICKED"
#define CHINAS_NOTIFICATION_REFRESH_DIALOG_IF_NEED @"CHINAS_NOTIFICATION_REFRESH_DIALOG_IF_NEED"
#define CHINAS_NOTIFICATION_REFRESH_SEARCH_AFTER_CREATE_AD @"CHINAS_NOTIFICATION_REFRESH_SEARCH_AFTER_CREATE_AD"
#define CHINAS_NOTIFICATION_SHARE_TO_FACEBOOKS_FRIENDS @"CHINAS_NOTIFICATION_SHARE_TO_FACEBOOK'S_FRIENDS"
#define CHINAS_NOTIFICATION_NEED_TO_DISSMISS_AUTH_CONTROLLER @"CHINAS_NOTIFICATION_NEED_TO_DISSMISS_AUTH_CONTROLLER"
#define CHINAS_NOTIFICATION_NEED_TO_PRESENT_AUTH_CONTROLLER @"CHINAS_NOTIFICATION_NEED_TO_PRESENT_AUTH_CONTROLLER"
#define CHINAS_NOTIFICATION_USER_DID_LOGOUT @"CHINAS_NOTIFICATION_USER_DID_LOGOUT"
#define CHINAS_NOTIFICATION_ANNOTATION_VIEW_TAPPED @"CHINAS_NOTIFICATION_ANNOTATION_VIEW_TAPPED"
#define CHINAS_NOTIFICATION_UPDATE_BADGE_VALUE_FROM_PROFILE @"CHINAS_NOTIFICATION_UPDATE_BADGE_VALUE_FROM_PROFILE"
#define CHINAS_NOTIFICATION_MOVE_ROW_TO_TOP @"CHINAS_NOTIFICATION_MOVE_ROW_TO_TOP"
#define CHINAS_NOTIFICATION_DIALOG_NEED_MOVE_TO_TOP @"CHINAS_NOTIFICATION_DIALOG_NEED_MOVE_TO_TOP"
//data sources updated
#define CHINAS_NOTIFICATION_SEARCH_DATA_SOURCE_UPDATED @"CHINAS_NOTIFICATION_SEARCH_DATA_SOURCE_UPDATED"
#define CHINAS_NOTIFICATION_FAV_DATA_SOURCE_UPDATED @"CHINAS_NOTIFICATION_FAV_DATA_SOURCE_UPDATED"
#define CHINAS_NOTIFICATION_DIALOGS_DATA_SOURCE_UPDATED @"CHINAS_NOTIFICATION_DIALOGS_DATA_SOURCE_UPDATED"
#define CHINAS_NOTIFICATION_MESSAGES_DATA_SOURCE_UPDATED @"CHINAS_NOTIFICATION_MESSAGES_DATA_SOURCE_UPDATED"
#define CHINAS_NOTIFICATION_MY_ITEMS_DATA_SOURCE_UPDATED @"CHINAS_NOTIFICATION_MY_ITEMS_DATA_SOURCE_UPDATED"
//gridviewcell tapped
#define CHINAS_NOTIFICATION_GRIDVIEWCELL_TAPPED @"CHINAS_NOTIFICATION_GRIDVIEWCELL_TAPPED"
#define CHINAS_NOTIFICATION_PAYMENTS_DATA_SOURCE_UPDATED @"CHINAS_NOTIFICATION_PAYMENTS_DATA_SOURCE_UPDATED"
#define CHINAS_NOTIFICATION_GO_TO_PURCHASING @"CHINAS_NOTIFICATION_GO_TO_PURCHASING"
#define CHINAS_NOTIFICATION_FRIENDSPICK_DATA_SOURCE_UPDATED @"CHINAS_NOTIFICATION_FRIENDSPICK_DATA_SOURCE_UPDATED"

#define CHINAS_NOTIFICATION_ALLOW_ROTATING_IN_FULL_SIZE @"CHINAS_NOTIFICATION_ALLOW_ROTATING_IN_FULL_SIZE"

#define CHINAS_NOTIFICATION_NEED_AUTH_WITH_SOCIAL @"CHINAS_NOTIFICATION_NEED_AUTH_WITH_SOCIAL"
#define CHINAS_NOTIFICATION_DIALOGS_CHECK_ACTUALLITY @"CHINAS_NOTIFICATION_DIALOGS_CHECK_ACTUALLITY"

#define CHINAS_NOTIFICATION_VK_AUTH_CANCELED @"CHINAS_NOTIFICATION_VK_AUTH_CANCELED"
#define CHINAS_NOTIFICATION_FB_AUTH_CANCELED @"CHINAS_NOTIFICATION_FB_AUTH_CANCELED"

#define CHINAS_NOTIFICATION_NEED_UPDATE_FEED_DATA_SOURCE @"CHINAS_NOTIFICATION_NEED_UPDATE_FEED_DATA_SOURCE"

#define TAB_BAR_HEIGHT 43.5f
#define ACTIVITY_INDICATOR_TAG 166


#pragma mark --
#pragma mark CONSTANTS

//#define localhost @"staging.iseller.pro"
//#define HOST @"http://ru.api.iseller.pro"

#ifdef DEBUG
    #define DEV_HOST @"http://dev.iseller.pro"
    #define HOST @"http://api.iseller.pro"

    // Аналитика
    #define GA_ID @"UA-36729976-1"

#else

    #define DEV_HOST @"http://iseller.pro"
    #define HOST @"http://ru.api.iseller.pro"

    // Аналитика
    #define GA_ID @"UA-36729976-3"

#endif

//#define DEV_HOST @"http://dev.iseller.pro"

#define IS_IPHONE5 CGSizeEqualToSize([[UIScreen mainScreen] preferredMode].size,CGSizeMake(640, 1136))
#define IS_RETINA !CGSizeEqualToSize([[UIScreen mainScreen] preferredMode].size,CGSizeMake(320, 480)) && !CGSizeEqualToSize([[UIScreen mainScreen] preferredMode].size,CGSizeMake(1024, 768))

#define IS_IPHONE UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone
#define IS_IPAD !IS_IPHONE

#define IS_SIMULATOR [[[UIDevice currentDevice] model]isEqualToString:@"iPhone Simulator"]

//#define ACCESS_TOKEN [[NSUserDefaults standardUserDefaults] objectForKey:@"token"]
#define ACCESS_TOKEN [[MyProfileSingleton sharedMyProfileSingleton] token]
#define SET_ACCESS_TOKEN(token) [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"]
#define SYNCHRONIZE_USER_DEFAULTS [[NSUserDefaults standardUserDefaults] synchronize]

//#define BUILD_URL(METHOD_NAME,PARAMS) [NSString stringWithFormat:@"http://%@/%@?token=%@&%@",host,METHOD_NAME,ACCESS_TOKEN,PARAMS,nil] //для составления url запроса;
#define BUILD_URL(METHOD_NAME) [NSString stringWithFormat:@"http://%@/%@",host,METHOD_NAME,nil]
#define AUTH_URL [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@",host,@"profile/login",nil]]

///api path's
#define AUTH_PATH @"profile/login"
#define SEARCH_PATH @"ads/search"
#define MAP_SEARCH_PATH @"/ads/map_search"
#define FAV_LIST_PATH @"favorites"

#define MY_ADS_PATH @"/ads/personal?token=tokenKey"

#define POST_AD @"/ads?token=tokenKey"
#define EDIT_AD @"/ads/idKey?token=tokenKey"
#define DELETE_AD @"/ads/idKey?token=tokenKey"
#define ADD_TO_TOP_AD @"/ads/idKey/up?token=tokenKey"

#define TOKEN_PATH @"profile?token=tokenKey"
#define FB_PATH @"authentications"
#define SIGN_UP_PATH @"profile"
#define PUT_PROFILE_PATH @"profile?token=tokenKey"
#define ADD_DEVICE_PATH @"profile/devices?token=tokenKey"
#define REMOVE_DEVICE_PATH @"profile/devices/idKey?token=tokenKey"
#define RESTORE_PASS_PATH @"users/send_reset_token"
#define CONFIRM_EMAIL_PATH @"profile/send_confirmation?token=tokenKey"
#define GET_BALANCE_PATH @"profile/balance?token=tokenKey"

#define AD_PATH @"/ads/idKey"

#define ADD_FAV_PATH @"/ads/idKey/favorites?token=tokenKey"
#define DELETE_FAV_PATH @"/favorites/idKey?token=tokenKey"

#define DIALOGS_LIST_PATH @"/profile/conversations?token=tokenKey"
#define DIALOG_PATH @"/users/userKey/conversation/idKey?token=tokenKey"
#define POST_DIALOG_PATH @"/users/userKey/message/idKey?token=tokenKey"
#define MESSAGES_STATE_PATH @"profile/messages_state?token=tokenKey"

#define POST_RECEIPTS_PATH @"payments?token=tokenKey"
#define PAYMENT_STATUS_PATH @"payments/idKey?token=tokenKey"
#define PAYMENT_HISTORY_PATH @"profile/reports?token=tokenKey"//@"payments?token=tokenKey"


#define ADD_DEVICE_REQUEST 300
#define REMOVE_DEVICE_REQUEST 300
//#define FBSessionStateChangedNotification @"com.CloudTeam.saler.Login:FBSessionStateChangedNotification";

#pragma mark SEGUES
#define kSegueFromSearchToAd @"kSegueFromSearchToAd"
#define kSegueFromFavToAd @"kSegueFromFavToAd"
#define kSegueFromMyItemsToAd @"kSegueFromMyItemsToAd"
#define kSegueFromProfileToMyItems @"kSegueFromProfileToMyItems"
#define kSegueFromProfileToEdit @"kSegueFromProfileToEdit"
#define kSegueFromCreateToCamOverlay @"kSegueFromCreateToCamOverlay"
#define kSegueFromEditAdToCamOverlay @"kSegueFromEditAdToCamOverlay"
#define kSegueFromEditProfileToCamOverlay @"kSegueFromEditProfileToCamOverlay"
#define kSegueFromProfileToPaymentSetting @"kSegueFromProfileToPaymentSetting"
#define kSegueFromBalanceToPaymentHistory @"kSegueFromBalanceToPaymentHistory"
#define kSegueFromBalanceToPurchasing @"kSegueFromBalanceToPurchasing"
#define kSegueFromSearchToMap @"kSegueFromSearchToMap"
#define kSegueFromAdToFullSize @"kSegueFromAdToFullSize"
#define kSegueFromAdToEdit @"kSegueFromAdToEdit"
#define kSegueFromDialogToAd @"kSegueFromDialogToAd"
#define kSegueFromMapToAd @"kSegueFromMapToAd"
#define kSegueFromClusterToAnnotationsList @"kSegueFromClusterToAnnotationsList"
#define kSegueFromAnnotationListToAd @"kSegueFromAnnotationListToAd"
#define kSegueFromProfileToPaymentHistory @"kSegueFromProfileToPaymentHistory"
#define kSegueFromPaymentHistoryToPurchase @"kSegueFromPaymentHistoryToPurchase"
#define kSegueFromProfileToCamOverlay @"kSegueFromProfileToCamOverlay"
#define kSegueFromAdvertisementToPurchase @"kSegueFromAdvertisementToPurchase"
#define kSegueFromCreateToPurchase @"kSegueFromCreateToPurchase"
#define kSegueFromAuthToTutorial @"kSegueFromAuthToTutorial"
#define kSegueFromAboutToTutorial @"kSegueFromAboutToTutorial"
#define kSegueFromProfileToFriendPicker @"kSegueFromProfileToFriendPicker"

#pragma mark --
#pragma mark REQUESTS_TAGS

#define SEARCH_REQUEST_NO_EXCLUDED 600
#define SEARCH_REQUEST_WITH_EXCLUDED 601
#define PERSONAL_ADS_REQUEST_FIRST 602
#define PERSONAL_ADS_REQUEST_LATER 603
#define PROFILE_PAYMENTS_FIRST_REQUEST_TAG 604
#define PROFILE_PAYMENTS_NON_FIRST_REQUEST_TAG 605

#pragma mark --
#pragma mark PRODUCT_ID'S

#define COINS10 @"pro.cloudteam.iseller.10coins"
#define COINS30 @"pro.cloudteam.iseller.30coins"
#define COINS100 @"pro.cloudteam.iseller.100coins"
#define COINS300 @"pro.cloudteam.iseller.300coins"

#pragma mark - image's key

#define IMAGES_ATTRIBUTES @"images_attributes"
#define IM_ATTR_X @"x"
#define IM_ATTR_Y @"y"
#define IM_ATTR_SIDE @"side"
#define IM_ATTR_ATTACHMENT @"attachment"

#define BG_TEXTURE_IMAGE IS_RETINA ? @"bg_texture.png" : @"index-back.png"
#define BG_IMAGE @"preloader.png"

typedef enum
{
    updateDataWithReset = 0,
    updateDataLoadNext,
    updateDataLoadAfter
}
updateDataOption;

#define PRICE_OF_TOP_UP @"PriceOfTopUP" //ключ для NSUserDefaults где хранится цена поднятия в топ
#define DONT_SHOW_ALERT_WITH_PRICE_OF_TOP @"dontShowAlertWithPriceOfTop"//ключ для NSUserDefaults где хранится булл надо ли роказывать алерт предупреждающий о цене поднятия в топ
