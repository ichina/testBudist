//
//  NSDictionary+Extensions.h
//  iSeller
//
//  Created by Chingis Gomboev on 23.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Extensions)

+ (NSDictionary *)plainDictionaryWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)dictionaryForKey:(NSString *)key;

@end
