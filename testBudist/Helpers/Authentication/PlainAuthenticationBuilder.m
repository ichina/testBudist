//
//  PlainAuthenticationBuilder.m
//  iSeller
//
//  Created by Paul Semionov on 11.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "PlainAuthenticationBuilder.h"

@implementation PlainAuthenticationBuilder

+ (NSArray *)_requiredFields {
    
    static NSArray * _requiredFields = nil;
    
    if(_requiredFields == nil) {
        
        _requiredFields = [[NSArray alloc] initWithObjects:@"email", @"password", nil];
        
    }
    
    return _requiredFields;
    
}

+ (NSString *)_method {
    
    static NSString * _method = @"POST";
    
    return _method;
}

+ (NSString *)_path {
    
    static NSString * _path = AUTH_PATH;
    
    return _path;
    
}


@end
