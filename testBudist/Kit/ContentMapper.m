//
//  ValueSplitter.m
//  iSeller
//
//  Created by Paul Semionov on 17.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "ContentMapper.h"

@implementation ContentMapper

static NSDictionary *_map = nil;

static NSDictionary *_allocMap = nil;

+ (void)initialize {
    
    [super initialize];
    
    if (_map == nil)
    {
        _map = [NSDictionary dictionaryWithObjectsAndKeys:@"id", @"identifier",
                 @"name", @"name",
                 @"token", @"token",
                 @"balance", @"balance",
                 @"device", @"device",
                 @"device_token", @"deviceToken",
                 @"skype", @"skype",
                 @"phone", @"phone",
                 @"email", @"email",
                 @"avatar", @"avatar",
                 @"messages_count", @"messagesCount",
                 @"title", @"title",
                 @"image", @"image",
                 @"image", @"smallImage",
                 @"status", @"status",
                 @"images", @"images",
                 @"description", @"descriptionText",
                 @"ll", @"location",
                 @"user", @"user",
                 @"price", @"price",
                 @"body", @"body",
                 @"fresh", @"isFresh",
                 @"created_at", @"createdAt",
                 @"fresh_count", @"freshCount",
                 @"incoming?", @"incoming",
                 @"user_id" , @"userID",
                 @"ad", @"ad",
                 @"view_count", @"viewCount",
                 @"devices", @"devices",
                 @"device_id", @"deviceID",
                 @"amount", @"amount",
                 @"paid_at", @"paidAt",
                 @"favorite?", @"isFavorite",
                 @"auth_providers", @"authProviders",
                 @"data", @"data",
                 @"confirmed", @"confirmed",
                 @"contact_email",@"contactEmail",
                 @"current_price",@"currentPrice",nil];
    }
    
    if (_allocMap == nil)
    {
        _allocMap = [NSDictionary dictionaryWithObjectsAndKeys:@"User", @"user",
                @"Advertisement", @"ad", nil];
        
    }
}

+ (NSDictionary *)dictionaryWithProperties:(NSDictionary *)_properties andContent:(NSDictionary *)_content {
    
    NSMutableDictionary *_propertyMap = [NSMutableDictionary dictionary];
    
    for(NSString *property in _properties) {
                
        if([_content valueForKey:[_map valueForKey:property]]) {
            
            if([[_allocMap allKeys] containsObject:property]) {
                
                [_propertyMap setValue:[(Model *)[NSClassFromString([_allocMap valueForKey:property]) alloc] initWithContents:[_content valueForKey:[_map valueForKey:property]]] forKey:property];
                                
            }else{
                            
                [_propertyMap setValue:[_content valueForKey:[_map valueForKey:property]] forKey:property];
                                
            }
            
        }else{
                        
            //NSLog(@"Missing value for property: %@", property);
            
        }
        
    }
    
    return [NSDictionary dictionaryWithDictionary:_propertyMap];
    
}

@end
