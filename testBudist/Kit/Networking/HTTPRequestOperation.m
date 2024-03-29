//
//  HTTPRequestOperation.m
//  iSeller
//
//  Created by Paul Semenov on 15.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "HTTPRequestOperation.h"
#import <objc/runtime.h>

// Workaround for change in imp_implementationWithBlock() with Xcode 4.5
#if defined(__IPHONE_6_0) || defined(__MAC_10_8)
#define AF_CAST_TO_BLOCK id
#else
#define AF_CAST_TO_BLOCK __bridge void *
#endif

// We do a little bit of duck typing in this file which can trigger this warning.  Turn it off for this source file.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-selector-match"

NSSet * ContentTypesFromHTTPHeader(NSString *string) {
    if (!string) {
        return nil;
    }
    
    NSArray *mediaRanges = [string componentsSeparatedByString:@","];
    NSMutableSet *mutableContentTypes = [NSMutableSet setWithCapacity:mediaRanges.count];
    
    [mediaRanges enumerateObjectsUsingBlock:^(NSString *mediaRange, __unused NSUInteger idx, __unused BOOL *stop) {
        NSRange parametersRange = [mediaRange rangeOfString:@";"];
        if (parametersRange.location != NSNotFound) {
            mediaRange = [mediaRange substringToIndex:parametersRange.location];
        }
        
        mediaRange = [mediaRange stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (mediaRange.length > 0) {
            [mutableContentTypes addObject:mediaRange];
        }
    }];
    
    return [NSSet setWithSet:mutableContentTypes];
}

static void AFGetMediaTypeAndSubtypeWithString(NSString *string, NSString **type, NSString **subtype) {
    NSScanner *scanner = [NSScanner scannerWithString:string];
    [scanner setCharactersToBeSkipped:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [scanner scanUpToString:@"/" intoString:type];
    [scanner scanString:@"/" intoString:nil];
    [scanner scanUpToString:@";" intoString:subtype];
}

static NSString * AFStringFromIndexSet(NSIndexSet *indexSet) {
    NSMutableString *string = [NSMutableString string];
    
    NSRange range = NSMakeRange([indexSet firstIndex], 1);
    while (range.location != NSNotFound) {
        NSUInteger nextIndex = [indexSet indexGreaterThanIndex:range.location];
        while (nextIndex == range.location + range.length) {
            range.length++;
            nextIndex = [indexSet indexGreaterThanIndex:nextIndex];
        }
        
        if (string.length) {
            [string appendString:@","];
        }
        
        if (range.length == 1) {
            [string appendFormat:@"%lu", (long)range.location];
        } else {
            NSUInteger firstIndex = range.location;
            NSUInteger lastIndex = firstIndex + range.length - 1;
            [string appendFormat:@"%lu-%lu", (long)firstIndex, (long)lastIndex];
        }
        
        range.location = nextIndex;
        range.length = 1;
    }
    
    return string;
}

static void AFSwizzleClassMethodWithClassAndSelectorUsingBlock(Class klass, SEL selector, id block) {
    Method originalMethod = class_getClassMethod(klass, selector);
    IMP implementation = imp_implementationWithBlock((AF_CAST_TO_BLOCK)block);
    class_replaceMethod(objc_getMetaClass([NSStringFromClass(klass) UTF8String]), selector, implementation, method_getTypeEncoding(originalMethod));
}

#pragma mark -

@interface HTTPRequestOperation ()
@property (readwrite, nonatomic, strong) NSURLRequest *request;
@property (readwrite, nonatomic, strong) NSHTTPURLResponse *response;
@property (readwrite, nonatomic, strong) NSError *HTTPError;
@property (readwrite, nonatomic, copy) NSString *HTTPResponseString;
@property (readwrite, nonatomic, assign) long long totalContentLength;
@property (readwrite, nonatomic, assign) long long offsetContentLength;
@end

@implementation HTTPRequestOperation
@synthesize tag = _tag;
@synthesize HTTPError = _HTTPError;
@synthesize HTTPResponseString = _HTTPResponseString;
@synthesize successCallbackQueue = _successCallbackQueue;
@synthesize failureCallbackQueue = _failureCallbackQueue;
@synthesize totalContentLength = _totalContentLength;
@synthesize offsetContentLength = _offsetContentLength;
@dynamic request;
@dynamic response;

- (void)dealloc {
    if (_successCallbackQueue) {
#if !OS_OBJECT_USE_OBJC
        dispatch_release(_successCallbackQueue);
#endif
        _successCallbackQueue = NULL;
    }
    
    if (_failureCallbackQueue) {
#if !OS_OBJECT_USE_OBJC
        dispatch_release(_failureCallbackQueue);
#endif
        _failureCallbackQueue = NULL;
    }
}

- (NSError *)error {
    if (!self.HTTPError && self.response) {
        if (![self hasAcceptableStatusCode] || ![self hasAcceptableContentType]) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setValue:self.responseString forKey:NSLocalizedRecoverySuggestionErrorKey];
            [userInfo setValue:[self.request URL] forKey:NSURLErrorFailingURLErrorKey];
            [userInfo setValue:self.request forKey:AFNetworkingOperationFailingURLRequestErrorKey];
            [userInfo setValue:self.response forKey:AFNetworkingOperationFailingURLResponseErrorKey];
            
            if (![self hasAcceptableStatusCode]) {
                NSUInteger statusCode = ([self.response isKindOfClass:[NSHTTPURLResponse class]]) ? (NSUInteger)[self.response statusCode] : 200;
                [userInfo setValue:[NSString stringWithFormat:NSLocalizedStringFromTable(@"Expected status code in (%@), got %d", @"AFNetworking", nil), AFStringFromIndexSet([[self class] acceptableStatusCodes]), statusCode] forKey:NSLocalizedDescriptionKey];
                self.HTTPError = [[NSError alloc] initWithDomain:AFNetworkingErrorDomain code:NSURLErrorBadServerResponse userInfo:userInfo];
            } else if (![self hasAcceptableContentType]) {
                // Don't invalidate content type if there is no content
                if ([self.responseData length] > 0) {
                    [userInfo setValue:[NSString stringWithFormat:NSLocalizedStringFromTable(@"Expected content type %@, got %@", @"AFNetworking", nil), [[self class] acceptableContentTypes], [self.response MIMEType]] forKey:NSLocalizedDescriptionKey];
                    self.HTTPError = [[NSError alloc] initWithDomain:AFNetworkingErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:userInfo];
                }
            }
        }
    }
    
    if (self.HTTPError) {
        return self.HTTPError;
    } else {
        return [super error];
    }
}

