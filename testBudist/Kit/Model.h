//
//  Model.h
//  iSeller
//
//  Created by Chingis Gomboev on 27.12.12.
//  Copyright (c) 2012 CloudTeam. All rights reserved.
//
//
// :id

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>

#import "Networking.h"

#import <JSONKit.h>

#import <objc/runtime.h>

#import "ContentMapper.h"

// Constant id for achiving Model

static NSString *const kContents = @"Contents";

// Request keys

static NSString *const RequestKeyHTTPMethod = @"RKHTTPMethods";
static NSString *const RequestKeyParameters = @"RKParameters";

@protocol ModelDelegate;

@interface Model : NSObject 

// Blocks

#if NS_BLOCKS_AVAILABLE
typedef void(^SuccessBlock)(id object);
typedef void(^ProgressBlock)(float progress);
typedef void(^FailureBlock)(id object, NSError* error);
#endif

// Property map

- (NSDictionary *)_propertyMap;

// Initializing methods

- (id)initWithContents:(NSDictionary *)_contents;

// Fill methods

- (void)fillWithContents:(NSDictionary *)_contents;


// Request methods

+ (void)executeRequest:(KIMutableURLRequest *)request progress:(ProgressBlock)progressBlock success:(SuccessBlock)successBlock failure:(FailureBlock)failureBlock;

+ (HTTPRequestOperation *)constructHTTPOperationWithRequest:(KIMutableURLRequest *)request progress:(ProgressBlock)progressBlock success:(SuccessBlock)successBlock failure:(FailureBlock)failureBlock;

+ (NSArray *)getOperationsWithTag:(NSString *)_tag;

+ (void)cancelAllRequests;

+ (void)cancelLastRequest;

+ (void)cancelOperation:(HTTPRequestOperation *)_operation;

+ (void)operationError:(HTTPRequestOperation *)operation error:(NSError *)error;

// Delegate methods

@end
