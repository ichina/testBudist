//
//  Model.m
//  iSeller
//
//  Created by Paul Semionov on 27.12.12.
//  Copyright (c) 2012 CloudTeam. All rights reserved.
//
// Вся структура родительского класса должна быть сохранена в последующих сабклассах.
//
//
//

#import "Model.h"

#import "User.h"

#import "HTTPClient.h"

#import "ErrorHandler.h"

#import <GAI.h>

#import "NSDate+Extensions.h"

@implementation Model

@synthesize delegate;

#pragma mark Core
#pragma mark Model archiving methods

/*
 2 метода для архивации объекта модели (например, в NSUserDefaults).
 */

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self=[super init])) {
        //contents = [decoder decodeObjectForKey:kContents];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //[encoder encodeObject:contents forKey:kContents];
}

#pragma mark Core
#pragma mark Model mapping methods

- (NSDictionary *)_propertyMap {
    
    static NSDictionary *_propertyMap;
    
    if(_propertyMap == nil) {
        
        _propertyMap = [NSDictionary dictionaryWithObjectsAndKeys:nil, nil];
        
    }
    
    return _propertyMap;
}

#pragma mark Core
#pragma mark Model initializing methods

// Initialize Model using contents (dict)

- (id)initWithContents:(NSDictionary *)_contents {
    
	if((self = [super init])) {
        
        BOOL isValidContent = ![_contents isKindOfClass:[NSNull class]] ; // проверка NSNull (на nil создавать не критично)

        [self fillWithContents:isValidContent ? _contents : nil];
	}
	
	return self;
}

+ (void)initialize {
    
    [super initialize];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
}

#pragma mark Core
#pragma mark Model fill methods

- (void)fillWithContents:(NSDictionary *)_contents {
    
    //получаю свойства всех классов в иерархии от текущего класса до Model, не включая сам Model
    NSMutableDictionary *_properties = [[self allClassHierarchyPropertyTypeDictionaryWithClass:[self class]] mutableCopy];
    
    NSDictionary *_map = [ContentMapper dictionaryWithProperties:[NSDictionary dictionaryWithDictionary:_properties] andContent:_contents];
    
    [self setValuesForKeysWithDictionary:_map];
}

#pragma mark Network
#pragma mark Model network methods

/*
 Исполнение запроса. Вызывает создание запорса.
 */

