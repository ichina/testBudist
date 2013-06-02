//
//  ErrorHandler.m
//  iSeller
//
//  Created by Chingis Gomboev on 13.02.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "ErrorHandler.h"

#import "NSString+Extensions.h"

@implementation ErrorHandler

#pragma mark Singleton methods

static ErrorHandler *instance_;

+ (ErrorHandler *)sharedHandler {
    @synchronized(self) {
        if( instance_ == nil ) {
            instance_ = [[self alloc] init];
        }
    }
    
    return instance_;
}

- (id)init {
    self = [super init];
    instance_ = self;
    
    return self;
}

- (NSString *)handleError:(NSError *)error {
    
    NSString *errorMsg = @"";
    
    switch (error.code) {
        case 422:  {
                errorMsg = [NSString stringWithFormat:@"%@ %@", [[[error.userInfo[kErrorObject] allKeys] lastObject] capitalizedString], [[[error.userInfo[kErrorObject] allValues] lastObject] lastObject]];
            
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:errorMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                if(alert.message && ![alert.message isEqualToString:@""]) {
                    
                    [alert show];
                }
            
        }
            break;
        case 409:
                errorMsg = @"Хватит это терпеть!";
            break;
        case 401:
            {
                NSHTTPURLResponse *response = (NSHTTPURLResponse *)[error.userInfo valueForKey:@"AFNetworkingOperationFailingURLResponseErrorKey"];
                
                NSLog(@"Status code: %i", response.statusCode);
                
                errorMsg = @"Ах ты неавторизован??!!";
                //блять, короче надо кудато эту строку присунуть))
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CHINAS_NOTIFICATION_NEED_TO_PRESENT_AUTH_CONTROLLER" object:self];
        }
            break;
        case -1021: {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            if(alert.message && ![alert.message isEqualToString:@""]) {
                
                [alert show];
            }
            
        }
            break;
        case -1009: {
            
            NSLog(@"Error: %@", [error localizedDescription]);
            
            //CGAlertView *alert = [[CGAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            //[alert show];
            
        }
            break;
        case -10001:
        {
            [[[UIAlertView alloc] initWithTitle:error.domain message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
            break;
        default: {
            
            errorMsg = @"Неизвестная ошибка";
            
        }
            break;
    }
    
    return errorMsg;    
}

@end
