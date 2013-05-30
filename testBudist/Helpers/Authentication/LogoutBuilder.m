//
//  LogoutBuilder.m
//  iSeller
//
//  Created by Paul Semionov on 14.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "LogoutBuilder.h"

@implementation LogoutBuilder

+ (NSArray *)_requiredFields {
    
    static NSArray * _requiredFields = nil;
    
    if(_requiredFields == nil) {
        
        _requiredFields = [[NSArray alloc] initWithObjects:nil];
        
    }
    
    return _requiredFields;
    
}

+ (NSString *)_method {
    
    static NSString * _method = nil;
    
    return _method;
    
}

+ (NSString *)_path {
    
    static NSString * _path = nil;
    
    return _path;
    
}

@end
