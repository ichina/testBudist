//
//  AdvertisementBuilder.m
//  iSeller
//
//  Created by Paul Semionov on 14.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "AdvertisementBuilder.h"

#import "NSString+Extensions.h"

@implementation AdvertisementBuilder

+ (NSArray *)_requiredFields {
    
    static NSArray * _requiredFields = nil;
    
    if(_requiredFields == nil) {
        
        _requiredFields = [[NSArray alloc] initWithObjects:nil];
        
    }
    
    return _requiredFields;
    
}

+ (NSMutableDictionary *)_requiredURLParameters {
    
    static NSMutableDictionary * _requiredURLParameters = nil;
    
    if(_requiredURLParameters == nil) {
        
        _requiredURLParameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"", @"id", nil];
        
    }
    
    return _requiredURLParameters;
    
}

+ (NSString *)_method {
    
    static NSString * _method = @"GET";
    
    return _method;
    
}

+ (NSString *)_path {
    
    NSString *_path = [NSString pathStringByReplacingPlaceholdersInString:AD_PATH withValues:[self _requiredURLParameters] andSuffix:@"Key"];
            
    return _path;
    
}

+ (NSMutableURLRequest *)buildRequestWithParameters:(NSDictionary *)parameters {
    
    NSMutableURLRequest *request = nil;
    
    NSMutableDictionary *tempParameters = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    
    for(NSString *parameter in [[self _requiredURLParameters] allKeys]) {
        
        if(![[tempParameters allKeys] containsObject:parameter] || [(NSString *)[tempParameters objectForKey:parameter] length] == 0) {
            
            return nil;
                        
        }else{
            
            [[self _requiredURLParameters] setValue:[tempParameters valueForKey:parameter] forKey:parameter];
            
            [tempParameters removeObjectForKey:parameter];
            
        }
        
    }
        
    if(tempParameters.allKeys.count == (parameters.allKeys.count - [self _requiredURLParameters].allKeys.count)) {
        
        parameters = nil;
        
    }else{
        
        parameters = tempParameters;

    }
        
    request = [super buildRequestWithParameters:parameters];
    
    return request;
    
}

@end
