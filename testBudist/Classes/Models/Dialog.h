//
//  Dialog.h
//  iSeller
//
//  Created by Чина on 16.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Model.h"

#import "Advertisement.h"

@interface Dialog : Model

@property(nonatomic,strong) NSNumber* identifier;
@property(nonatomic,strong) NSString* body;
@property(nonatomic,strong) NSNumber* fresh;
@property(nonatomic,strong) NSString* createdAt;
@property(nonatomic,strong) NSNumber* freshCount;
@property(nonatomic,strong) NSNumber* incoming;
@property(nonatomic,strong) Advertisement* ad;
@property(nonatomic,strong) User* user;

+ (void)getDialogsWithLastIdentifier:(NSString *)identifier success:(AdvertisementsSuccessBlock)_success failure:(AdvertisementsFailureBlock)_failure;

-(BOOL)isEqualToDialog:(Dialog*)tempDialog;
@end
