//
//  HTTPBodyPart.m
//  iSeller
//
//  Created by Paul Semionov on 15.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "HTTPBodyPart.h"

typedef enum {
    AFEncapsulationBoundaryPhase = 1,
    AFHeaderPhase                = 2,
    AFBodyPhase                  = 3,
    AFFinalBoundaryPhase         = 4,
} AFHTTPBodyPartReadPhase;

@interface HTTPBodyPart () <NSCopying> {
    AFHTTPBodyPartReadPhase _phase;
    NSInputStream *_inputStream;
    unsigned long long _phaseReadOffset;
}

- (BOOL)transitionToNextPhase;

@end

@implementation HTTPBodyPart
@synthesize stringEncoding = _stringEncoding;
@synthesize headers = _headers;
@synthesize bodyContentLength = _bodyContentLength;
@synthesize inputData = _inputData;
@synthesize inputURL = _inputURL;
@synthesize hasInitialBoundary = _hasInitialBoundary;
@synthesize hasFinalBoundary = _hasFinalBoundary;

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    [self transitionToNextPhase];
    
    return self;
}

- (void)dealloc {
    if (_inputStream) {
        [_inputStream close];
        _inputStream = nil;
    }
}

- (NSInputStream *)inputStream {
    if (_inputStream) {
        return _inputStream;
    }
    
    if (self.inputData) {
        _inputStream = [NSInputStream inputStreamWithData:self.inputData];
    } else if (self.inputURL) {
        _inputStream = [NSInputStream inputStreamWithURL:self.inputURL];
    }
    
    return _inputStream;
}

- (NSString *)stringForHeaders {
    NSMutableString *headerString = [NSMutableString string];
    for (NSString *field in [self.headers allKeys]) {
        [headerString appendString:[NSString stringWithFormat:@"%@: %@%@", field, [self.headers valueForKey:field], kAFMultipartFormCRLF]];
    }
    [headerString appendString:kAFMultipartFormCRLF];
    
    return [NSString stringWithString:headerString];
}

- (unsigned long long)contentLength {
    unsigned long long length = 0;
    
    NSData *encapsulationBoundaryData = [([self hasInitialBoundary] ? AFMultipartFormInitialBoundary() : AFMultipartFormEncapsulationBoundary()) dataUsingEncoding:self.stringEncoding];
    length += [encapsulationBoundaryData length];
    
    NSData *headersData = [[self stringForHeaders] dataUsingEncoding:self.stringEncoding];
    length += [headersData length];
    
    length += _bodyContentLength;
    
    NSData *closingBoundaryData = ([self hasFinalBoundary] ? [AFMultipartFormFinalBoundary() dataUsingEncoding:self.stringEncoding] : [NSData data]);
    length += [closingBoundaryData length];
    
    return length;
}

- (BOOL)hasBytesAvailable {
    // Allows `read:maxLength:` to be called again if `AFMultipartFormFinalBoundary` doesn't fit into the avaiable buffer
    if (_phase == AFFinalBoundaryPhase) {
        return YES;
    }
    
    switch (self.inputStream.streamStatus) {
        case NSStreamStatusNotOpen:
        case NSStreamStatusOpening:
        case NSStreamStatusOpen:
        case NSStreamStatusReading:
        case NSStreamStatusWriting:
            return YES;
        case NSStreamStatusAtEnd:
        case NSStreamStatusClosed:
        case NSStreamStatusError:
            return NO;
    }
}

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)length {
    NSInteger bytesRead = 0;
    
    if (_phase == AFEncapsulationBoundaryPhase) {
        NSData *encapsulationBoundaryData = [([self hasInitialBoundary] ? AFMultipartFormInitialBoundary() : AFMultipartFormEncapsulationBoundary()) dataUsingEncoding:self.stringEncoding];
        bytesRead += [self readData:encapsulationBoundaryData intoBuffer:&buffer[bytesRead] maxLength:(length - (NSUInteger)bytesRead)];
    }
    
    if (_phase == AFHeaderPhase) {
        NSData *headersData = [[self stringForHeaders] dataUsingEncoding:self.stringEncoding];
        bytesRead += [self readData:headersData intoBuffer:&buffer[bytesRead] maxLength:(length - (NSUInteger)bytesRead)];
    }
    
    if (_phase == AFBodyPhase) {
        if ([self.inputStream hasBytesAvailable]) {
            bytesRead += [self.inputStream read:&buffer[bytesRead] maxLength:(length - (NSUInteger)bytesRead)];
        }
        
        if (![self.inputStream hasBytesAvailable]) {
            [self transitionToNextPhase];
        }
    }
    
    if (_phase == AFFinalBoundaryPhase) {
        NSData *closingBoundaryData = ([self hasFinalBoundary] ? [AFMultipartFormFinalBoundary() dataUsingEncoding:self.stringEncoding] : [NSData data]);
        bytesRead += [self readData:closingBoundaryData intoBuffer:&buffer[bytesRead] maxLength:(length - (NSUInteger)bytesRead)];
    }
    
    return bytesRead;
}

- (NSInteger)readData:(NSData *)data
           intoBuffer:(uint8_t *)buffer
            maxLength:(NSUInteger)length
{
    NSRange range = NSMakeRange((NSUInteger)_phaseReadOffset, MIN([data length] - ((NSUInteger)_phaseReadOffset), length));
    [data getBytes:buffer range:range];
    
    _phaseReadOffset += range.length;
    
    if (((NSUInteger)_phaseReadOffset) >= [data length]) {
        [self transitionToNextPhase];
    }
    
    return (NSInteger)range.length;
}

- (BOOL)transitionToNextPhase {
    if (![[NSThread currentThread] isMainThread]) {
        [self performSelectorOnMainThread:@selector(transitionToNextPhase) withObject:nil waitUntilDone:YES];
        return YES;
    }
    
    switch (_phase) {
        case AFEncapsulationBoundaryPhase:
            _phase = AFHeaderPhase;
            break;
        case AFHeaderPhase:
            [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
            [self.inputStream open];
            _phase = AFBodyPhase;
            break;
        case AFBodyPhase:
            [self.inputStream close];
            _phase = AFFinalBoundaryPhase;
            break;
        case AFFinalBoundaryPhase:
        default:
            _phase = AFEncapsulationBoundaryPhase;
            break;
    }
    _phaseReadOffset = 0;
    
    return YES;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    HTTPBodyPart *bodyPartCopy = [[[self class] allocWithZone:zone] init];
    
    bodyPartCopy.stringEncoding = self.stringEncoding;
    bodyPartCopy.headers = self.headers;
    bodyPartCopy.bodyContentLength = self.bodyContentLength;
    bodyPartCopy.inputData = self.inputData;
    bodyPartCopy.inputURL = self.inputURL;
    
    return bodyPartCopy;
}

@end
