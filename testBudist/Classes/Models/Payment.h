//
//  Payment.h
//  iSeller
//
//  Created by Чина on 24.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "Model.h"
#import "Advertisement.h"
@interface Payment : Model

@property(nonatomic, strong) NSNumber* identifier;
@property(nonatomic, strong) NSString* createdAt;
@property(nonatomic, strong) NSNumber* amount;
@property(nonatomic, strong) NSDictionary* data;




+(void)postReceipt:(NSString*)receipt success:(SuccessBlock)_success failure:(FailureBlock)_failure;
+(void)checkPaymentWithIdentifier:(NSNumber*)identifier success:(SuccessBlock)_success failure:(FailureBlock)_failure;
+(void)getPaymentsWithIdentifier:(NSString*)identifier success:(SuccessBlock)_success failure:(FailureBlock)_failure;

@end
