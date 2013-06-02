//
//  NSString+Extensions.m
//  iSeller
//
//  Created by Chingis Gomboev on 14.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "NSString+Extensions.h"

@implementation NSString (Extensions)

+ (NSString *)stringWithFormat:(NSString *)format andArguments:(NSArray *)arguments {
    
    NSRange range = NSMakeRange(0, [arguments count]);
    
    NSMutableData* data = [NSMutableData dataWithLength: sizeof(id) * [arguments count]];
    
    [arguments getObjects:(__unsafe_unretained id *)data.mutableBytes range:range];
    
    return [[NSString alloc] initWithFormat:format  arguments:data.mutableBytes];
}

+ (NSString *)pathStringByReplacingPlaceholdersInString:(NSString *)string withValues:(NSDictionary *)values andSuffix:(NSString *)suffix {
    
    for (NSString *key in [values allKeys]) {
        
        if([string containsString:[key stringByAppendingString:suffix]]) {
            
            string = [string stringByReplacingOccurrencesOfString:[key stringByAppendingString:suffix] withString:[values valueForKey:key]];
            
        }
        
    }
    
    return string;
    
}



- (BOOL)containsString:(NSString *)string {
    if ([self rangeOfString:string options:NSCaseInsensitiveSearch].location == NSNotFound) {
        return NO;
    } else {
        return YES;
    }
}



- (NSString*)stringBetweenString:(NSString*)start andString:(NSString*)end
{
    NSScanner* scanner = [NSScanner scannerWithString:self];
    [scanner setCharactersToBeSkipped:nil];
    [scanner scanUpToString:start intoString:NULL];
    if ([scanner scanString:start intoString:NULL]) {
        NSString* result = nil;
        if ([scanner scanUpToString:end intoString:&result]) {
            return result;
        }
    }
    return nil;
}

- (NSArray *)stringsBetweenString:(NSString *)start andString:(NSString *)end {
    
    NSString *string = self;
    
    NSMutableArray *array = [NSMutableArray array];
    
    BOOL stop = NO;
    
    do {
        
        NSString *result = [string stringBetweenString:@"[" andString:@"]"];
        
        if(result == nil) {
            stop = YES;
        }else{
            
            [array addObject:result];
            
            string = [string stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@%@%@", start, result, end] withString:@""];
            
        }
        
    } while (!stop);
    
    return [NSArray arrayWithArray:array];
    
}

-(NSString*)camelize
{
    NSMutableArray* camelArray= [NSMutableArray arrayWithArray:[self componentsSeparatedByString:@"_"]];
    for(int i = 1 ; i < camelArray.count ; i++)
    {
        NSString* word = camelArray[i];
        if(word.length)
            word = [[[word substringToIndex:1] uppercaseString] stringByAppendingString:[word substringFromIndex:1]];
        camelArray[i] = word;
    }
    return [camelArray componentsJoinedByString:@""];
}

-(BOOL) isValidEmail
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

-(BOOL)containsInArrayOfStrings:(NSArray*) array
{
    for (NSNumber* number in array) {
        
        if(number.intValue==self.intValue)
            return YES;
    }
    return NO;
}

@end
