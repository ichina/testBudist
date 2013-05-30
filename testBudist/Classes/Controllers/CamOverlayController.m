//
//  CamOverlayController.m
//  iSeller
//
//  Created by Чина on 21.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "CamOverlayController.h"
#import "UIImage+scale.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import "UIView+Extensions.h"
#import "UIImage+scale.h"

#import "NSDate+Extensions.h"

#define FLASH_VIEW_TAG 80

static void *AVCamFocusModeObserverContext = &AVCamFocusModeObserverContext;

@interface CamOverlayController ()

@end
@interface CamOverlayController (InternalMethods)
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates;
- (void)tapToAutoFocus:(UIGestureRecognizer *)gestureRecognizer;
- (void)tapToContinouslyAutoFocus:(UIGestureRecognizer *)gestureRecognizer;
- (void)updateButtonStates;
@end

@interface CamOverlayController (AVCamCaptureManagerDelegate) <AVCamCaptureManagerDelegate>
@end

@implementation CamOverlayController

@synthesize captureManager = _captureManager;
@synthesize stillButton;
@synthesize videoPreviewView;
@synthesize cameraToggleButton;
@synthesize captureVideoPreviewLayer;
@synthesize image;
@synthesize orientation;
@synthesize index;
@synthesize flashMode;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.capturedImageView setFrame:CGRectMake(0,(IS_IPHONE5? 0: -44), 320, 568)];
    
    if(IS_IPHONE5)
    {
        [videoPreviewView setFrame:CGRectMake(0, 0, 320, 568)];
        [captureVideoPreviewLayer setFrame:CGRectMake(0, 0, 320, 568)];
        
        //[self.capturedImageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.bgImageView setFrame:CGRectMake(0, 0, 320, 568)];
        [self.bgImageView setImage:[[UIImage imageNamed:@"cam_back-2.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(385,0,100,0)]];
        bannerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera_panel_5iphoneWithHole.png"]];
        [bannerView setFrame:CGRectMake(0, CGRectGetMaxY(videoPreviewView.frame)-bannerView.image.size.height, 320, bannerView.image.size.height)];
        [self.switchToLibButton.superview bringSubviewToFront:self.switchToLibButton];
        [self.switchToLibButton setCenter:CGPointMake(self.switchToLibButton.center.x, CGRectGetMidY(bannerView.frame))];
        [self.bgImageView.superview addSubview:bannerView];
        [stillButton.superview bringSubviewToFront:stillButton];
        [stillButton setCenter:CGPointMake(stillButton.center.x, CGRectGetMidY(bannerView.frame))];
        [self.retakeButton setImage:[UIImage imageNamed:@"cam_retake_Iphone5@2x.png"] forState:UIControlStateNormal];
        CGPoint point = self.retakeButton.center;
        [self.retakeButton setFrame:CGRectMake(0, 0,self.retakeButton.imageView.image.size.width/2 , self.retakeButton.imageView.image.size.height/2)];
        [self.retakeButton setCenter:CGPointMake(point.x, CGRectGetMidY(bannerView.frame))];
        
    }
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(pickerDidDismissed)
    {
        [self exit:nil];
    }
    else if(!isHaveCamera)
       [self switchToLibrary:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    isHaveCamera = YES;
    if ([self captureManager] == nil) {
		AVCamCaptureManager *manager = [[AVCamCaptureManager alloc] init];
		[self setCaptureManager:manager];
		
		[[self captureManager] setDelegate:self];
        
		if ([[self captureManager] setupSession]) {
            // Create video preview layer and add it to the UI
			AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[[self captureManager] session]];
			UIView *view = [self videoPreviewView];
			CALayer *viewLayer = [view layer];
			[viewLayer setMasksToBounds:YES];
			
			CGRect bounds = [view bounds];
			[newCaptureVideoPreviewLayer setFrame:bounds];
			
			if ([newCaptureVideoPreviewLayer.connection isVideoOrientationSupported]) {
				[newCaptureVideoPreviewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
			}
			
			[newCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
			
			[viewLayer insertSublayer:newCaptureVideoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
			
			[self setCaptureVideoPreviewLayer:newCaptureVideoPreviewLayer];
            // Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				[[[self captureManager] session] startRunning];
			});
			self.flashMode = AVCaptureFlashModeAuto;
            [self updateButtonStates];
			
            // Add a single tap gesture to focus on the point tapped, then lock focus
			UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToAutoFocus:)];
			[singleTap setDelegate:self];
			[singleTap setNumberOfTapsRequired:1];
			[view addGestureRecognizer:singleTap];
			
            // Add a double tap gesture to reset the focus mode to continuous auto focus
			UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToContinouslyAutoFocus:)];
			[doubleTap setDelegate:self];
			[doubleTap setNumberOfTapsRequired:2];
			[singleTap requireGestureRecognizerToFail:doubleTap];
			[view addGestureRecognizer:doubleTap];
			}
	}
    focusView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"focusRect.png"] stretchableImageWithLeftCapWidth:25 topCapHeight:25]];
    [self getLastImageFromRoll];
    // Do any additional setup after loading the view.
    
}
-(void) getLastImageFromRoll
{
    
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        
        //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
        //                   ^{
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
        // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
        [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            
            // Within the group enumeration block, filter to enumerate just photos.
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            
            if([group numberOfAssets]>0)
                [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:([group numberOfAssets] - 1)] options:0 usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
                    
                    // The end of the enumeration is signaled by asset == nil.
                    if (alAsset) {
                        UIImage *latestPhoto = [UIImage imageWithCGImage:[alAsset thumbnail]];
                        
                        [self.switchToLibButton setImage:latestPhoto forState:UIControlStateNormal];
                       
                    }
                }];
        } failureBlock: ^(NSError *error) {
            // Typically you should handle an error more gracefully than this.
            NSLog(@"No groups");
        }];
        //                   });
        
    });
}

