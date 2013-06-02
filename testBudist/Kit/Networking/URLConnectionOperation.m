//
//  URLConnectionOperation.m
//  iSeller
//
//  Created by Paul Semenov on 15.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "URLConnectionOperation.h"

@implementation URLConnectionOperation

@synthesize bodyStream;

- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request {
    
    return [(NSInputStream *)self.bodyStream copy];
    
}

@end
