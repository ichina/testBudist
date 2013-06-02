//
//  Builder.m
//  iSeller
//
//  Created by Chingis Gomboev on 10.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "Builder.h"

#import <JSONKit.h>

#import "NSDictionary+Extensions.h"

#import "ErrorHandler.h"

@interface Builder()

//+ (KIMutableURLRequest *)buildRequestWithParameters:(NSDictionary *)parameters requiredFields:(NSArray *)_requiredFields method:(NSString *)_method andPath:(NSString *)_path;
+ (KIMutableURLRequest *)buildRequestWithParameters:(NSDictionary *)parameters requiredFields:(NSArray *)_requiredFields method:(NSString *)_method andPath:(NSString *)_path error:(NSError**)error;

@end

@implementation Builder

static NSArray *_garbageValues = nil;

+ (void)initialize {
    
    [super initialize];
    
    if (_garbageValues == nil)
    {
        _garbageValues = [[NSArray alloc] initWithObjects:@"(null)", @"<null>", @"null", @"%28null%29", [NSNull null], nil];
    }
}

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

+ (BOOL)isMultipart {
        
    return NO;
    
}

+ (KIMutableURLRequest *)buildRequestWithParameters:(NSDictionary *)parameters {
    
    return [self buildRequestWithParameters:parameters requiredFields:[self _requiredFields] method:[self _method] andPath:[self _path] error:nil];
}

+ (KIMutableURLRequest *)buildRequestWithParameters:(NSDictionary *)parameters error:(NSError**) error {
    
    return [self buildRequestWithParameters:parameters requiredFields:[self _requiredFields] method:[self _method] andPath:[self _path] error:error];
}

//+ (KIMutableURLRequest *)buildRequestWithParameters:(NSDictionary *)parameters requiredFields:(NSArray *)_requiredFields method:(NSString *)_method andPath:(NSString *)_path
+ (KIMutableURLRequest *)buildRequestWithParameters:(NSDictionary *)parameters requiredFields:(NSArray *)_requiredFields method:(NSString *)_method andPath:(NSString *)_path error:(NSError**) error
{
    
    KIMutableURLRequest *request;
//    NSString *rootKey = @"";
//    if(parameters.allKeys.count == 1 && [[parameters valueForKey:[[parameters allKeys] lastObject]] isKindOfClass:[NSDictionary class]]) {
//        rootKey = [[parameters allKeys] lastObject];       
//        parameters = [self validate:parameters[rootKey] andRequiredFields:_requiredFields error:error];
//        if(!parameters) 
//            return nil;
//        else if (parameters.allKeys.count==0)
//            parameters = nil;
//        else
//            parameters = @{rootKey : parameters};
//    }
//    else
//    {
//        parameters = [self validate:parameters andRequiredFields:_requiredFields error:error];
//        if(!parameters)
//            return nil;
//        if(parameters.allKeys.count==0)
//            parameters = nil;
//    }
    
    parameters = [self validate:parameters andRequiredFields:_requiredFields error:error];
    if(!parameters)
        return nil;
    if(parameters.allKeys.count==0)
        parameters = nil;
    
    if(![self isMultipart])
        request = [[HTTPClient sharedClient] requestWithMethod:_method path:_path parameters:parameters];
    else
    {
        request = [[HTTPClient sharedClient] multipartFormRequestWithMethod:_method path:_path parameters:nil constructingBodyWithBlock:^(id<MultipartFormData> formData) {
            
            NSDictionary *plainDictionary = [NSDictionary plainDictionaryWithDictionary:parameters];
            
            /*
            for (NSString* key in plainDictionary.allKeys) {
                
                if([plainDictionary[key] isKindOfClass:[UIImage class]]) {
                    
                    NSData *imageData = UIImageJPEGRepresentation(plainDictionary[key], 0.7f);
                    [formData appendPartWithFileData:imageData name:key fileName:@"image.jpg" mimeType:@"image/jpeg"];
                    
                }else{
                    
                    [formData appendPartWithFormData:[plainDictionary[key] dataUsingEncoding:NSUTF8StringEncoding] name:key];
                    
                }
            }
            */
            //надо все картинки посылать в последнюю очередь, иначе сервер игнорирует параметры
            for (NSString* key in plainDictionary.allKeys) {
                
                if(![plainDictionary[key] isKindOfClass:[UIImage class]]) {
                    
                    [formData appendPartWithFormData:[plainDictionary[key] dataUsingEncoding:NSUTF8StringEncoding] name:key];
                }
            }
            for (NSString* key in plainDictionary.allKeys) {
                if([plainDictionary[key] isKindOfClass:[UIImage class]]) {
                    NSData *imageData = UIImageJPEGRepresentation(plainDictionary[key], 0.7f);
                    [formData appendPartWithFileData:imageData name:key fileName:@"image.jpg" mimeType:@"image/jpeg"];
                }
            }
        }];
    }
        
    return request;
}

