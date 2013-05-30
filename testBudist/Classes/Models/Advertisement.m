//
//  Advertisement.m
//  iSeller
//
//  Created by Paul Semionov on 27.12.12.
//  Copyright (c) 2012 CloudTeam. All rights reserved.
//

#import "Advertisement.h"

#import "Profile.h"

#import "SearchBuilder.h"
#import "MapSearchBuilder.h"
#import "AdvertisementBuilder.h"
#import "FavouritesListBuilder.h"
#import "AddFavouriteBuilder.h"
#import "DeleteFavouriteBuilder.h"
#import "PersonalAdvertisementsBuilder.h"
#import "PostAdvertisementBuilder.h"
#import "EditAdvertisementBuilder.h"
#import "TopAdvertisementBuilder.h"
#import "LocationManager.h"
#import "DeleteAdvertisementBuilder.h"
#import "ErrorHandler.h"

@implementation Advertisement

@synthesize identifier;
@synthesize title;
@synthesize image;
@synthesize price;
@synthesize smallImage;
@synthesize status;
@synthesize images;
@synthesize descriptionText;
@synthesize location;
@synthesize user;
@synthesize userID;
@synthesize viewCount;
@synthesize paidAt;
@synthesize isFavorite;

+ (NSMutableArray*)convertArray:(NSArray*)_array
{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:[(NSArray*)_array count]];
    
    for(NSDictionary* dict in _array)
    {
        Advertisement* ad = [[Advertisement alloc] initWithContents:dict];
        [array addObject:ad];
    }
    return array;
}

+ (void)searchWithParams:(NSDictionary*)params success:(AdvertisementsSuccessBlock)_success failure:(AdvertisementsFailureBlock)_failure
{
    KIMutableURLRequest* request = [SearchBuilder buildRequestWithParameters:params];
    
    [self executeRequest:request progress:^(float progress) {
        
        NSLog(@"%.2f%%", progress * 100);
        
    } success:^(id object) {
        
        NSMutableArray* array = [self convertArray:object];
        
        if(_success)
            _success(array);
     
    } failure:^(id object, NSError *error) {
        if (_failure)
            _failure(object, error);
    }];
}

+ (void)searchMapWithViewPort:(NSString *)viewPort query:(NSString *)query priceFrom:(NSString *)priceFrom andPriceTo:(NSString *)priceTo success:(AdvertisementsSuccessBlock)_success failure:(AdvertisementsFailureBlock)_failure {
    
    NSDictionary *parameters = @{
        @"box"  : viewPort ? viewPort : [NSNull null],
        @"q"    : query ? query : [NSNull null],
        @"from" : priceFrom ? priceFrom : [NSNull null],
        @"to"   : priceTo ? priceTo : [NSNull null]
    };
    
    KIMutableURLRequest* request = [MapSearchBuilder buildRequestWithParameters:parameters];
    
    [self executeRequest:request progress:nil success:^(id object) {
        
        NSMutableArray* array = [self convertArray:object];
        
        if(_success)
            _success(array);
        
    } failure:^(id object, NSError *error) {
        if (_failure)
            _failure(object, error);
    }];

    
}

+ (void)addAdvertisementToFavouritesWithIdentifier:(NSString *)identifier success:(SuccessBlock)_success failure:(FailureBlock)_failure {
    
    NSDictionary *parameters = @{
        @"id" : identifier,
        @"token": [Profile sharedProfile].token
    };
    
    KIMutableURLRequest* request = [AddFavouriteBuilder buildRequestWithParameters:parameters];
    
    [self executeRequest:request progress:nil success:^(id object) {
                
        if(_success)
            _success(object);
        
    } failure:^(id object, NSError *error) {
        if(error.localizedDescription)
            
        if (_failure)
            _failure(object, error);
    }];
}

