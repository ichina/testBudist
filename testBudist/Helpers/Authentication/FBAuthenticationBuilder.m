//
//  FBAuthenticationBuilder.m
//  iSeller
//
//  Created by Paul Semionov on 14.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "FBAuthenticationBuilder.h"

@implementation FBAuthenticationBuilder

+ (NSArray *)_requiredFields {
    
    static NSArray * _requiredFields = nil;
    
    if(_requiredFields == nil) {
        
        _requiredFields = [[NSArray alloc] initWithObjects:@"code",@"provider", nil];
        
    }
    
    return _requiredFields;
    
}

+ (NSString *)_method {
    
    static NSString * _method = @"POST";
    
    return _method;
    
}

+ (NSString *)_path {
    
    static NSString * _path = FB_PATH;
    
    return _path;
    
}

@end