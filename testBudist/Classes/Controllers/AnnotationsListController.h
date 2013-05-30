//
//  AnnotationsListController.h
//  iSeller
//
//  Created by Paul Semionov on 08.04.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "BaseController.h"

#import "Advertisement.h"

@interface AnnotationsListController : BaseController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) NSMutableArray *annotations;

@end
