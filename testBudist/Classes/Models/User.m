//
//  User.m
//  iSeller
//
//  Created by Chingis Gomboev on 27.12.12.
//  Copyright (c) 2012 CloudTeam. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize isAuthorized;

@synthesize identifier;
@synthesize name;
@synthesize token;
@synthesize birthday;
@synthesize sex;
@synthesize age;
@synthesize phone;
@synthesize email;
@synthesize avatar;
@synthesize region;
@synthesize countryPrefix;

-(NSString*)avatar
{
    return [NSString stringWithFormat:@"http://budist.s3.amazonaws.com/avatars/%@/%@.jpg",avatar,IS_RETINA?@"100":@"50"];
}
@end
