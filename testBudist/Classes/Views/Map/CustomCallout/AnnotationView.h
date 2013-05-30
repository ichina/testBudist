//
//  AnnotationView.h
//  iSeller
//
//  Created by Paul Semionov on 25.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "CalloutView.h"

#import "Annotation.h"

#define kNotificationHideCallouts @"HideCallouts"

@protocol AnnotationViewDelegate;

@interface AnnotationView : MKAnnotationView <UIGestureRecognizerDelegate, MKMapViewDelegate> {
    
    id <AnnotationViewDelegate> delegate;
    
}

@property (nonatomic, retain) id <AnnotationViewDelegate> delegate;

@property (nonatomic, assign) MKMapView *mapView;

@property (nonatomic, weak) CalloutView *calloutView;

@property (nonatomic, assign) BOOL isCallout;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
- (void)animateCalloutAppearance;
- (void)hideCallout:(NSNotification *)notification;

@end

@protocol AnnotationViewDelegate <NSObject>

@optional

- (void)annotationView:(AnnotationView *)annotationView willShowCallout:(CalloutView *)calloutView;
- (void)annotationView:(AnnotationView *)annotationView didShowCallout:(CalloutView *)calloutView;

- (void)calloutView:(CalloutView *)calloutView touchedWithAnnotation:(Annotation *)annotation inPoint:(CGPoint)touchPoint;

@end
