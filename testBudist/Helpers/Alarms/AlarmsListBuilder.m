//
//  GetAlarmsList.m
//  testBudist
//
//  Created by Чингис on 02.06.13.
//  Copyright (c) 2013 Чингис. All rights reserved.
//

#import "AlarmsListBuilder.h"

@implementation AlarmsListBuilder

+ (NSArray *)_requiredFields {
    
    static NSArray * _requiredFields = nil;
    
    if(_requiredFields == nil) {
        
        _requiredFields = [[NSArray alloc] initWithObjects: nil];
        
    }
    
    return _requiredFields;
    
}

+ (NSString *)_method {
    
    static NSString * _method = @"POST";
    
    return _method;
}

+ (NSString *)_path {
    
    static NSString * _path = ALARM_LIST_PATH;
    
    return _path;
    
}



@end
