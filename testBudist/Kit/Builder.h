//
//  Builder.h
//  iSeller
//
//  Created by Chingis Gomboev on 10.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Networking.h"
#import "NSString+Extensions.h"

@interface Builder : NSObject

+ (BOOL)isMultipart;

+ (NSArray *)_requiredFields;

+ (NSString *)_method;

+ (NSString *)_path;

+ (KIMutableURLRequest *)buildRequestWithParameters:(NSDictionary *)parameters;
+ (KIMutableURLRequest *)buildRequestWithParameters:(NSDictionary *)parameters error:(NSError**) error;


+ (NSDictionary *)validate:(NSDictionary *)_parameters andRequiredFields:(NSArray *)_requiredFields;

@end
