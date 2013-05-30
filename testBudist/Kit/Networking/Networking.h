//
//  Networking.h
//  iSeller
//
//  Created by Paul Semionov on 15.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Availability.h>

#ifndef _AFNETWORKING_
#define _AFNETWORKING_

#import "AFURLConnectionOperation.h"

#import "AFHTTPRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "AFXMLRequestOperation.h"
#import "AFPropertyListRequestOperation.h"
#import "AFHTTPClient.h"

#import "AFImageRequestOperation.h"

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
#import "AFNetworkActivityIndicatorManager.h"
#import "UIImageView+AFNetworking.h"
#endif
#endif /* _AFNETWORKING_ */

#import "HTTPClient.h"

#import "HTTPRequestOperation.h"