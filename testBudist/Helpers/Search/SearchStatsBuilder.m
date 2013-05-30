//
//  SearchStatsBuilder.m
//  iSeller
//
//  Created by Чина on 04.02.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "SearchStatsBuilder.h"

@implementation SearchStatsBuilder

+ (NSArray *)_requiredFields {
    
    static NSArray * _requiredFields = nil;
    
    if(_requiredFields == nil) {
        
        _requiredFields = [[NSArray alloc] initWithObjects:nil];
        
    }
    
    return _requiredFields;
    
}

+ (NSString *)_method {
    
    static NSString * _method = @"GET";
    
    return _method;
    
}

+ (NSString *)_path {
    
    static NSString * _path = nil;
    
    return _path;
    
}

@end