-(void)deviceNotHaveCamera
{
    isHaveCamera = NO;
    //[self switchToLibrary:nil];
}

#pragma mark Toolbar Actions
- (IBAction)toggleCamera:(id)sender
{
    [self flashStateChange:nil];
    // Toggle between cameras when there is more than one
    [[self captureManager] toggleCamera];
    
    static bool isFrontCam;
    isFrontCam = !isFrontCam;
    self.cameraToggleButton.tag = 40+(int)isFrontCam;
    
    // Do an initial focus
    [[self captureManager] continuousFocusAtPoint:CGPointMake(.5f, .5f)];
}

- (IBAction)retakePhoto:(id)sender {
    
    [self.capturedImageView setImage:nil];
    [self.retakeButton setHidden:YES];
    [self.bgImageView setImage:[[UIImage imageNamed:@"cam_back-2.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(375, 0, 105, 0)]];
    [self.stillButton setImage:[UIImage imageNamed:@"cam_take-photo.png"] forState:UIControlStateNormal];
    [bannerView setImage:[UIImage imageNamed:@"camera_panel_5iphoneWithHole.png"]];
    if(IS_IPHONE5)
        [self.retakeButton.superview insertSubview:self.retakeButton belowSubview:bannerView];
    [self.switchToLibButton setHidden:NO];
}

- (IBAction)captureStillImage:(id)sender
{
    
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Camera" withAction:@"Take photo button pressed" withLabel:[NSString stringWithFormat:@"(%@) %@", [[NSDate date] dateToUTCWithFormat:nil], [NSStringFromClass([self class]) substringToIndex:NSStringFromClass([self class]).length-10]] withValue:nil];
    
    if(self.retakeButton.hidden)
    {        
       
        [[self captureManager] captureStillImage];

//        [self.retakeButton setHidden:NO];
//        [self.bgImageView setImage:[[UIImage imageNamed:@"cam_back-1.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(375, 0, 105, 0)]];
//        [self.switchToLibButton setHidden:YES];
//        [self.stillButton setImage:[UIImage imageNamed:@"cam_done.png"] forState:UIControlStateNormal];
//        [bannerView setImage:[UIImage imageNamed:@"camera_panel_5iphone.png"]];
//        if(IS_IPHONE5)
//            [self.retakeButton.superview insertSubview:self.retakeButton aboveSubview:bannerView];
        
        
        
    }
    else
    {
        if(!image)
        {
            if(self.delegate && [self.delegate respondsToSelector:@selector(imagePickerControllerDidCancel:)])
                [self.delegate imagePickerControllerDidCancel:self];
            return;
        }
        float ratio = (image.size.width>image.size.height?image.size.height:image.size.width)/640;
        CGSize size = image.size;
        
        image = [image imageByScalingAndCroppingForSize:CGSizeMake(size.width/ratio, size.height/ratio)];
        //size = image.size;
        CGRect rect;
        
        switch (orientation) {
            case AVCaptureVideoOrientationPortrait:
                rect.origin = CGPointMake(20, 116+((!IS_IPHONE5)?44:0));
                break;
            case AVCaptureVideoOrientationPortraitUpsideDown:
                rect.origin = CGPointMake(20, self.view.frame.size.height-116-600);
                break;
            case AVCaptureVideoOrientationLandscapeLeft:
                rect.origin = CGPointMake(self.view.frame.size.height*(IS_RETINA?2:1)-116-600+((!IS_IPHONE5)?44:0), 20);
                break;
            case AVCaptureVideoOrientationLandscapeRight:
                rect.origin = CGPointMake(116, 20);
                break;
        }
        
        rect.size.width= 600;
        rect.size.height = 600;
        UIImage* editedImage = [image imageByScalingAndCroppingForRect:rect];
        NSMutableDictionary* dict = [@{@"x" : [[NSNumber numberWithFloat:rect.origin.x] stringValue], @"y" : [[NSNumber numberWithFloat:rect.origin.y] stringValue], @"side" : [[NSNumber numberWithFloat:rect.size.width] stringValue]} mutableCopy];
        [dict setObject:image forKey:IM_ATTR_ATTACHMENT];
        [dict setObject:editedImage forKey:@"editedImage"];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        [[NSNotificationCenter defaultCenter] removeObserver:self.captureManager];
        if(self.delegate && [self.delegate respondsToSelector:@selector(imagePickerController:didFinishPickingMediaWithInfo:)])
            [self.delegate imagePickerController:self didFinishPickingMediaWithInfo:dict];
    }
}

-(void)openImagepicker
{
    
}

- (IBAction)switchToLibrary:(id)sender {
    
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Camera" withAction:@"Photo Library button pressed" withLabel:[NSString stringWithFormat:@"(%@) %@", [[NSDate date] dateToUTCWithFormat:nil], [NSStringFromClass([self class]) substringToIndex:NSStringFromClass([self class]).length-10]] withValue:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[[self captureManager] session] stopRunning];
    });
    UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    [self presentViewController:imagePickerController animated:YES completion:NULL];
}

- (IBAction)exit:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self.captureManager];

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)flashStateChange:(id)sender {
    
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Camera" withAction:@"Flash state button pressed" withLabel:[NSString stringWithFormat:@"(%@) %@", [[NSDate date] dateToUTCWithFormat:nil], [NSStringFromClass([self class]) substringToIndex:NSStringFromClass([self class]).length-10]] withValue:nil];
    
    self.flashMode = [_captureManager changeFlashMode];
    NSString* imageName;
    switch (self.flashMode) {
        case AVCaptureFlashModeAuto:
            imageName = @"cam_flash-auto.png";
            break;
        case AVCaptureFlashModeOff:
            imageName = @"cam_flash-off.png";
            break;
        case AVCaptureFlashModeOn:
            imageName = @"cam_flash.png";
            break;
    }
    [self.flashModeBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

#pragma mark - UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    pickerDidDismissed = YES;
    
    UIImage* outputImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    CGRect rect = [info[@"UIImagePickerControllerCropRect"] CGRectValue];
    float ratio = outputImage.size.width/640;
    
    rect.origin.x /=ratio;
    rect.origin.y /=ratio;
    rect.size.width/=ratio;
    rect.size.height/=ratio;
    
    CGSize size = outputImage.size;
    
    outputImage = [outputImage imageByScalingAndCroppingForSize:CGSizeMake(size.width/ratio, size.height/ratio)];
    //size = outputImage.size;
    
    NSMutableDictionary* dict = [@{@"x" : [[NSNumber numberWithInt:rect.origin.x] stringValue], @"y" : [[NSNumber numberWithInt:rect.origin.y]stringValue ], @"side" : [[NSNumber numberWithInt:rect.size.width] stringValue]} mutableCopy];
    [dict setObject:outputImage forKey:IM_ATTR_ATTACHMENT];
    [dict setObject:[info objectForKey:UIImagePickerControllerEditedImage] forKey:@"editedImage"];
    
    if (outputImage) {
        [picker dismissModalViewControllerAnimated:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        [[NSNotificationCenter defaultCenter] removeObserver:self.captureManager];

        if(self.delegate && [self.delegate respondsToSelector:@selector(imagePickerController:didFinishPickingMediaWithInfo:)])
            [self.delegate imagePickerController:self didFinishPickingMediaWithInfo:dict];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    
    if(!isHaveCamera)
    {
        [self exit:nil];
        pickerDidDismissed = YES;
        //[self dismissModalViewControllerAnimated:NO];
        //[self dismissViewControllerAnimated:YES completion:nil];
        [self.delegate imagePickerControllerDidCancel:self];
        return;
    }
    if (isStatic) {
        // TODO: fix this hack
        [self dismissModalViewControllerAnimated:NO];
        [self.delegate imagePickerControllerDidCancel:self];
    } else {
        [self dismissModalViewControllerAnimated:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[[self captureManager] session] startRunning];
        });
        [self retakePhoto:nil];
    }
}

-(void)deviceOrientationDidChange:(AVCaptureVideoOrientation)_orientation
{
    float angle;
    switch (_orientation) {
        case AVCaptureVideoOrientationLandscapeLeft:
            angle = -M_PI/2;
            break;
        case AVCaptureVideoOrientationLandscapeRight:
            angle = M_PI/2;
            break;
        case AVCaptureVideoOrientationPortrait:
            angle = 0;
            break;
        case AVCaptureVideoOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        default:
            return;
            break;
    }
    //[UIView animateWithDuration:0.08 delay:0.0 options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse |UIViewAnimationOptionAllowUserInteraction) animations:^{
    [UIView animateWithDuration:0.3 delay:0.0 options:(UIViewAnimationCurveEaseInOut |UIViewAnimationOptionAllowUserInteraction) animations:^{
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
        //self.retakeButton.transform = transform;
        self.switchToLibButton.transform = transform;
        self.stillButton.transform = transform;
        self.flashModeBtn.transform = transform;
        self.cameraToggleButton.transform = transform;
        self.exitBtn.transform = transform;
    } completion:NULL];
}

- (void)viewDidUnload {
    [self setRetakeButton:nil];
    [self setSwitchToLibButton:nil];
    [self setBgImageView:nil];
    [self setFlashModeBtn:nil];
    [self setCapturedImageView:nil];
    [self setExitBtn:nil];
    [super viewDidUnload];
}
@end

@implementation CamOverlayController (InternalMethods)

// Convert from view coordinates to camera coordinates, where {0,0} represents the top left of the picture area, and {1,1} represents
// the bottom right in landscape mode with the home button on the right.
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
{
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = [[self videoPreviewView] frame].size;
    
    if ([captureVideoPreviewLayer.connection isVideoMirrored]) {
        viewCoordinates.x = frameSize.width - viewCoordinates.x;
    }
    
    if ( [[captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResize] ) {
		// Scale, switch x and y, and reverse x
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        for (AVCaptureInputPort *port in [[[self captureManager] videoInput] ports]) {
            if ([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if ( [[captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspect] ) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
						// If point is inside letterboxed area, do coordinate conversion; otherwise, don't change the default value returned (.5,.5)
                        if (point.x >= blackBar && point.x <= blackBar + x2) {
							// Scale (accounting for the letterboxing on the left and right of the video preview), switch x and y, and reverse x
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
						// If point is inside letterboxed area, do coordinate conversion. Otherwise, don't change the default value returned (.5,.5)
                        if (point.y >= blackBar && point.y <= blackBar + y2) {
							// Scale (accounting for the letterboxing on the top and bottom of the video preview), switch x and y, and reverse x
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                } else if ([[captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
					// Scale, switch x and y, and reverse x
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2; // Account for cropped height
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2); // Account for cropped width
                        xc = point.y / frameSize.height;
                    }
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}

// Auto focus at a particular point. The focus mode will change to locked once the auto focus happens.
- (void)tapToAutoFocus:(UIGestureRecognizer *)gestureRecognizer
{
    if ([[[_captureManager videoInput] device] isFocusPointOfInterestSupported]) {
        CGPoint tapPoint = [gestureRecognizer locationInView:[self videoPreviewView]];
        if(![self.switchToLibButton isHidden])
            [self drawHollyCrosshair:tapPoint];
        CGPoint convertedFocusPoint = [self convertToPointOfInterestFromViewCoordinates:tapPoint];
        [_captureManager autoFocusAtPoint:convertedFocusPoint];
    }
}

// Change to continuous auto focus. The camera will constantly focus at the point choosen.
- (void)tapToContinouslyAutoFocus:(UIGestureRecognizer *)gestureRecognizer
{
    if ([[[_captureManager videoInput] device] isFocusPointOfInterestSupported])
        [_captureManager continuousFocusAtPoint:CGPointMake(.5f, .5f)];
}
-(void) drawHollyCrosshair:(CGPoint) point
{
    if(!CGRectContainsPoint(CGRectMake(0, 58, 320, 320),point))
        return;
    
    focusView.alpha = 0.5f;
    
    [focusView setFrame:CGRectMake(0, 0, focusView.image.size.width*2, focusView.image.size.height*2)];
    [focusView setCenter:point];
    [[self videoPreviewView] addSubview:focusView];
    [UIView animateWithDuration:0.5f animations:^{
        [focusView setFrame:CGRectMake(focusView.frame.origin.x+focusView.image.size.width/2, focusView.frame.origin.y+focusView.image.size.height/2,focusView.image.size.width, focusView.image.size.width)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3f animations:^{
            focusView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [focusView removeFromSuperview];
        }];
    }];
}
// Update button states based on the number of available cameras and mics
- (void)updateButtonStates
{
    NSUInteger cameraCount = [[self captureManager] cameraCount];
    
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        if (cameraCount < 2) {
            [[self cameraToggleButton] setEnabled:NO];
            
            if (cameraCount < 1) {
                [[self stillButton] setEnabled:NO];
                
                
            } else {
                [[self stillButton] setEnabled:YES];
            }
        } else {
            [[self cameraToggleButton] setEnabled:YES];
            [[self stillButton] setEnabled:YES];
        }
    });
}

@end

@implementation CamOverlayController (AVCamCaptureManagerDelegate)

- (void)captureManager:(AVCamCaptureManager *)captureManager didFailWithError:(NSError *)error
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        CGAlertView *alertView = [[CGAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title")
                                                  otherButtonTitles:nil];
        [alertView show];
    });
    [self retakePhoto:nil];
}

- (void)captureManagerRecordingBegan:(AVCamCaptureManager *)captureManager
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        
    });
}

- (void)captureManagerRecordingFinished:(AVCamCaptureManager *)captureManager
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        
    });
}