+ (void)deleteFavouriteWithIdentifier:(NSString *)identifier success:(SuccessBlock)_success failure:(FailureBlock)_failure {
    
    NSDictionary *parameters = @{
        @"id" : identifier,
        @"token": [Profile sharedProfile].token
    };
    
    KIMutableURLRequest* request = [DeleteFavouriteBuilder buildRequestWithParameters:parameters];
    
    [self executeRequest:request progress:nil success:^(id object) {
        
        if(_success)
            _success(object);
        
    } failure:^(id object, NSError *error) {
        if (_failure)
            _failure(object, error);
    }];
}

+ (void)getFavoritesWithLastIdentifier:(NSString *)identifier status:(NSString *)status success:(AdvertisementsSuccessBlock)_success failure:(AdvertisementsFailureBlock)_failure
{
    NSDictionary *params = @{
        @"before" : identifier,
        @"status" : status,
        @"token" : [[Profile sharedProfile] token]
    };
    
    KIMutableURLRequest* request = [FavouritesListBuilder buildRequestWithParameters:params];
    
    [self executeRequest:request progress:nil success:^(id object) {
        
        NSMutableArray* array = [self convertArray:object];
        for(Advertisement* ad in array)
            ad.isFavorite = [NSNumber numberWithBool:YES];

        if(_success)
            _success(array);
        
    } failure:^(id object, NSError *error) {
        if (_failure)
            _failure(object, error);
    }];
}

+ (void)getMyItemsWithLastIdentifier:(NSString *)identifier status:(NSString *)status success:(AdvertisementsSuccessBlock)_success failure:(AdvertisementsFailureBlock)_failure
{
    NSDictionary *params = @{
    @"before" : identifier,
    @"status" : status,
    @"token" : [[Profile sharedProfile] token]
    };
    
    KIMutableURLRequest* request = [PersonalAdvertisementsBuilder buildRequestWithParameters:params];
    
    [self executeRequest:request progress:nil success:^(id object) {
        
        NSMutableArray* array = [self convertArray:object];
        for(Advertisement* ad in array)
            ad.userID = [[Profile sharedProfile] identifier];
        
        if(_success)
            _success(array);
        
    } failure:^(id object, NSError *error) {
        if (_failure)
            _failure(object, error);
    }];
}

+ (void)getAdvertisementWithIdentifier:(NSString *)identifier success:(AdvertisementSuccessBlock)_success failure:(AdvertisementsFailureBlock)_failure {
    
    if(!identifier) {
        return;
    }
    
    NSDictionary *parameters = @{
        @"id" : identifier,
        @"token" : [Profile sharedProfile].token ? [Profile sharedProfile].token : @" "
    };
    
    KIMutableURLRequest* request = [AdvertisementBuilder buildRequestWithParameters:parameters];
    
    [self executeRequest:request progress:nil success:^(id object) {
        
        Advertisement *ad = [[Advertisement alloc] initWithContents:object];
        
        if(_success)
            _success(ad);
        
    } failure:^(id object, NSError *error) {
        if (_failure)
            _failure(object, error);
    }];
}

+ (void) createAdvertisementWithImages:(NSArray*)images params:(NSDictionary*)params progress:(ProgressBlock)progressBlock success:(AdvertisementSuccessBlock)_success failure:(AdvertisementsFailureBlock)_failure {
    
    __block NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:params];
    
    [parameters setObject:images forKey:IMAGES_ATTRIBUTES];
    
    if(parameters[@"ll"])
        [self createWithParams:parameters progress:progressBlock success:_success failure:_failure];
    else
    {
        [[LocationManager sharedManager] getLocationWithSuccess:^(CLLocation *location) {
            
            NSString* locationStr = [NSString stringWithFormat:@"%f,%f",location.coordinate.latitude,location.coordinate.longitude,nil];
            [parameters setObject:locationStr forKey:@"ll"];
            [self createWithParams:parameters progress:progressBlock success:_success failure:_failure];
            
        } failure:^(NSError *error) {
            
            if (_failure)
                _failure(nil, error);
        }];
    }
}

