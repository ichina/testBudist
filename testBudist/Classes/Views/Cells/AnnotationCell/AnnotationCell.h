//
//  AnnotationCell.h
//  iSeller
//
//  Created by Paul Semionov on 08.04.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "CustomCellForSelecting.h"

#import "Advertisement.h"

@interface AnnotationCell : CustomCellForSelecting

@property (nonatomic, retain) IBOutlet UILabel *titleOfAd;
@property (nonatomic, retain) IBOutlet UILabel *price;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;

- (void)setAdvertisementInfo:(Advertisement *)ad;

@end
