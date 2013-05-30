//
//  SignUpBuilder.m
//  iSeller
//
//  Created by Чина on 28.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "SignUpBuilder.h"

@implementation SignUpBuilder

+ (NSArray *)_requiredFields {
    
    static NSArray * _requiredFields = nil;
    
    if(_requiredFields == nil) {
        
        _requiredFields = [[NSArray alloc] initWithObjects:@"user[email]", @"user[name]",@"user[password]",nil];
        
    }
    
    return _requiredFields;
    
}

+ (NSString *)_method {
    
    static NSString * _method = @"POST";
    
    return _method;
    
}

+ (NSString *)_path {
    
    static NSString * _path = SIGN_UP_PATH;
    
    return _path;
    
}



@end