- (void)captureManagerStillImageCaptured:(AVCamCaptureManager *)captureManager
{
    orientation = captureManager.statOrientation;
    
    image = [[UIImage alloc] initWithData:captureManager.captImg];
    //if(orientation==AVCaptureVideoOrientationLandscapeLeft || orientation ==AVCaptureVideoOrientationLandscapeRight)
    //NSLog(@"%d",self.cameraToggleButton.tag);
    
    if( orientation == 3 || orientation == 4)
    {
        [self.capturedImageView setImage:[image imageByRotatingImage:image fromImageOrientation:(orientation==4)?3:3]];
    }
    else
        [self.capturedImageView setImage:image];
    
    [self.capturedImageView setHidden:YES];    
    
    CGRect frame = [[self videoPreviewView] frame];
    frame.size.height+=20;
    
    UIView *flashView = [[UIView alloc] initWithFrame:frame];
    [flashView setBackgroundColor:[UIColor whiteColor]];
    
    [[[self view] window] addSubview:flashView];
    
    [self.retakeButton setHidden:NO];
    [self.bgImageView setImage:[[UIImage imageNamed:@"cam_back-1.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(375, 0, 105, 0)]];
    [self.switchToLibButton setHidden:YES];
    [self.stillButton setImage:[UIImage imageNamed:@"cam_done.png"] forState:UIControlStateNormal];
    [bannerView setImage:[UIImage imageNamed:@"camera_panel_5iphone.png"]];
    if(IS_IPHONE5)
        [self.retakeButton.superview insertSubview:self.retakeButton aboveSubview:bannerView];
    
    [UIView animateWithDuration:0.8f delay:0.0f options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.capturedImageView setHidden:NO];
                         [flashView setAlpha:0.f];
                     }
                     completion:^(BOOL finished){
                         [flashView removeFromSuperview];
                     }
     ];
    
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
    
    });
}


- (void)captureManagerDeviceConfigurationChanged:(AVCamCaptureManager *)captureManager
{
	[self updateButtonStates];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end