//
//  FavListBuilder.m
//  iSeller
//
//  Created by Чина on 12.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "FavouritesListBuilder.h"

@implementation FavouritesListBuilder

+ (NSArray *)_requiredFields {
    
    static NSArray * _requiredFields = nil;
    
    if(_requiredFields == nil) {
        
        _requiredFields = [[NSArray alloc] init];
        
    }
    
    return _requiredFields;
    
}

+ (NSString *)_method {
    
    static NSString * _method = @"GET";
    
    return _method;
    
}

+ (NSString *)_path {
    
    static NSString * _path = FAV_LIST_PATH;
    
    return _path;
    
}
@end
