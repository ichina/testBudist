//
//  Advertisement.h
//  iSeller
//
//  Created by Paul Semionov on 27.12.12.
//  Copyright (c) 2012 CloudTeam. All rights reserved.
//

#import "Model.h"
#import "User.h"
@interface Advertisement : Model

typedef void(^AdvertisementsSuccessBlock)(NSArray* ads);
typedef void(^AdvertisementSuccessBlock)(Advertisement* ad);
typedef void(^AdvertisementsFailureBlock)(NSDictionary* dict, NSError *error);


@property (nonatomic,strong) NSNumber* identifier;
@property (nonatomic,strong) NSString* title;
@property (nonatomic,strong) NSString* image;
@property (nonatomic,strong) NSNumber* price;
@property (nonatomic,strong) NSString* smallImage;
@property (nonatomic,strong) NSString* status;
@property (nonatomic,strong) NSArray* images;
@property (nonatomic,strong) NSString* descriptionText;
@property (nonatomic,strong) NSString *location;
@property (nonatomic,strong) User* user;
@property (nonatomic,strong) NSNumber* userID;
@property (nonatomic,strong) NSNumber* viewCount;
@property (nonatomic,strong) NSString* paidAt;
@property (nonatomic,strong) NSNumber* isFavorite;

//network method's
+ (void)searchWithParams:(NSDictionary*) params success:(AdvertisementsSuccessBlock)_success failure:(AdvertisementsFailureBlock)_failure;
+ (void)searchMapWithViewPort:(NSString *)viewPort query:(NSString *)query priceFrom:(NSString *)priceFrom andPriceTo:(NSString *)priceTo success:(AdvertisementsSuccessBlock)_success failure:(AdvertisementsFailureBlock)_failure;
+ (void)getFavoritesWithLastIdentifier:(NSString *)identifier status:(NSString *)status success:(AdvertisementsSuccessBlock)_success failure:(AdvertisementsFailureBlock)_failure;
+ (void)getMyItemsWithLastIdentifier:(NSString *)identifier status:(NSString *)status success:(AdvertisementsSuccessBlock)_success failure:(AdvertisementsFailureBlock)_failure;
+ (void)addAdvertisementToFavouritesWithIdentifier:(NSString *)identifier success:(SuccessBlock)_success failure:(FailureBlock)_failure;
+ (void)deleteFavouriteWithIdentifier:(NSString *)identifier success:(SuccessBlock)_success failure:(FailureBlock)_failure;
+ (void)getAdvertisementWithIdentifier:(NSString *)identifier success:(AdvertisementSuccessBlock)_success failure:(AdvertisementsFailureBlock)_failure;
+ (void)createAdvertisementWithImages:(NSArray*)images params:(NSDictionary*)params progress:(ProgressBlock)progressBlock success:(AdvertisementSuccessBlock)_success failure:(AdvertisementsFailureBlock)_failure;
+ (void)editAdvertisementWithID:(NSString*)_identifier images:(NSArray*)images params:(NSDictionary*)params progress:(ProgressBlock)progressBlock success:(AdvertisementSuccessBlock)_success failure:(AdvertisementsFailureBlock)_failure;
+ (void) upToTopWithID:(NSString*)_identifier success:(AdvertisementSuccessBlock)_success failure:(AdvertisementsFailureBlock)_failure;
+ (void)deleteAdvertisementWithID:(NSString*)_identifier success:(AdvertisementSuccessBlock)_success failure:(AdvertisementsFailureBlock)_failure;
//data method's
-(NSString*) getSmallImage;

+(void)shareToVKWithURL:(NSURL* )url success:(AdvertisementSuccessBlock)_success failure:(AdvertisementsFailureBlock)_failure;

@end


