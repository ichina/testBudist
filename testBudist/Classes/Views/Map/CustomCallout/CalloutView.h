//
//  CalloutView.h
//  iSeller
//
//  Created by Paul Semionov on 25.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalloutView : UIView

@property (nonatomic, retain) IBOutlet UIImageView *image;
@property (nonatomic, retain) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UILabel *distance;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityView;

@end
