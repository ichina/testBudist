//
//  KIMutableURLRequest.h
//  iSeller
//
//  Created by Paul Semionov on 15.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MultipartBodyStream.h"

@interface KIMutableURLRequest : NSMutableURLRequest

@property (readwrite, nonatomic, strong) MultipartBodyStream *initialBodyStream;

- (id)copyWithZone:(NSZone *)zone;

@end