+ (void) createWithParams:(NSDictionary*)parameters progress:(ProgressBlock)progressBlock success:(AdvertisementSuccessBlock)_success failure:(AdvertisementsFailureBlock)_failure
{
    
    parameters = [@{@"ad" : parameters, @"token" : [Profile sharedProfile].token} mutableCopy];
    NSError *_error = nil;
    KIMutableURLRequest* request = [PostAdvertisementBuilder buildRequestWithParameters:parameters error:&_error];
    if(_error)
    {
        [[ErrorHandler sharedHandler] handleError:_error];
        if (_failure) {
            _failure(nil,_error);
        }
    }
    else
    {
        [self executeRequest:request progress:progressBlock success:^(id object) {
            
            Advertisement *ad = [[Advertisement alloc] initWithContents:object];
            
            if(_success)
                _success(ad);
            
        } failure:^(id object, NSError *error) {
            [[ErrorHandler sharedHandler] handleError:error];
            if (_failure)
                _failure(object, error);
        }];
    }
}

+ (void)editAdvertisementWithID:(NSString*)_identifier images:(NSArray*)images params:(NSDictionary*)params progress:(ProgressBlock)progressBlock success:(AdvertisementSuccessBlock)_success failure:(AdvertisementsFailureBlock)_failure {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:params];
    
    [parameters setObject:images forKey:IMAGES_ATTRIBUTES];
    
    parameters = [@{@"id": _identifier , @"ad" : parameters, @"token" : [Profile sharedProfile].token} mutableCopy];
    
    NSError *_error = nil;
    KIMutableURLRequest* request = [EditAdvertisementBuilder buildRequestWithParameters:parameters error:&_error];
    if(_error)
    {
        [[ErrorHandler sharedHandler] handleError:_error];
        if (_failure) {
            _failure(nil,_error);
        }
    }
    else
    {
        [self executeRequest:request progress:progressBlock success:^(id object) {
            
            Advertisement *ad = [[Advertisement alloc] initWithContents:object];
            if(_success)
                _success(ad);
            
        } failure:^(id object, NSError *error) {
            if (_failure)
                _failure(object, error);
        }];
    }
}

+ (void) upToTopWithID:(NSString*)_identifier success:(AdvertisementSuccessBlock)_success failure:(AdvertisementsFailureBlock)_failure
{
    NSDictionary *parameters = @{
    @"id" : _identifier,
    @"token": [Profile sharedProfile].token
    };
    
    KIMutableURLRequest* request = [TopAdvertisementBuilder buildRequestWithParameters:parameters];
    
    [self executeRequest:request progress:nil success:^(id object) {
        
        if(_success)
            _success(object);
        
        [[Profile sharedProfile] getBalanceWithSuccess:nil failure:^(NSError *error) {
            
            NSLog(@"Error, while retrieving balance: %@", [error localizedDescription]);
            
        }];
        
    } failure:^(id object, NSError *error) {
        if (_failure)
            _failure(object, error);
    }];
}

+ (void)deleteAdvertisementWithID:(NSString*)_identifier success:(AdvertisementSuccessBlock)_success failure:(AdvertisementsFailureBlock)_failure {
    
    NSDictionary *parameters = @{
    @"id" : _identifier,
    @"token": [Profile sharedProfile].token
    };
    
    KIMutableURLRequest* request = [DeleteAdvertisementBuilder buildRequestWithParameters:parameters];
    
    [self executeRequest:request progress:nil success:^(id object) {
        if(_success)
            _success(object);
        
    } failure:^(id object, NSError *error) {
        if (_failure)
            _failure(object, error);
    }];
}

-(NSString*) getSmallImage
{
    return [self.image stringByReplacingOccurrencesOfString:@"/medium/" withString:@"/small/"];
}

+(void)shareToVKWithURL:(NSURL* )url success:(AdvertisementSuccessBlock)_success failure:(AdvertisementsFailureBlock)_failure
{
    KIMutableURLRequest* request = [[KIMutableURLRequest alloc] initWithURL:url];
    
    [self executeRequest:request progress:nil success:^(id object) {
        if(_success)
            _success(object);
        
    } failure:^(id object, NSError *error) {
        if (_failure)
            _failure(object, error);
    }];
}

@end
