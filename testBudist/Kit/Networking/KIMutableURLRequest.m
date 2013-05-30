//
//  KIMutableURLRequest.m
//  iSeller
//
//  Created by Paul Semionov on 15.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "KIMutableURLRequest.h"

@implementation KIMutableURLRequest

@synthesize initialBodyStream;

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    
    KIMutableURLRequest *requestCopy = [[[self class] allocWithZone:zone] initWithURL:self.URL cachePolicy:self.cachePolicy timeoutInterval:self.timeoutInterval];
        
    requestCopy.initialBodyStream = self.initialBodyStream;
    
    requestCopy.HTTPMethod = [self.HTTPMethod copyWithZone:zone];
    
    requestCopy.HTTPBodyStream = self.HTTPBodyStream;
    
    requestCopy.HTTPBody = self.HTTPBody;

    requestCopy.HTTPShouldHandleCookies = self.HTTPShouldHandleCookies;

    requestCopy.HTTPShouldUsePipelining = self.HTTPShouldUsePipelining;
    
    requestCopy.HTTPBodyStream = self.HTTPBodyStream;
    
    return requestCopy;
}

@end
