//
//  ValueSplitter.h
//  iSeller
//
//  Created by Chingis Gomboev on 17.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Model.h"

@interface ContentMapper : NSObject

+ (NSDictionary *)dictionaryWithProperties:(NSDictionary *)_properties andContent:(NSDictionary *)_content;

@end
