//
//  NSDictionary+Extensions.m
//  iSeller
//
//  Created by Chingis Gomboev on 23.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "NSDictionary+Extensions.h"

#import "NSString+Extensions.h"

@interface NSDictionary()

@end

@implementation NSDictionary (Extensions)

static NSMutableDictionary *_resultDictionary = nil;

static NSString *_keyPath = nil;

static NSString *_requiredKey = nil;

+ (void)initialize {
    
    [super initialize];
    
    if (_resultDictionary == nil)
    {
        _resultDictionary = [NSMutableDictionary dictionary];
    }
    
    if (_keyPath == nil)
    {
        _keyPath = @"";
    }
    
    if (_requiredKey == nil)
    {
        _requiredKey = @"";
    }
}

+ (NSDictionary *)plainDictionaryWithDictionary:(NSDictionary *)dictionary {
    
    _requiredKey = nil;
    
    _resultDictionary = [NSMutableDictionary dictionary];
    
    [self scanDictionary:dictionary key:@""];
    
    return [NSDictionary dictionaryWithDictionary:_resultDictionary];
    
}

- (NSString *)keyPathIncludingLastKey:(NSString *)key {
    
    _requiredKey = key;
    
    [NSDictionary scanDictionary:self key:@""];
    
    return _keyPath;
    
}

- (NSDictionary *)dictionaryForKey:(NSString *)key {
    
    _requiredKey = key;
    
    [NSDictionary scanDictionary:self key:@""];
    
    NSString *keysString = [[_resultDictionary allKeys] lastObject];
    
    NSString *rootKey = @"";
    
    NSRange end = [keysString rangeOfString:@"["];
    
    if (end.location != NSNotFound) {
        rootKey = [keysString substringWithRange:NSMakeRange(0, end.location)];
        [keysString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@[", rootKey] withString:@""];
    }
    
    NSMutableArray *keys = [NSMutableArray arrayWithObject:rootKey];
    
    [keys addObjectsFromArray:[keysString stringsBetweenString:@"[" andString:@"]"]];
    
    id value = [_resultDictionary valueForKey:keysString];
    
    NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithObject:value forKey:_requiredKey];
    
    for(int i = keys.count - 2; i > -1; i--) {
        
        NSLog(@"%@", [keys objectAtIndex:i]);
        
        NSDictionary *tempDictionary = [NSDictionary dictionaryWithDictionary:returnDictionary];
        
        [returnDictionary removeAllObjects];
        
        [returnDictionary setValue:tempDictionary forKey:[keys objectAtIndex:i]];
        
    }
    
    NSLog(@"%@", returnDictionary);
    
    return [NSDictionary dictionaryWithDictionary:returnDictionary];
    
}

+ (void)scanDictionary:(NSDictionary *)_dictionary key:(NSString *)_key
{
    NSString *tempKey = _key;
    
    for(NSString* key in [_dictionary allKeys])
    {
        tempKey = (_key.length) ? [NSString stringWithFormat:@"%@[%@]",_key, key]: key;
        
        if([_dictionary[key] isKindOfClass:[NSDictionary class]] || [_dictionary[key] isKindOfClass:[NSMutableDictionary class]])
        {
            
            if([key isEqualToString:_requiredKey]) {
                
                [_resultDictionary removeAllObjects];
                [_resultDictionary setObject:_dictionary[key] forKey:tempKey];
                
                break;
                
            }
            
            [self scanDictionary:_dictionary[key] key:tempKey];
            
        }
        else if([_dictionary[key] isKindOfClass:[NSArray class]] || [_dictionary[key] isKindOfClass:[NSMutableArray class]])
        {
            
            if([key isEqualToString:_requiredKey]) {
                
                [_resultDictionary removeAllObjects];
                [_resultDictionary setObject:_dictionary[key] forKey:tempKey];
                                
                break;
                
            }
            
            [self scanArray:_dictionary[key] key:tempKey];
            
        }
        else
        {
            
            [_resultDictionary setObject:_dictionary[key] forKey:tempKey];
            
        }
    }
    
}

+ (void)scanArray:(NSArray *)_array key:(NSString *)_key
{
    NSLog(@"Entered array scan");
    
    NSString* tempKey = _key;
    
    for(int i = 0 ; i < _array.count ; i++)
    {
        tempKey = (_key.length) ? [NSString stringWithFormat:@"%@[%d]", _key, i]: [NSString stringWithFormat:@"%d", i];
        
        if([_array[i] isKindOfClass:[NSDictionary class]] || [_array[i] isKindOfClass:[NSMutableDictionary class]])
        {
            
            [self scanDictionary:_array[i] key:tempKey];
            
        }
        else if([_array[i] isKindOfClass:[NSArray class]] || [_array[i] isKindOfClass:[NSMutableArray class]])
        {
            
            [self scanArray:_array[i] key:tempKey];
            
        }
        else
        {
            
            [_resultDictionary setObject:_array[i] forKey:tempKey];
            
        }
    }
}

@end
