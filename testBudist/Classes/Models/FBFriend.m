//
//  FBFriend.m
//  iSeller
//
//  Created by Чингис on 29.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "FBFriend.h"

@implementation FBFriend

-(id)initWithFBContents:(NSDictionary* ) contents
{
    self = [super init];
    if(self)
    {
        [self fillFBContents:contents];
    }
    return self;
}


-(id)initWithVKContents:(NSDictionary* ) contents
{
    self = [super init];
    if(self)
    {
        [self fillVKContents:contents];
    }
    return self;
}


-(void)fillFBContents:(NSDictionary*) contents
{
    if(!contents)
        return;
    self.identifier = contents[@"id"] ? contents[@"id"] : (self.identifier ? self.identifier:@"");
    self.name = contents[@"name"] ? contents[@"name"] : (self.name ? self.name:@"");
    self.installed = contents[@"installed"] ? [contents[@"installed"] boolValue]: self.installed;
    self.imageUrl = contents[@"picture"][@"data"][@"url"] ? contents[@"picture"][@"data"][@"url"] : (self.imageUrl ? self.imageUrl:@"");
}


-(void)fillVKContents:(NSDictionary*) contents
{
    if(!contents)
        return;
    self.identifier = contents[@"uid"] ? contents[@"uid"] : (self.identifier ? self.identifier:@"");
    NSString* name = [NSString stringWithFormat:@"%@ %@",contents[@"first_name"],contents[@"last_name"]];
    self.name = name;
    //self.installed = contents[@"installed"] ? [contents[@"installed"] boolValue]: self.installed;
    self.imageUrl = contents[@"photo"] ? contents[@"photo"] : (self.imageUrl ? self.imageUrl:@"");
}



@end
