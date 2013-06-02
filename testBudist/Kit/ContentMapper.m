//
//  ValueSplitter.m
//  iSeller
//
//  Created by Chingis Gomboev on 17.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "ContentMapper.h"

#import "NSString+Extensions.h"

@implementation ContentMapper

static NSMutableDictionary *_map = nil;

static NSMutableDictionary *_exceptionMap = nil;

+ (void)initialize {
    
    [super initialize];
    
    if (_exceptionMap == nil)
    {
        _exceptionMap = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"id", @"identifier",
                         @"description", @"descriptionText",
                         @"ll", @"location",
                         nil];
    }
    
    if (_map == nil) {
        
        _map = [NSMutableDictionary dictionary];
        
    }
    
}

+ (NSDictionary *)dictionaryWithProperties:(NSDictionary *)_properties andContent:(NSDictionary *)_content {
    
    for(NSString *key in [_content allKeys]) {
        
        [_map setValue:key forKey:[self generatePropertyFromField:key andContent:_content]];
        
    }
    
    NSMutableDictionary *_propertyMap = [NSMutableDictionary dictionary];
    
    for(NSString *property in _properties) {
                
        if([_content valueForKey:[_map valueForKey:property]]) {
            
            if(![[_properties valueForKey:property] hasPrefix:@"NS"]) {
                
                [_propertyMap setValue:[(Model *)[NSClassFromString([_properties valueForKey:property]) alloc] initWithContents:[_content valueForKey:[_map valueForKey:property]]] forKey:property];
                                
            }else{
                            
                [_propertyMap setValue:[_content valueForKey:[_map valueForKey:property]] forKey:property];
                                
            }
            
        }else{
                        
            //NSLog(@"Missing value for property: %@", property);
            
        }
        
    }
    
    return [NSDictionary dictionaryWithDictionary:_propertyMap];
    
}

+ (NSString *)generatePropertyFromField:(NSString *)field andContent:(NSDictionary *)_content {
    
    if([[_exceptionMap allValues] containsObject:field]) {
        
        return [[_exceptionMap allKeysForObject:field] lastObject];
        
    }
    
    BOOL isBool = NO;
    
    if([[_content valueForKey:field] isKindOfClass:[NSNumber class]] && ![[_exceptionMap allValues] containsObject:field]) {
    
        NSNumber * n = [_content valueForKey:field];

        if (strcmp([n objCType], @encode(BOOL)) == 0 && ![field hasPrefix:@"is"]) {
            
            isBool = YES;
            
            NSString *property = [field stringByReplacingOccurrencesOfString:@"?" withString:@""];
            
            if(property.length > 1) {
            
                property = [[[property substringToIndex:1] uppercaseString] stringByAppendingString:[property substringFromIndex:1]];
                
            }else{
                
                property = [property uppercaseString];
                
            }
            
            property = [NSString stringWithFormat:@"is%@", property];
            
            return property;
            
        } else if (strcmp([n objCType], @encode(int)) == 0) {
            
            isBool = NO;
            
        }
    
    }
    
    field = [field camelize];
    
    return field;
    
}

@end
