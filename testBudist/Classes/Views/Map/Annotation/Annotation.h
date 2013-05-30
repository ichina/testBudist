//
//  Annotation.h
//  seller
//
//  Created by Чина on 03.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "CalloutView.h"
#import "Advertisement.h"

typedef enum{
    kAnnotationStateNormal = 0,
    kAnnotationStateDropped
}kAnnotationState;

@interface Annotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) Advertisement * ad;
@property (nonatomic, strong) NSString* tag;
@property (nonatomic, assign) BOOL isDisplayLocation;
@property (nonatomic, assign) NSInteger state;
@property (nonatomic, retain) CalloutView *calloutView;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
