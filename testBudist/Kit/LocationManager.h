//
//  LocationManager.h
//  iSeller
//
//  Created by Paul Semionov on 15.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject <CLLocationManagerDelegate>

typedef void (^LocationBlockSuccess)(CLLocation *location);
typedef void (^LocationBlockFailure)(NSError* error);
typedef void (^GeocodingCompletion)(NSString* address);
typedef void (^PlacemarkCompletion)(CLPlacemark *placemark, NSError *error);

+ (LocationManager *)sharedManager;

- (void)getLocationWithSuccess:(LocationBlockSuccess)_success failure:(LocationBlockFailure)_failure;

- (NSString *)calculateDistanceWithLocation:(NSString*)_location;

-(void)geocodingFromLocation:(NSString*)_location completion:(GeocodingCompletion)completion;
- (void)placemarkFromLocation:(CLLocationCoordinate2D)_coorditates completion:(PlacemarkCompletion)_completion;

@end
