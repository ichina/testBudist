//
//  GeoPickerController.h
//  iSeller
//
//  Created by Paul Semionov on 04.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "BaseController.h"

#import "Annotation.h"

#import "AnnotationView.h"

@protocol GeoPickerControllerDelegate;

@interface GeoPickerController : BaseController <MKMapViewDelegate, AnnotationViewDelegate> {
    
    id <GeoPickerControllerDelegate> delegate;
    
}

@property (nonatomic, retain) id <GeoPickerControllerDelegate> delegate;

@end

@protocol GeoPickerControllerDelegate <NSObject>

@optional

- (void)geoPickerWantsToDismissWithCancel;
- (void)geoPickerWantsToDismissWithPlacemark:(CLPlacemark *)placemark;

@end