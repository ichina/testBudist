//
//  MessageStateBuilder.m
//  iSeller
//
//  Created by Чингис on 08.04.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "MessageStateBuilder.h"
#import "NSString+Extensions.h"

@implementation MessageStateBuilder

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
        
        _requiredURLParameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"", @"token", nil];
        
    }
    
    return _requiredURLParameters;
    
}

+ (NSString *)_method {
    
    static NSString * _method = @"GET";
    
    return _method;
    
}

+ (NSString *)_path {
    
    NSString * _path = [NSString pathStringByReplacingPlaceholdersInString:MESSAGES_STATE_PATH withValues:[self _requiredURLParameters] andSuffix:@"Key"];
    
    return _path;
    
}

+ (NSMutableURLRequest *)buildRequestWithParameters:(NSDictionary *)parameters {
    
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
    
    parameters = tempParameters;
    
    request = [super buildRequestWithParameters:parameters];
    
    return request;
    
}
@end