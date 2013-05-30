//
//  SearchBuilder.m
//  iSeller
//
//  Created by Paul Semionov on 10.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "SearchBuilder.h"

@implementation SearchBuilder

+ (NSArray *)_requiredFields {
    
    static NSArray * _requiredFields = nil;
    
    if(_requiredFields == nil) {
    
        _requiredFields = [[NSArray alloc] initWithObjects:@"ll", nil];
        
    }
    
    return _requiredFields;
    
}

+ (NSString *)_method {
    
    static NSString * _method = @"GET";
    
    return _method;
    
}

+ (NSString *)_path {
    
    static NSString * _path = SEARCH_PATH;
    
    return _path;
    
}

@end
