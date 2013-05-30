//
//  PostAdvertisementBuilder.m
//  iSeller
//
//  Created by Paul Semionov on 18.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "EditAdvertisementBuilder.h"

#import "NSString+Extensions.h"

@implementation EditAdvertisementBuilder

+ (NSArray *)_requiredFields {
    
    static NSArray * _requiredFields = nil;
    
    if(_requiredFields == nil) {
        
        _requiredFields = [[NSArray alloc] initWithObjects:@"price", @"title",@"description", nil];
        
    }
    
    return _requiredFields;
    
}

+ (NSMutableDictionary *)_requiredURLParameters {
    
    static NSMutableDictionary * _requiredURLParameters = nil;
    
    if(_requiredURLParameters == nil) {
        
        _requiredURLParameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"", @"id", @"", @"token", nil];
        
    }
    
    return _requiredURLParameters;
    
}

+ (NSString *)_method {
    
    static NSString * _method = @"PUT";
    
    return _method;
    
}

+ (BOOL)isMultipart {
    
    return YES;
    
}

+ (NSString *)_path {
    
    NSString *_path = [NSString pathStringByReplacingPlaceholdersInString:EDIT_AD withValues:[self _requiredURLParameters] andSuffix:@"Key"];
    
    return _path;
    
}

+ (NSMutableURLRequest *)buildRequestWithParameters:(NSDictionary *)parameters error:(NSError *__autoreleasing *)error{
    
    NSMutableURLRequest *request = nil;
    
    NSMutableDictionary *tempParameters = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    
    for(NSString *parameter in [[self _requiredURLParameters] allKeys]) {
        
        if(![[tempParameters allKeys] containsObject:parameter]) {
            
            break;
            
        }else{
            
            [[self _requiredURLParameters] setValue:[tempParameters valueForKey:parameter] forKey:parameter];
            
            [tempParameters removeObjectForKey:parameter];
            
        }
        
    }
    
    if(tempParameters.allKeys.count == 0) {
        
        parameters = nil;
        
    }else{
        
        parameters = tempParameters;
        
    }
    
    request = [super buildRequestWithParameters:parameters error:error];
    
    return request;
    
}

@end
