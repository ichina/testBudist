//
//  RestorePasswordBuilder.m
//  iSeller
//
//  Created by Чина on 18.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "RestorePasswordBuilder.h"

@implementation RestorePasswordBuilder

+ (NSArray *)_requiredFields {
    
    static NSArray * _requiredFields = nil;
    
    if(_requiredFields == nil) {
        
        _requiredFields = [[NSArray alloc] initWithObjects:nil];
        
    }
    
    return _requiredFields;
    
}

+ (NSString *)_method {
    
    static NSString * _method = @"POST";
    
    return _method;
    
}

+ (NSString *)_path {
    
    static NSString * _path = RESTORE_PASS_PATH;
    
    return _path;
    
}

@end
