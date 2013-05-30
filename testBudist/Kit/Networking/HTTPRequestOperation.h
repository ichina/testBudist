//
//  HTTPRequestOperation.h
//  iSeller
//
//  Created by Paul Semionov on 15.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URLConnectionOperation.h"

#import <AFNetworkActivityIndicatorManager.h>

/**
 `AFHTTPRequestOperation` is a subclass of `AFURLConnectionOperation` for requests using the HTTP or HTTPS protocols. It encapsulates the concept of acceptable status codes and content types, which determine the success or failure of a request.
 */
@interface HTTPRequestOperation : URLConnectionOperation

///----------------------------------------------
/// @name Getting Operation Information
///----------------------------------------------

/**
 Tag for operation.
 */
@property (nonatomic, strong) NSString *tag;

///----------------------------------------------
/// @name Getting HTTP URL Connection Information
///----------------------------------------------

/**
 The last HTTP response received by the operation's connection.
 */
@property (readonly, nonatomic, strong) NSHTTPURLResponse *response;

///----------------------------------------------------------
/// @name Managing And Checking For Acceptable HTTP Responses
///----------------------------------------------------------

/**
 A Boolean value that corresponds to whether the status code of the response is within the specified set of acceptable status codes. Returns `YES` if `acceptableStatusCodes` is `nil`.
 */
@property (nonatomic, readonly) BOOL hasAcceptableStatusCode;

/**
 A Boolean value that corresponds to whether the MIME type of the response is among the specified set of acceptable content types. Returns `YES` if `acceptableContentTypes` is `nil`.
 */
@property (nonatomic, readonly) BOOL hasAcceptableContentType;

/**
 The callback dispatch queue on success. If `NULL` (default), the main queue is used.
 */
@property (nonatomic, assign) dispatch_queue_t successCallbackQueue;

/**
 The callback dispatch queue on failure. If `NULL` (default), the main queue is used.
 */
@property (nonatomic, assign) dispatch_queue_t failureCallbackQueue;

///------------------------------------------------------------
/// @name Managing Acceptable HTTP Status Codes & Content Types
///------------------------------------------------------------

/**
 Returns an `NSIndexSet` object containing the ranges of acceptable HTTP status codes. When non-`nil`, the operation will set the `error` property to an error in `AFErrorDomain`. See http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
 
 By default, this is the range 200 to 299, inclusive.
 */
+ (NSIndexSet *)acceptableStatusCodes;

/**
 Adds status codes to the set of acceptable HTTP status codes returned by `+acceptableStatusCodes` in subsequent calls by this class and its descendants.
 
 @param statusCodes The status codes to be added to the set of acceptable HTTP status codes
 */
+ (void)addAcceptableStatusCodes:(NSIndexSet *)statusCodes;

/**
 Returns an `NSSet` object containing the acceptable MIME types. When non-`nil`, the operation will set the `error` property to an error in `AFErrorDomain`. See http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.17
 
 By default, this is `nil`.
 */
+ (NSSet *)acceptableContentTypes;

/**
 Adds content types to the set of acceptable MIME types returned by `+acceptableContentTypes` in subsequent calls by this class and its descendants.
 
 @param contentTypes The content types to be added to the set of acceptable MIME types
 */
+ (void)addAcceptableContentTypes:(NSSet *)contentTypes;


///-----------------------------------------------------
/// @name Determining Whether A Request Can Be Processed
///-----------------------------------------------------

/**
 A Boolean value determining whether or not the class can process the specified request. For example, `AFJSONRequestOperation` may check to make sure the content type was `application/json` or the URL path extension was `.json`.
 
 @param urlRequest The request that is determined to be supported or not supported for this class.
 */
+ (BOOL)canProcessRequest:(NSURLRequest *)urlRequest;

///-----------------------------------------------------------
/// @name Setting Completion Block Success / Failure Callbacks
///-----------------------------------------------------------

/**
 Sets the `completionBlock` property with a block that executes either the specified success or failure block, depending on the state of the request on completion. If `error` returns a value, which can be caused by an unacceptable status code or content type, then `failure` is executed. Otherwise, `success` is executed.
 
 @param success The block to be executed on the completion of a successful request. This block has no return value and takes two arguments: the receiver operation and the object constructed from the response data of the request.
 @param failure The block to be executed on the completion of an unsuccessful request. This block has no return value and takes two arguments: the receiver operation and the error that occurred during the request.
 
 @discussion This method should be overridden in subclasses in order to specify the response object passed into the success block.
 */
- (void)setCompletionBlockWithSuccess:(void (^)(HTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(HTTPRequestOperation *operation, NSError *error))failure;

@end

///----------------
/// @name Functions
///----------------

/**
 Returns a set of MIME types detected in an HTTP `Accept` or `Content-Type` header.
 */
extern NSSet * ContentTypesFromHTTPHeader(NSString *string);