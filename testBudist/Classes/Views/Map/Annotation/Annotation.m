//
//  Annotation.m
//  seller
//
//  Created by Чина on 03.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Annotation.h"

#import "NSString+Extensions.h"

@implementation Annotation

@synthesize title;
@synthesize subtitle;
@synthesize tag;
@synthesize isDisplayLocation;
@synthesize ad;
@synthesize state;
@synthesize calloutView;

//Clustering

@synthesize coordinate = _coordinate;

- (id)init {
    
    self = [super init];
    
    return self;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    
    self = [super init];
    
    if(self) {
        
        self.coordinate = coordinate;
                
    }
    
    return self;
    
}

@end
