//
//  NavForModalController.m
//  iSeller
//
//  Created by Чингис on 05.04.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "NavForModalController.h"

@interface NavForModalController ()

@end

@implementation NavForModalController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate
{
    return NO;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation==UIInterfaceOrientationPortrait);
}
@end
