//
//  ErrorHandler.h
//  iSeller
//
//  Created by Paul Semionov on 13.02.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kErrorObject @"ErrorObject"

@interface ErrorHandler : NSObject <CGAlertViewDelegate>

+ (ErrorHandler *)sharedHandler;

- (NSString *)handleError:(NSError *)error;

@end
