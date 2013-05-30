//
//  MapViewController.h
//  iSeller
//
//  Created by Paul Semionov on 24.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "BaseController.h"

#import <MapKit/MapKit.h>

#import "LocationManager.h"

#import "AnnotationView.h"

@interface MapController : BaseController <MKMapViewDelegate, UISearchBarDelegate, AnnotationViewDelegate>

@property (nonatomic, retain) NSString *priceFrom;

@property (nonatomic, retain) NSString *priceTo;

@property (nonatomic, retain) NSString *range;

@property (nonatomic, retain) NSString *query;

@property (nonatomic, assign) BOOL isSearching;

@end
