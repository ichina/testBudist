//
//  User.h
//  iSeller
//
//  Created by Chingis Gomboev on 27.12.12.
//  Copyright (c) 2012 CloudTeam. All rights reserved.
//
//
// :id, :name, :token, :balance, :device, :device_token, :skype, :phone, :email

#import "Model.h"

@interface User : Model

@property(nonatomic, strong) NSNumber* identifier;
@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) NSString* token;
@property(nonatomic, strong) NSNumber* sex;
@property(nonatomic, strong) NSString* birthday;
@property(nonatomic, strong) NSString* age;
@property(nonatomic, strong) NSString* phone;
@property(nonatomic, strong) NSString* email;
@property(nonatomic, strong) NSString* avatar;
@property(nonatomic, strong) NSString* countryPrefix;
@property(nonatomic, strong) NSString* region;

@property (nonatomic, assign) BOOL isAuthorized;

-(NSString*)avatar;
@end