//
//  MapSearchBuilder.m
//  iSeller
//
//  Created by Paul Semionov on 24.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "MapSearchBuilder.h"

@implementation MapSearchBuilder

+ (NSArray *)_requiredFields {
    
    static NSArray * _requiredFields = nil;
    
    if(_requiredFields == nil) {
        
        _requiredFields = [[NSArray alloc] initWithObjects:@"box", nil];
        
    }
    
    return _requiredFields;
    
}

+ (NSString *)_method {
    
    static NSString * _method = @"GET";
    
    return _method;
    
}

+ (NSString *)_path {
    
    static NSString * _path = MAP_SEARCH_PATH;
    
    return _path;
    
}

@end
