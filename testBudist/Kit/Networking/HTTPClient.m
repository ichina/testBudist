
//
//  HTTPClient.m
//  iSeller
//
//  Created by Paul Semenov on 10.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "HTTPClient.h"

#import <Availability.h>

#ifdef _SYSTEMCONFIGURATION_H
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#endif

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
#import <UIKit/UIKit.h>
#endif

#ifdef _SYSTEMCONFIGURATION_H

typedef SCNetworkReachabilityRef AFNetworkReachabilityRef;
typedef void (^AFNetworkReachabilityStatusBlock)(AFNetworkReachabilityStatus status);
#else
typedef id AFNetworkReachabilityRef;
#endif

@interface StreamingMultipartFormData : NSObject <MultipartFormData>
@property (readwrite, nonatomic, strong) MultipartBodyStream *bodyStream;
- (id)initWithURLRequest:(KIMutableURLRequest *)urlRequest
          stringEncoding:(NSStringEncoding)encoding;

- (KIMutableURLRequest *)requestByFinalizingMultipartFormData;
@end

static NSString * PercentEscapedQueryStringPairMemberFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    static NSString * const kAFCharactersToBeEscaped = @":/?&=;+!@#$()~";
    static NSString * const kAFCharactersToLeaveUnescaped = @"[].";
    
	return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, (__bridge CFStringRef)kAFCharactersToLeaveUnescaped, (__bridge CFStringRef)kAFCharactersToBeEscaped, CFStringConvertNSStringEncodingToEncoding(encoding));
}

#pragma mark -

@interface QueryStringPair : NSObject
@property (readwrite, nonatomic, strong) id field;
@property (readwrite, nonatomic, strong) id value;

- (id)initWithField:(id)field value:(id)value;

- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding;
@end

@implementation QueryStringPair
@synthesize field = _field;
@synthesize value = _value;

- (id)initWithField:(id)field value:(id)value {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.field = field;
    self.value = value;
    
    return self;
}

- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding {
    if (!self.value || [self.value isEqual:[NSNull null]]) {
        return PercentEscapedQueryStringPairMemberFromStringWithEncoding([self.field description], stringEncoding);
    } else {
        return [NSString stringWithFormat:@"%@=%@", PercentEscapedQueryStringPairMemberFromStringWithEncoding([self.field description], stringEncoding), PercentEscapedQueryStringPairMemberFromStringWithEncoding([self.value description], stringEncoding)];
    }
}

@end

#pragma mark -

@interface AFHTTPClient ()
@property (readwrite, nonatomic) NSURL *baseURL;
@property (readwrite, nonatomic) NSMutableArray *registeredHTTPOperationClassNames;
@property (readwrite, nonatomic) NSMutableDictionary *defaultHeaders;
@property (readwrite, nonatomic) NSOperationQueue *operationQueue;
#ifdef _SYSTEMCONFIGURATION_H
@property (readwrite, nonatomic, assign) AFNetworkReachabilityRef networkReachability;
@property (readwrite, nonatomic, assign) AFNetworkReachabilityStatus networkReachabilityStatus;
@property (readwrite, nonatomic, copy) AFNetworkReachabilityStatusBlock networkReachabilityStatusBlock;
#endif

@property (nonatomic, assign) BOOL isNeedAlert;

@end

@implementation HTTPClient

@synthesize failureOperationQueue;

@synthesize isNeedAlert;

#pragma mark Singleton methods

static HTTPClient *instance_;

static int failureQueueObservanceContext;