- (NSString *)responseString {
    // When no explicit charset parameter is provided by the sender, media subtypes of the "text" type are defined to have a default charset value of "ISO-8859-1" when received via HTTP. Data in character sets other than "ISO-8859-1" or its subsets MUST be labeled with an appropriate charset value.
    // See http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.4.1
    if (!self.HTTPResponseString && self.response && !self.response.textEncodingName && self.responseData) {
        NSString *type = nil;
        AFGetMediaTypeAndSubtypeWithString([[self.response allHeaderFields] valueForKey:@"Content-Type"], &type, nil);
        
        if ([type isEqualToString:@"text"]) {
            self.HTTPResponseString = [[NSString alloc] initWithData:self.responseData encoding:NSISOLatin1StringEncoding];
        }
    }
    
    if (self.HTTPResponseString) {
        return self.HTTPResponseString;
    } else {
        return [super responseString];
    }
}

- (void)pause {
    unsigned long long offset = 0;
    if ([self.outputStream propertyForKey:NSStreamFileCurrentOffsetKey]) {
        offset = [[self.outputStream propertyForKey:NSStreamFileCurrentOffsetKey] unsignedLongLongValue];
    } else {
        offset = [[self.outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey] length];
    }
    
    NSMutableURLRequest *mutableURLRequest = [self.request mutableCopy];
    if ([[self.response allHeaderFields] valueForKey:@"ETag"]) {
        [mutableURLRequest setValue:[[self.response allHeaderFields] valueForKey:@"ETag"] forHTTPHeaderField:@"If-Range"];
    }
    [mutableURLRequest setValue:[NSString stringWithFormat:@"bytes=%llu-", offset] forHTTPHeaderField:@"Range"];
    self.request = mutableURLRequest;
    
    [super pause];
}

- (void)start {
    
    [super start];
    
    [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];

}

- (BOOL)hasAcceptableStatusCode {
	if (!self.response) {
		return NO;
	}
    
    NSUInteger statusCode = ([self.response isKindOfClass:[NSHTTPURLResponse class]]) ? (NSUInteger)[self.response statusCode] : 200;
    return ![[self class] acceptableStatusCodes] || [[[self class] acceptableStatusCodes] containsIndex:statusCode];
}

- (BOOL)hasAcceptableContentType {
    if (!self.response) {
		return NO;
	}
    
    // Any HTTP/1.1 message containing an entity-body SHOULD include a Content-Type header field defining the media type of that body. If and only if the media type is not given by a Content-Type field, the recipient MAY attempt to guess the media type via inspection of its content and/or the name extension(s) of the URI used to identify the resource. If the media type remains unknown, the recipient SHOULD treat it as type "application/octet-stream".
    // See http://www.w3.org/Protocols/rfc2616/rfc2616-sec7.html
    NSString *contentType = [self.response MIMEType];
    if (!contentType) {
        contentType = @"application/octet-stream";
    }
    
    return ![[self class] acceptableContentTypes] || [[[self class] acceptableContentTypes] containsObject:contentType];
}

