//
//  User.h
//  iSeller
//
//  Created by Paul Semionov on 27.12.12.
//  Copyright (c) 2012 CloudTeam. All rights reserved.
//
//
// :id, :name, :token, :balance, :device, :device_token, :skype, :phone, :email

#import "Model.h"

@interface User : Model

@property(nonatomic, strong) NSNumber* identifier;
@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) NSString* token;
@property(nonatomic, strong) NSMutableArray* devices;
@property(nonatomic, strong) NSString* deviceToken;
@property(nonatomic, strong) NSString* skype;
@property(nonatomic, strong) NSString* phone;
@property(nonatomic, strong) NSString* email;
@property(nonatomic, strong) NSString* contactEmail;
@property(nonatomic, strong) NSString* avatar;
@property(nonatomic, strong) NSString* messagesCount;


@property (nonatomic, assign) BOOL isAuthorized;

@end