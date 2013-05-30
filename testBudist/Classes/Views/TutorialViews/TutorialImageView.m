//
//  TutorialImageView.m
//  iSeller
//
//  Created by Чингис on 26.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "TutorialImageView.h"
#import "UIImage+scale.h"
@implementation TutorialImageView

-(void)setTutorialImage:(UIImage *)image
{
    UIImage* maskImage = [self imageWithGradient:image forMirrow:NO];
    //self.image = maskImage;
    self.image = [self maskImage:[image roundTopCornerImageWithRadius:(IS_RETINA)?9:5] withMask:maskImage];
}

-(void)setTutorialImage:(UIImage *)image withGradientToTopOffset:(float)yOffset
{
    UIImage* maskImage = [self imageWithGradientToTop:image withOffset:yOffset];
    //self.image = maskImage;
    self.image = [self maskImage:[image roundTopCornerImageWithRadius:(IS_RETINA)?9:5] withMask:maskImage];
}

-(void)setMirrorImage:(UIImage*)image
{
    UIImage* maskImage = [self imageWithGradient:image forMirrow:YES];
    //self.image = maskImage;
    UIImage* tutImage = [self maskImage:image withMask:maskImage];
    self.image = [self imageForMirror:tutImage];;
}

- (UIImage *)imageWithGradient:(UIImage *)img forMirrow:(BOOL) forMirrow {
    UIGraphicsBeginImageContextWithOptions(img.size, NO, img.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();

    
    
    CGFloat comps[] = { (forMirrow?1.0f:0.8f), (forMirrow?1.0f:0.8f), (forMirrow?1.0f:0.8f), 1.0f, (forMirrow?0.6f:0.0f), (forMirrow?0.6f:0.0f), (forMirrow?0.6f:0.0f), 1.0f};
    
    CGFloat locs[] = {!forMirrow,forMirrow};

    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGGradientRef g = CGGradientCreateWithColorComponents(space, comps, locs, 2);
    
    // Apply gradient
    CGContextDrawLinearGradient(context, g, CGPointMake(0,(forMirrow? img.size.height*8/9 : img.size.height/2)), CGPointMake(0, img.size.height), 1);
    
    
    UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGGradientRelease(g);
    CGColorSpaceRelease(space);
    
    return gradientImage;
}


- (UIImage *)imageWithGradientToTop:(UIImage *)img withOffset:(float) offset {
    UIGraphicsBeginImageContextWithOptions(img.size, NO, img.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    
    CGFloat comps[] = { 1.0f, 1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f};
    
    CGFloat locs[] = {0,1};
    
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGGradientRef g = CGGradientCreateWithColorComponents(space, comps, locs, 2);
    
    // Apply gradient
    CGContextDrawLinearGradient(context, g, CGPointMake(0,offset), CGPointMake(0, offset+img.size.height/3), 1);
    
    UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGGradientRelease(g);
    CGColorSpaceRelease(space);
    
    return gradientImage;
}

- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
    CGImageRef maskRef = maskImage.CGImage;
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef maskedImageRef = CGImageCreateWithMask(image.CGImage, mask);
    UIImage *maskedImage = [UIImage imageWithCGImage:maskedImageRef];
    
    CGImageRelease(mask);
    CGImageRelease(maskedImageRef);
    
    // returns new image with mask applied
    return maskedImage;
}

-(UIImage*)imageForMirror:(UIImage*) image
{
    return [UIImage imageWithCGImage:[image CGImage] scale:image.scale orientation:UIImageOrientationDownMirrored];
}

@end
