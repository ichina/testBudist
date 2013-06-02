    //
//  LocationManager.m
//  iSeller
//
//  Created by Chingis Gomboev on 15.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "LocationManager.h"

#import <AudioToolbox/AudioToolbox.h>

@interface LocationManager()

@property (nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic, retain) CLLocation *currLocation;

@property (nonatomic, assign) BOOL isStopped;

@property (nonatomic, assign) NSTimer *locationTimer;

@property (nonatomic, copy) LocationBlockSuccess successBlock;
@property (nonatomic, copy) LocationBlockFailure failureBlock;

@end

@implementation LocationManager

@synthesize locationManager;

@synthesize successBlock, failureBlock;

@synthesize isStopped;

@synthesize currLocation;

@synthesize locationTimer;

#pragma mark Singleton methods

static LocationManager *instance_;

+ (LocationManager *)sharedManager {
    @synchronized(self) {
        if( instance_ == nil ) {
            instance_ = [[self alloc] init];
        }
    }
    
    return instance_;
}

- (id)init {
    self = [super init];
    instance_ = self;
    
    self.locationManager = [[CLLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];
    
    [self.locationManager setDesiredAccuracy:20.0];
    
    [self.locationManager setDistanceFilter:100.0];
        
    [self.locationManager startUpdatingLocation];
                    
    return self;
}

- (void)getLocationWithSuccess:(LocationBlockSuccess)_success failure:(LocationBlockFailure)_failure {
    
    [self.locationManager setDelegate:self];
    
    if(_success) {
        self.successBlock = _success;
    }
    
    if(_failure) {
        self.failureBlock = _failure;
    }
    
    if(self.successBlock && self.currLocation) {
        self.successBlock(self.currLocation);
        self.successBlock = nil;
    }else if([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        
        NSError *error = [NSError errorWithDomain:@"GeoDamin" code:-10002 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Geo location is restricted.", NSLocalizedDescriptionKey, nil]];
        
        self.failureBlock(error);
        
    }
        
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    [self checkLocation:[locations lastObject]];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    [self checkLocation:newLocation];
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    if(self.failureBlock) {
        self.failureBlock(error);
    }
    
}

- (void)checkLocation:(CLLocation *)location {
    
    // test the age of the location measurement to determine if the measurement is cached
    // in most cases you will not want to rely on cached measurements
    NSTimeInterval locationAge = -[location.timestamp timeIntervalSinceNow];
    
    if (locationAge > 5.0) return;
    
    // test that the horizontal accuracy does not indicate an invalid measurement
    if (location.horizontalAccuracy < 0) return;
    
    // test the measurement to see if it is more accurate than the previous measurement
    if (self.currLocation == nil || self.currLocation.horizontalAccuracy > location.horizontalAccuracy || self.currLocation.coordinate.latitude != location.coordinate.latitude) {
        // store the location as the "best effort"
        self.currLocation = location;
        
        if(self.successBlock && self.currLocation) {
            self.successBlock(self.currLocation);
            self.successBlock = nil;
        }
        
        // test the measurement to see if it meets the desired accuracy
        //
        // IMPORTANT!!! kCLLocationAccuracyBest should not be used for comparison with location coordinate or altitidue
        // accuracy because it is a negative value. Instead, compare against some predetermined "real" measure of
        // acceptable accuracy, or depend on the timeout to stop updating. This sample depends on the timeout.
        //
                
        if (location.horizontalAccuracy <= locationManager.desiredAccuracy) {
            // we have a measurement that meets our requirements, so we can stop updating the location
            //
            // IMPORTANT!!! Minimize power usage by stopping the location manager as soon as possible.
            //
                        
            [self.locationManager stopUpdatingLocation];
            
            // we can also cancel our previous performSelector:withObject:afterDelay: - it's no longer necessary
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation) object:nil];
            
        }
    }
    
}

- (void)updateLocation {
                    
    [self.locationManager startUpdatingLocation];
    
    [self.locationManager performSelector:@selector(stopUpdatingLocation) withObject:nil afterDelay:10.0];
    
}

- (NSString*)calculateDistanceWithLocation:(NSString*)_location
{
    NSArray* coordinates = [_location componentsSeparatedByString:@","];
    
    CLLocation *location1 = [[CLLocation alloc] initWithLatitude:((NSString*)coordinates[0]).doubleValue longitude:((NSString*)coordinates[1]).doubleValue];
    
    CLLocationDistance distance = [location1 distanceFromLocation:self.currLocation];
    
    location1 = nil;
    
    if(distance>=1000)
    {
        return [NSString stringWithFormat:@"%ld км",((long)distance)/1000];
    }
    else
    {
        return [NSString stringWithFormat:@"%ld м",(long)distance];
    }
    
    return [NSString stringWithFormat:@"%ld",(long)distance];
}

-(void)geocodingFromLocation:(NSString*)_location completion:(GeocodingCompletion)completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray* coordinates = [_location componentsSeparatedByString:@","];
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:((NSString*)coordinates[0]).doubleValue longitude:((NSString*)coordinates[1]).doubleValue];
        
        CLGeocoder *gc = [[CLGeocoder alloc] init];
        
        [gc reverseGeocodeLocation:location completionHandler:^(NSArray *placemark, NSError *error) {
                        
            CLPlacemark *pm = [placemark objectAtIndex:0];
            
            NSDictionary *curraddress;
            
            if(error) {
                
                curraddress = nil;
                
            }else{
                
                curraddress = pm.addressDictionary;
                
            }
            
        if(completion)
            completion([curraddress objectForKey:@"City"]?[curraddress objectForKey:@"City"]:[curraddress objectForKey:@"Name"]);
        }];
        
        location = nil;
    });
}

- (void)placemarkFromLocation:(CLLocationCoordinate2D)_coorditates completion:(PlacemarkCompletion)_completion {
    
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:_coorditates.latitude longitude:_coorditates.longitude];
        
        CLGeocoder *gc = [[CLGeocoder alloc] init];
        
        [gc reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                        
            if(_completion) {
                
                _completion(error ? nil : [[CLPlacemark alloc] initWithPlacemark:[placemarks objectAtIndex:0]], error);
                
            }
            
        }];
        
        location = nil;
    });

}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if(status == kCLAuthorizationStatusAuthorized) {
        
        [self.locationManager startUpdatingLocation];
        
        self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(updateLocation) userInfo:nil repeats:YES];
        
    }else{
        
        [self.locationManager stopUpdatingLocation];
        
        [self.locationTimer invalidate];
        
        if(self.failureBlock) {
            
            NSError *error = [NSError errorWithDomain:@"GeoDamin" code:-10002 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Geo location is restricted.", NSLocalizedDescriptionKey, nil]];
            
            self.failureBlock(error);
            
        }
        
    }
}

@end
