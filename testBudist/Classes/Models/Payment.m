//
//  Payment.m
//  iSeller
//
//  Created by Чина on 24.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "Payment.h"
#import "Profile.h"
#import "CheckReceiptsBuilder.h"
#import "PaymentHistoryBuilder.h"
#import "PostReceiptsBuilder.h"

@implementation Payment
@synthesize identifier;
@synthesize amount;
@synthesize createdAt;
@synthesize data;


+ (NSMutableArray*)convertArray:(NSArray*)_array
{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:[(NSArray*)_array count]];
    
    for(NSDictionary* dict in _array)
    {
        Payment* payment = [[Payment alloc] initWithContents:dict];
        [array addObject:payment];
    }
    return array;
}

+(void)postReceipt:(NSString*)receipt success:(SuccessBlock)_success failure:(FailureBlock)_failure
{
    NSDictionary *parameters = @{
    @"payment[receipt_data]" : receipt,
    @"device" : @"ios",
    @"token": [Profile sharedProfile].token
    };
    
    KIMutableURLRequest* request = [PostReceiptsBuilder buildRequestWithParameters:parameters];
    
    [self executeRequest:request progress:nil success:^(id object) {
        
        [self checkPaymentWithIdentifier:object[@"id"] success:^(id object) {
            
            if(_success)
                _success(object);
            /*
            [[Profile sharedProfile] getBalanceWithSuccess:nil failure:^(NSError *error) {
                
                NSLog(@"Error, while retrieving balance: %@", [error localizedDescription]);
                
            }];
             */
            
        } failure:^(id object, NSError *error) {
            if (_failure)
                _failure(object, error);
        }];
        
    } failure:^(id object, NSError *error) {
        if (_failure)
            _failure(object, error);
    }];
    
}

+(void)checkPaymentWithIdentifier:(NSNumber*)identifier success:(SuccessBlock)_success failure:(FailureBlock)_failure
{
    NSDictionary *parameters = @{
    @"id" : [identifier stringValue],
    @"device" : @"ios",
    @"token" : [Profile sharedProfile].token
    };
    
    KIMutableURLRequest* request = [CheckReceiptsBuilder buildRequestWithParameters:parameters];
    
    [self executeRequest:request progress:nil success:^(id object) {
        
        if(_success)
            _success(object);
        
    } failure:^(id object, NSError *error) {
        if (_failure)
            _failure(object, error);
    }];
     
}

+(void)getPaymentsWithIdentifier:(NSString*)identifier success:(SuccessBlock)_success failure:(FailureBlock)_failure
{
    NSDictionary* parameters = @{
                                 @"token" : [Profile sharedProfile].token,
                                 @"before" : identifier 
                                 };
    
    KIMutableURLRequest* request = [PaymentHistoryBuilder buildRequestWithParameters:parameters];
    
    [self executeRequest:request progress:nil success:^(id object) {
        
        NSMutableArray* array = [self convertArray:object];
        
        if(_success)
            _success(array);
        
    } failure:^(id object, NSError *error) {
        if (_failure)
            _failure(object, error);
    }];
}

@end