+ (HTTPClient *)sharedClient {
    @synchronized(self) {
        if( instance_ == nil ) {
            instance_ = [[self alloc] initWithBaseURL:[NSURL URLWithString:HOST]];
        }
    }
    
    return instance_;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if(self)
    {
        instance_ = self;
        
        self.isNeedAlert = YES;
        
        self.failureOperationQueue = [[NSOperationQueue alloc] init];
        
        __weak __typeof(&*self)weakSelf = self;
                
        [weakSelf setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            
            [weakSelf.failureOperationQueue setSuspended: (status == AFNetworkReachabilityStatusNotReachable) ];
            
            NSLog(@"network status %d",status);
            
            if(status == AFNetworkReachabilityStatusNotReachable) {
                
                if(self.isNeedAlert) {
                
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Internet connection failed", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                    
                    self.isNeedAlert = NO;
                    
                }
                
            }else if(status == AFNetworkReachabilityStatusReachableViaWiFi || status == AFNetworkReachabilityStatusReachableViaWWAN) {
                
                for(int i = 0;i < self.failureOperationQueue.operationCount;i++) {
                    
                    [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
                    
                }
                
                self.isNeedAlert = YES;
            }
        }];
        
        [weakSelf.failureOperationQueue addObserver:self forKeyPath:@"operationCount" options:NSKeyValueObservingOptionNew context:&failureQueueObservanceContext];
        //[self.operationQueue addObserver:self forKeyPath:@"operationCount" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:&operationQueueObservanceContext];
        
    }
    [self setDefaultHeader:@"X-Platform" value:@"ios"];
    [self setDefaultHeader:@"Accept-Language" value:@"ru, en, fr, de, ja, nl, it, es, pt, pt-PT, da, fi, nb, sv, ko, zh-Hans, zh-Hant, pl, tr, uk, ar, hr, cs, el, he, ro, sk, th, id, ms, en-GB, ca, hu, vi, en-us;q=0.8"];
    [self setDefaultHeader:@"X-Requested-With" value:@"XMLHttpRequest"];
    [self setDefaultHeader:@"X-Client-Version" value:@"2.8.2.10"];
    [self setDefaultHeader:@"Api-Version" value:@"3.0"];

    
    [self setDefaultHeader:@"Accept" value:@"application/json"];

    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(context == &failureQueueObservanceContext)
    {
        NSLog(@"count of failureQueue %@",change[@"new"]);
        
    }else/* if(context == &operationQueueObservanceContext)
          {
          if([change[@"new"] integerValue]>[change[@"old"] integerValue])
          {
          [requests setObject:[[(AFHTTPRequestOperation*)self.operationQueue.operations.lastObject request] copy] forKey:[(AFHTTPRequestOperation*)self.operationQueue.operations.lastObject request].URL.absoluteString];
          }
          }else*/
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)operationFailed:(HTTPRequestOperation *)operation {
    
    if([failureOperationQueue operationCount])
        [operation addDependency:[[failureOperationQueue operations] lastObject]];
        
    [failureOperationQueue addOperation:operation];
}

#pragma mark -

extern NSArray * AFQueryStringPairsFromDictionary(NSDictionary *dictionary);
extern NSArray * AFQueryStringPairsFromKeyAndValue(NSString *key, id value);

NSString * QueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding stringEncoding) {
    NSMutableArray *mutablePairs = [NSMutableArray array];
    for (QueryStringPair *pair in QueryStringPairsFromDictionary(parameters)) {
        [mutablePairs addObject:[pair URLEncodedStringValueWithEncoding:stringEncoding]];
    }
    
    return [mutablePairs componentsJoinedByString:@"&"];
}

NSArray * QueryStringPairsFromDictionary(NSDictionary *dictionary) {
    return QueryStringPairsFromKeyAndValue(nil, dictionary);
}

NSArray * QueryStringPairsFromKeyAndValue(NSString *key, id value) {
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        // Sort dictionary keys to ensure consistent ordering in query string, which is important when deserializing potentially ambiguous sequences, such as an array of dictionaries
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        [[[value allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]] enumerateObjectsUsingBlock:^(id nestedKey, __unused NSUInteger idx, __unused BOOL *stop) {
            id nestedValue = [value objectForKey:nestedKey];
            if (nestedValue) {
                [mutableQueryStringComponents addObjectsFromArray:QueryStringPairsFromKeyAndValue((key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey), nestedValue)];
            }
        }];
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
        [array enumerateObjectsUsingBlock:^(id nestedValue, __unused NSUInteger idx, __unused BOOL *stop) {
            [mutableQueryStringComponents addObjectsFromArray:QueryStringPairsFromKeyAndValue([NSString stringWithFormat:@"%@[]", key], nestedValue)];
        }];
    } else {
        [mutableQueryStringComponents addObject:[[QueryStringPair alloc] initWithField:key value:value]];
    }
    
    return mutableQueryStringComponents;
}