- (void)setSuccessCallbackQueue:(dispatch_queue_t)successCallbackQueue {
    if (successCallbackQueue != _successCallbackQueue) {
        if (_successCallbackQueue) {
#if !OS_OBJECT_USE_OBJC
            dispatch_release(_successCallbackQueue);
#endif
            _successCallbackQueue = NULL;
        }
        
        if (successCallbackQueue) {
#if !OS_OBJECT_USE_OBJC
            dispatch_retain(successCallbackQueue);
#endif
            _successCallbackQueue = successCallbackQueue;
        }
    }
}

- (void)setFailureCallbackQueue:(dispatch_queue_t)failureCallbackQueue {
    if (failureCallbackQueue != _failureCallbackQueue) {
        if (_failureCallbackQueue) {
#if !OS_OBJECT_USE_OBJC
            dispatch_release(_failureCallbackQueue);
#endif
            _failureCallbackQueue = NULL;
        }
        
        if (failureCallbackQueue) {
#if !OS_OBJECT_USE_OBJC
            dispatch_retain(failureCallbackQueue);
#endif
            _failureCallbackQueue = failureCallbackQueue;
        }
    }
}

- (void)setCompletionBlockWithSuccess:(void (^)(HTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(HTTPRequestOperation *operation, NSError *error))failure
{
    // completionBlock is manually nilled out in AFURLConnectionOperation to break the retain cycle.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
    self.completionBlock = ^{
        if (self.error) {
            if (failure) {
                dispatch_async(self.failureCallbackQueue ?: dispatch_get_main_queue(), ^{
                    failure(self, self.error);
                });
            }
        } else {
            if (success) {
                dispatch_async(self.successCallbackQueue ?: dispatch_get_main_queue(), ^{
                    success(self, self.responseData);
                });
            }
        }
    };
#pragma clang diagnostic pop
}

#pragma mark - AFHTTPRequestOperation

+ (NSIndexSet *)acceptableStatusCodes {
    return [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
}

+ (void)addAcceptableStatusCodes:(NSIndexSet *)statusCodes {
    NSMutableIndexSet *mutableStatusCodes = [[NSMutableIndexSet alloc] initWithIndexSet:[self acceptableStatusCodes]];
    [mutableStatusCodes addIndexes:statusCodes];
    AFSwizzleClassMethodWithClassAndSelectorUsingBlock([self class], @selector(acceptableStatusCodes), ^(__unused id _self) {
        return mutableStatusCodes;
    });
}

+ (NSSet *)acceptableContentTypes {
    return nil;
}

+ (void)addAcceptableContentTypes:(NSSet *)contentTypes {
    NSMutableSet *mutableContentTypes = [[NSMutableSet alloc] initWithSet:[self acceptableContentTypes] copyItems:YES];
    [mutableContentTypes unionSet:contentTypes];
    AFSwizzleClassMethodWithClassAndSelectorUsingBlock([self class], @selector(acceptableContentTypes), ^(__unused id _self) {
        return mutableContentTypes;
    });
}

+ (BOOL)canProcessRequest:(NSURLRequest *)request {
    if ([[self class] isEqual:[HTTPRequestOperation class]]) {
        return YES;
    }
    
    return [[self acceptableContentTypes] intersectsSet:ContentTypesFromHTTPHeader([request valueForHTTPHeaderField:@"Accept"])];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(__unused NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    self.response = (NSHTTPURLResponse *)response;
    
    // Set Content-Range header if status code of response is 206 (Partial Content)
    // See http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html#sec10.2.7
    long long totalContentLength = self.response.expectedContentLength;
    long long fileOffset = 0;
    NSUInteger statusCode = ([self.response isKindOfClass:[NSHTTPURLResponse class]]) ? (NSUInteger)[self.response statusCode] : 200;
    if (statusCode == 206) {
        NSString *contentRange = [self.response.allHeaderFields valueForKey:@"Content-Range"];
        if ([contentRange hasPrefix:@"bytes"]) {
            NSArray *byteRanges = [contentRange componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" -/"]];
            if ([byteRanges count] == 4) {
                fileOffset = [[byteRanges objectAtIndex:1] longLongValue];
                totalContentLength = [[byteRanges objectAtIndex:2] longLongValue] ?: -1; // if this is "*", it's converted to 0, but -1 is default.
            }
        }
    } else {
        if ([self.outputStream propertyForKey:NSStreamFileCurrentOffsetKey]) {
            [self.outputStream setProperty:[NSNumber numberWithInteger:0] forKey:NSStreamFileCurrentOffsetKey];
        } else {
            if ([[self.outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey] length] > 0) {
                self.outputStream = [NSOutputStream outputStreamToMemory];
                
                NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
                for (NSString *runLoopMode in self.runLoopModes) {
                    [self.outputStream scheduleInRunLoop:runLoop forMode:runLoopMode];
                }
            }
        }
    }
    
    self.offsetContentLength = MAX(fileOffset, 0);
    self.totalContentLength = totalContentLength;
    
    [self.outputStream open];
}

@end
