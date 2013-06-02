//
//  NSString+Extensions.h
//  iSeller
//
//  Created by Chingis Gomboev on 14.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extensions)

+ (NSString *)stringWithFormat:(NSString *)format andArguments:(NSArray *)arguments;
+ (NSString *)pathStringByReplacingPlaceholdersInString:(NSString *)string withValues:(NSDictionary *)values andSuffix:(NSString *)suffix;

- (NSString*)stringBetweenString:(NSString*)start andString:(NSString*)end;
- (NSArray *)stringsBetweenString:(NSString *)start andString:(NSString *)end;


- (BOOL)containsString:(NSString *)string;

-(NSString*) camelize;
-(BOOL) isValidEmail;

@end