- (KIMutableURLRequest *)multipartFormRequestWithMethod:(NSString *)method
                                                   path:(NSString *)path
                                             parameters:(NSDictionary *)parameters
                              constructingBodyWithBlock:(void (^)(id <MultipartFormData> formData))block
{
    NSParameterAssert(method);
    NSParameterAssert(![method isEqualToString:@"GET"] && ![method isEqualToString:@"HEAD"]);
    
    KIMutableURLRequest *request = [self requestWithMethod:method path:path parameters:nil];
    
    __block StreamingMultipartFormData *formData = [[StreamingMultipartFormData alloc] initWithURLRequest:request stringEncoding:self.stringEncoding];
    
    if (parameters) {
        for (QueryStringPair *pair in QueryStringPairsFromDictionary(parameters)) {
            NSData *data = nil;
            if ([pair.value isKindOfClass:[NSData class]]) {
                data = pair.value;
            } else if ([pair.value isEqual:[NSNull null]]) {
                data = [NSData data];
            } else {
                data = [[pair.value description] dataUsingEncoding:self.stringEncoding];
            }
            
            if (data) {
                [formData appendPartWithFormData:data name:[pair.field description]];
            }
        }
    }
    
    if (block) {
        block(formData);
    }
        
    return [formData requestByFinalizingMultipartFormData];
}

- (KIMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {
    
    NSParameterAssert(method);
    
    if (!path) {
        path = @"";
    }
    
    NSURL *url = [NSURL URLWithString:path relativeToURL:self.baseURL];
	KIMutableURLRequest *request = [[KIMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:method];
    [request setAllHTTPHeaderFields:self.defaultHeaders];
	
    if (parameters) {
        if ([method isEqualToString:@"GET"] || [method isEqualToString:@"HEAD"] || [method isEqualToString:@"DELETE"]) {
            url = [NSURL URLWithString:[[url absoluteString] stringByAppendingFormat:[path rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@", AFQueryStringFromParametersWithEncoding(parameters, self.stringEncoding)]];
            [request setURL:url];
        } else {
            NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(self.stringEncoding));
            NSError *error = nil;
            
            switch (self.parameterEncoding) {
                case AFFormURLParameterEncoding:;
                    [request setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:[AFQueryStringFromParametersWithEncoding(parameters, self.stringEncoding) dataUsingEncoding:self.stringEncoding]];
                    break;
                case AFJSONParameterEncoding:;
                    [request setValue:[NSString stringWithFormat:@"application/json; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error]];
                    break;
                case AFPropertyListParameterEncoding:;
                    [request setValue:[NSString stringWithFormat:@"application/x-plist; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:[NSPropertyListSerialization dataWithPropertyList:parameters format:NSPropertyListXMLFormat_v1_0 options:0 error:&error]];
                    break;
            }
            
            if (error) {
                NSLog(@"%@ %@: %@", [self class], NSStringFromSelector(_cmd), error);
            }
        }
    }
    
	return request;
}

@end

#pragma mark -

@interface StreamingMultipartFormData ()
@property (readwrite, nonatomic) KIMutableURLRequest *request;
@property (readwrite, nonatomic, assign) NSStringEncoding stringEncoding;
@end

@implementation StreamingMultipartFormData
@synthesize request = _request;
@synthesize bodyStream = _bodyStream;
@synthesize stringEncoding = _stringEncoding;

- (id)initWithURLRequest:(KIMutableURLRequest *)urlRequest
          stringEncoding:(NSStringEncoding)encoding
{
    self = [super init];
    if (!self) {
        return nil;
    }
        
    self.request = urlRequest;
    self.stringEncoding = encoding;
    self.bodyStream = [[MultipartBodyStream alloc] initWithStringEncoding:encoding];
    
    return self;
}

- (BOOL)appendPartWithFileURL:(NSURL *)fileURL
                         name:(NSString *)name
                        error:(NSError * __autoreleasing *)error
{
    NSParameterAssert(fileURL);
    NSParameterAssert(name);
    
    if (![fileURL isFileURL]) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedStringFromTable(@"Expected URL to be a file URL", @"AFNetworking", nil) forKey:NSLocalizedFailureReasonErrorKey];
        if (error != NULL) {
            *error = [[NSError alloc] initWithDomain:AFNetworkingErrorDomain code:NSURLErrorBadURL userInfo:userInfo];
        }
        
        return NO;
    } else if ([fileURL checkResourceIsReachableAndReturnError:error] == NO) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedStringFromTable(@"File URL not reachable.", @"AFNetworking", nil) forKey:NSLocalizedFailureReasonErrorKey];
        if (error != NULL) {
            *error = [[NSError alloc] initWithDomain:AFNetworkingErrorDomain code:NSURLErrorBadURL userInfo:userInfo];
        }
        
        return NO;
    }
    
    NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionary];
    [mutableHeaders setValue:[NSString stringWithFormat:@"form-data; name=\"%@\"; filename=\"%@\"", name, [fileURL lastPathComponent]] forKey:@"Content-Disposition"];
    [mutableHeaders setValue:AFContentTypeForPathExtension([fileURL pathExtension]) forKey:@"Content-Type"];
    
    HTTPBodyPart *bodyPart = [[HTTPBodyPart alloc] init];
    bodyPart.stringEncoding = self.stringEncoding;
    bodyPart.headers = mutableHeaders;
    bodyPart.inputURL = fileURL;
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[fileURL path] error:nil];
    bodyPart.bodyContentLength = [[fileAttributes objectForKey:NSFileSize] unsignedLongLongValue];
    
    [self.bodyStream appendHTTPBodyPart:bodyPart];
    
    return YES;
}

- (void)appendPartWithFileData:(NSData *)data
                          name:(NSString *)name
                      fileName:(NSString *)fileName
                      mimeType:(NSString *)mimeType
{
    NSParameterAssert(name);
    NSParameterAssert(fileName);
    NSParameterAssert(mimeType);
    
    NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionary];
    [mutableHeaders setValue:[NSString stringWithFormat:@"form-data; name=\"%@\"; filename=\"%@\"", name, fileName] forKey:@"Content-Disposition"];
    [mutableHeaders setValue:mimeType forKey:@"Content-Type"];
    
    [self appendPartWithHeaders:mutableHeaders body:data];
}

- (void)appendPartWithFormData:(NSData *)data
                          name:(NSString *)name
{
    NSParameterAssert(name);
    
    NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionary];
    [mutableHeaders setValue:[NSString stringWithFormat:@"form-data; name=\"%@\"", name] forKey:@"Content-Disposition"];
    
    [self appendPartWithHeaders:mutableHeaders body:data];
}