+ (NSDictionary *)validate:(NSDictionary *)_parameters andRequiredFields:(NSArray *)_requiredFields
{
    return [self validate:_parameters andRequiredFields:_requiredFields];
}

+ (NSDictionary *)validate:(NSDictionary *)_parameters andRequiredFields:(NSArray *)_requiredFields error:(NSError**) error {
    
    NSMutableArray* unprocessedFields = [NSMutableArray new];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:_parameters];
        
    for(id garbageValue in _garbageValues) {
        
        [parameters removeObjectsForKeys:[parameters allKeysForObject:garbageValue]];
                
    }
            
    _parameters = [NSDictionary dictionaryWithDictionary:parameters];
            
    for(int i = 0; i < _requiredFields.count; i++) {
        
        if(![[_parameters allKeys] containsObject:[_requiredFields objectAtIndex:i]]) {
            
            NSLog(@"Required field is missing: %@", [_requiredFields objectAtIndex:i]);
            
            [unprocessedFields addObject:NSLocalizedString(_requiredFields[i],nil)];
            //_parameters = nil;
            //break;
            continue;
        }
        else
        {
            
            //нужно проверить кроме наличия в ключах еще и на содержимое
            if(![self validateValueContentOfObject:_parameters[_requiredFields[i]]])
            {
                //_parameters = nil;
                //break;
                [unprocessedFields addObject:NSLocalizedString(_requiredFields[i],nil) ];
                continue;
            }
        }
    }
    
    if(unprocessedFields && unprocessedFields.count>0)
    {
        NSString* errorBody = @"";
        
        errorBody = [unprocessedFields componentsJoinedByString:@", "];
        errorBody = [NSString stringWithFormat:@"%@",errorBody];
        
        *error = [NSError errorWithDomain:NSLocalizedString(@"Cannot be processed", nil) code:-10001 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorBody, NSLocalizedDescriptionKey, nil]];
        _parameters = nil;
    }
    else
    {
        NSLog(@"Required fields check : OK");
    }
    
    return _parameters;
}

+ (BOOL) validateValueContentOfObject:(NSObject*) object
{
    if(!object)
        return NO;
    
    if([object isKindOfClass:[NSString class]])
        return ((NSString*)object).length;
    
    if([object isKindOfClass:[NSNumber class]])
        return ((NSNumber*)object).stringValue.length;
    
    else if ([object isKindOfClass:[NSArray class]])
    {
        if(!((NSArray*)object).count)
            return NO;
        else
        {
            for(NSObject* subject in (NSArray*)object)
                if(![self validateValueContentOfObject:subject])
                    return NO;
            return YES;
        }
    }
    else if ([object isKindOfClass:[NSDictionary class]])
    {
        if(!((NSDictionary*)object).allKeys.count)
            return NO;
        else
        {
            for (NSString* key in ((NSDictionary*)object).allKeys )
                if(![self validateValueContentOfObject:[((NSDictionary*)object) objectForKey:key]])
                    return NO;
            return YES;
        }
    }
    return YES;
}

       
@end
