//
//  FBFriend.h
//  iSeller
//
//  Created by Чингис on 29.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBFriend : NSObject

typedef void(^FriendsSuccessBlock)(NSArray* ads);
typedef void(^FriendsFailureBlock)(NSDictionary* dict, NSError *error);


@property(nonatomic,strong) NSString* identifier;
@property(nonatomic,strong) NSString* name;
@property(nonatomic) BOOL installed;
@property(nonatomic,strong) NSString* imageUrl;
@property(nonatomic) BOOL needInvite;

-(id)initWithFBContents:(NSDictionary* ) contents;
-(id)initWithVKContents:(NSDictionary* ) contents;

@end
