//
//  PostAdvertisementBuilder.m
//  iSeller
//
//  Created by Paul Semionov on 18.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "PostAdvertisementBuilder.h"

#import "NSString+Extensions.h"

@implementation PostAdvertisementBuilder

+ (NSArray *)_requiredFields {
    
    static NSArray * _requiredFields = nil;
    
    if(_requiredFields == nil) {
        
        _requiredFields = [[NSArray alloc] initWithObjects:@"address", @"price", @"title", @"ll", @"description",IMAGES_ATTRIBUTES, nil];
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
    
    static NSString * _method = @"POST";
    
    return _method;
    
}

+ (NSString *)_path {
    
    NSString *_path = [NSString pathStringByReplacingPlaceholdersInString:POST_AD withValues:[self _requiredURLParameters] andSuffix:@"Key"];
    
    return _path;
    
}

+ (BOOL)isMultipart {
    
    return YES;
    
}

+ (NSMutableURLRequest *)buildRequestWithParameters:(NSDictionary *)parameters
{
    return [self buildRequestWithParameters:parameters error:nil];
}


+ (NSMutableURLRequest *)buildRequestWithParameters:(NSDictionary *)parameters error:(NSError**) error {
    
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
