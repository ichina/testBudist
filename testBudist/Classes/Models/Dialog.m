//
//  Dialog.m
//  iSeller
//
//  Created by Чина on 16.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "Dialog.h"

#import "Profile.h"

#import "PostMessageBuilder.h"
#import "DialogsListBuilder.h"
#import "DialogBuilder.h"

@implementation Dialog

@synthesize identifier;
@synthesize body;
@synthesize fresh;
@synthesize createdAt;
@synthesize freshCount;
@synthesize incoming;
@synthesize ad;
@synthesize user;

+ (void)getDialogsWithLastIdentifier:(NSString *)identifier success:(AdvertisementsSuccessBlock)_success failure:(AdvertisementsFailureBlock)_failure
{
    NSDictionary *params = @{
    @"before" : identifier,
    @"token" : [[Profile sharedProfile] token]
    };
    
    KIMutableURLRequest* request = [DialogsListBuilder buildRequestWithParameters:params];
    
    [self executeRequest:request progress:nil success:^(id object) {
        
        NSMutableArray* array = [self convertArray:object];
        
        if(_success)
            _success(array);
        
    } failure:^(id object, NSError *error) {
        if (_failure)
            _failure(object, error);
    }];
}

+ (NSMutableArray*)convertArray:(NSArray*)_array
{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:[(NSArray*)_array count]];
    
    for(NSDictionary* dict in _array)
    {
        Dialog* ad = [[Dialog alloc] initWithContents:dict];
        [array addObject:ad];
    }
    return array;
}

-(BOOL)isEqualToDialog:(Dialog*)tempDialog
{
    if (!tempDialog) {
        return NO;
    }
    
    //если совпадают и юзер и объява
    return (tempDialog.user.identifier.integerValue == self.user.identifier.integerValue && tempDialog.ad.identifier.integerValue==self.ad.identifier.integerValue);
        
}


@end