- (void)appendPartWithHeaders:(NSDictionary *)headers
                         body:(NSData *)body
{
    NSParameterAssert(body);
    
    HTTPBodyPart *bodyPart = [[HTTPBodyPart alloc] init];
    bodyPart.stringEncoding = self.stringEncoding;
    bodyPart.headers = headers;
    bodyPart.bodyContentLength = [body length];
    bodyPart.inputData = body;
    
    [self.bodyStream appendHTTPBodyPart:bodyPart];
}

- (void)throttleBandwidthWithPacketSize:(NSUInteger)numberOfBytes
                                  delay:(NSTimeInterval)delay
{
    self.bodyStream.numberOfBytesInPacket = numberOfBytes;
    self.bodyStream.delay = delay;
}

- (KIMutableURLRequest *)requestByFinalizingMultipartFormData {
    if ([self.bodyStream isEmpty]) {
        return self.request;
    }
    
    // Reset the initial and final boundaries to ensure correct Content-Length
    [self.bodyStream setInitialAndFinalBoundaries];
    
    [self.request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", kAFMultipartFormBoundary] forHTTPHeaderField:@"Content-Type"];
    [self.request setValue:[NSString stringWithFormat:@"%llu", [self.bodyStream contentLength]] forHTTPHeaderField:@"Content-Length"];
    [self.request setHTTPBodyStream:self.bodyStream];
    [self.request setInitialBodyStream:self.bodyStream];
    
    return self.request;
}

@end
