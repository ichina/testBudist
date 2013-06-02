//
//  URLConnectionOperation.h
//  iSeller
//
//  Created by Paul Semenov on 15.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "AFURLConnectionOperation.h"

#import "KIMutableURLRequest.h"

@interface URLConnectionOperation : AFURLConnectionOperation

@property (readwrite, nonatomic, strong) MultipartBodyStream *bodyStream;

@end
