//
//  AnnotationCell.m
//  iSeller
//
//  Created by Paul Semionov on 08.04.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "AnnotationCell.h"

#import "PriceFormatter.h"

@implementation AnnotationCell

@synthesize titleOfAd, imageView, price;

- (void)setAdvertisementInfo:(Advertisement *)ad {
    self.titleOfAd.text = [ad title];
    self.price.text = [[PriceFormatter sharedFormatter] formatPrice:[[ad price] floatValue]];
    
    [self.imageView setImageWithURL:[NSURL URLWithString:ad.smallImage] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
}

@end