+ (void)executeRequest:(KIMutableURLRequest *)request progress:(ProgressBlock)progressBlock success:(SuccessBlock)successBlock failure:(FailureBlock)failureBlock {
        
    if([HTTPClient sharedClient].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        
        NSLog(@"Reachability status: not reachable");
        
        NSError *error = [NSError errorWithDomain:@"NetoworkErrorDomain" code:-10002 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The Internet connection appears to be offline.", NSLocalizedDescriptionKey, nil]];
        
        if(failureBlock) {
            
            failureBlock(nil, error);
            
        }
        
        return;
        
    }
    
    if(!request) {
        
        if(failureBlock) {
            
            NSError *error = [NSError errorWithDomain:@"CustomDomain" code:-10001 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Request cannot be processed.", NSLocalizedDescriptionKey, nil]];
            
            [[ErrorHandler sharedHandler] handleError:error];
            
            failureBlock(nil, error);
        }
        return;
    }
        
    HTTPRequestOperation *httpOperation = [self constructHTTPOperationWithRequest:request progress:progressBlock success:successBlock failure:failureBlock];
    
    httpOperation.tag = NSStringFromClass([self class]);
    
    [[HTTPClient sharedClient].operationQueue addOperation:httpOperation];
     
}

/*
 Создание запроса.
 */

+ (HTTPRequestOperation *)constructHTTPOperationWithRequest:(KIMutableURLRequest *)request progress:(ProgressBlock)progressBlock success:(SuccessBlock)successBlock failure:(FailureBlock)failureBlock {
    
    [request setTimeoutInterval:35];
        
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    
    HTTPRequestOperation *httpOperation = [[HTTPRequestOperation alloc] initWithRequest:request];
    
    if(request.initialBodyStream) {
    
        [httpOperation setBodyStream:request.initialBodyStream];
        
    }
    
    [httpOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        
        float progress = ((float)totalBytesWritten) / totalBytesExpectedToWrite;
        
        double speed = totalBytesWritten / ([NSDate timeIntervalSinceReferenceDate] - start);
        
        float estimatedTime = ((totalBytesExpectedToWrite - totalBytesWritten) / speed);
        
        NSLog(@"Progress: %.2f%% (%.2f KB of %.2f KB), speed: %.2f Kb/s, estimated time: %.0fs", progress * 100, (float)totalBytesWritten / 1024, (float)totalBytesExpectedToWrite / 1024, (speed / 1024), estimatedTime);
        
        if(progressBlock) {
            
            progressBlock(progress);
            
        }
        
    }];
    
    [httpOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        
        float progress = ((float)totalBytesRead) / totalBytesExpectedToRead;
        
        if(totalBytesExpectedToRead != -1) {
            
            NSLog(@"Download progress: %.2f%%", progress * 100);
            
        }
        
    }];
    
    [httpOperation setCompletionBlockWithSuccess:^(HTTPRequestOperation *operation, id responseObject) {
                
        id object = [operation.responseData objectFromJSONData];
        
        NSLog(@"\n\n\nSucceeded request \"%@\" andMethod %@", operation.request.URL.path,operation.request.HTTPMethod);
        NSLog(@"Succeeded with status code: %i\n\n\n", [operation.response statusCode]);
        
        [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
        
        if(successBlock) {
            
            successBlock(object);
            
        }
        
    } failure:^(HTTPRequestOperation *operation, NSError *error) {
        
        [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
        
        if(error.code == -1009 || operation.response.statusCode == 408) {
            
            if(([operation.request.HTTPMethod isEqualToString:@"POST"] || [operation.request.HTTPMethod isEqualToString:@"PUT"] || [operation.request.HTTPMethod isEqualToString:@"DELETE"]) && !operation.isCancelled) {
                
                [[HTTPClient sharedClient] operationFailed:[self constructHTTPOperationWithRequest:request progress:progressBlock success:successBlock failure:failureBlock]];   
                
            }
        }
        
        [self operationError:operation error:operation.error];
        
        if(!operation.isCancelled) {
            
            if(failureBlock) {
                
                failureBlock(nil, error);
                
            }
        }
        
    }];
    
    return httpOperation;
    
}

#pragma mark Network
#pragma mark Model request control methods

+ (NSArray *)getOperationsWithTag:(NSString *)_tag {
    
    NSArray *mainQueue = [[[[HTTPClient sharedClient] operationQueue] operations] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.tag == %@", _tag]];
    
    NSArray *failedQueue;
    
    if(mainQueue.count == 0) {
        
        failedQueue = [[[[HTTPClient sharedClient] failureOperationQueue] operations] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.tag == %@", _tag]];
        
        if(failedQueue.count > 0) {
            
            return failedQueue;
            
        }else{
            
            return nil;
            
        }
        
    }
    
    return mainQueue;
    
}

+ (void)cancelAllRequests {
    
    do {
        
        [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
        
    } while ([[AFNetworkActivityIndicatorManager sharedManager] isNetworkActivityIndicatorVisible]);
    
    if([[[HTTPClient sharedClient] operationQueue] operations].count > 0) {
        
        [[[HTTPClient sharedClient] operationQueue] cancelAllOperations];
                
    }
    
    if([[[HTTPClient sharedClient] failureOperationQueue] operations].count > 0){
        
        [[[HTTPClient sharedClient] failureOperationQueue] cancelAllOperations];
        
    }
    
}

+ (void)cancelLastRequest {
    
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
    
    if([[[HTTPClient sharedClient] operationQueue] operations].count > 0 || [[[HTTPClient sharedClient] failureOperationQueue] operations].count > 0) {
        
        if([[[[[HTTPClient sharedClient] operationQueue] operations] lastObject] isExecuting]) {
            
            [[[[[HTTPClient sharedClient] operationQueue] operations] lastObject] cancel];
            
        }else{
            
            [[[[[HTTPClient sharedClient] failureOperationQueue] operations] lastObject] cancel];
            
        }
                        
    }
    
}

+ (void)cancelOperation:(HTTPRequestOperation *)_operation {
    
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
    
    if([[[HTTPClient sharedClient] operationQueue] operations].count > 0 || [[[HTTPClient sharedClient] failureOperationQueue] operations].count > 0) {
        
        [_operation cancel];
        
    }
    
}

#pragma mark Errors
#pragma mark Model error handling methods

+ (void)operationError:(HTTPRequestOperation*)operation error:(NSError *)error
{
    id object = [operation.responseData objectFromJSONData];
    
    if(error.code == -1011) {
        
        if(object) {
            
            error = [[NSError alloc] initWithDomain:error.domain code:operation.response.statusCode userInfo:[NSDictionary dictionaryWithObject:object forKey:kErrorObject]];
            
        }else{
            
            NSLog(@"%@\n%@", error.localizedDescription, operation.error.localizedDescription);
            
        }
        
    }else if(error.code == -1021){
        
        NSLog(@"Trying to recover after \"request body stream exhausted\".");
        
        //Fix "request body stream exhausted": https://github.com/AFNetworking/AFNetworking/pull/718
        // https://github.com/AFNetworking/AFNetworking/commit/23d3bd5af4d9d895c5d3349550db98d05cc3ba37
        
    }
    
    NSLog(@"Error: %@", [error localizedDescription]);
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker sendException:NO withDescription:@"(%@)Error: %@ while performing request with url: %@", [[NSDate date] dateToUTCWithFormat:nil], [error localizedDescription], [NSString stringWithFormat:@"%@%@", operation.request.URL.host, operation.request.URL.path]];
    
    [[ErrorHandler sharedHandler] handleError:error];
    
}

#pragma mark Core
#pragma mark Model Obj-C core

/*
    placeholder message
 */


/*
 * @returns A string describing the type of the property
 */

- (NSString *)propertyTypeStringOfProperty:(objc_property_t)property {
    const char *attr = property_getAttributes(property);
    NSString *const attributes = [NSString stringWithCString:attr encoding:NSUTF8StringEncoding];
    
    NSRange const typeRangeStart = [attributes rangeOfString:@"T@\""];  // start of type string
    if (typeRangeStart.location != NSNotFound) {
        NSString *const typeStringWithQuote = [attributes substringFromIndex:typeRangeStart.location + typeRangeStart.length];
        NSRange const typeRangeEnd = [typeStringWithQuote rangeOfString:@"\""]; // end of type string
        if (typeRangeEnd.location != NSNotFound) {
            NSString *const typeString = [typeStringWithQuote substringToIndex:typeRangeEnd.location];
            return typeString;
        }
    }
    return nil;
}

/**
 * @returns (NSString) Dictionary of property name --> type
 */

- (NSDictionary *)propertyTypeDictionaryWithClass:(Class)klass {
            
    NSMutableDictionary *propertyMap = [NSMutableDictionary dictionary];
    
    unsigned int outCount, i;
    
    objc_property_t *properties = class_copyPropertyList(klass, &outCount);
    
    for(i = 0; i < outCount; i++) {
        
        objc_property_t property = properties[i];
        
        const char *propName = property_getName(property);
        
        if(propName) {
            
            NSString *propertyName = [NSString stringWithCString:propName encoding:NSUTF8StringEncoding];
            NSString *propertyType = [self propertyTypeStringOfProperty:property];
            [propertyMap setValue:propertyType forKey:propertyName];
        }
    }
    
    free(properties);
    
    return propertyMap;
}

/**
 * @returns Dictionary of  all class hierarchy property name --> type
 */

- (NSDictionary *)allClassHierarchyPropertyTypeDictionaryWithClass:(Class)klass {

    Class BaseClass = NSClassFromString(@"Model");
    id CurrentClass = klass;
    
    NSMutableDictionary *propertyMap = [NSMutableDictionary dictionary];
    
    while(nil != CurrentClass && CurrentClass != BaseClass){
        
        [propertyMap addEntriesFromDictionary:[self propertyTypeDictionaryWithClass:CurrentClass]];
        
        CurrentClass = class_getSuperclass(CurrentClass);
    }
    return propertyMap;
}

@end
