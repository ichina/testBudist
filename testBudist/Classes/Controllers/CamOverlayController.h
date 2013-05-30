//
//  CamOverlayController.h
//  iSeller
//
//  Created by Чина on 21.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVCamCaptureManager.h"

@class AVCamPreviewView, AVCaptureVideoPreviewLayer;
@protocol CamOverlayDelegate;

@interface CamOverlayController : UIViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate>
{
    UIImageView* focusView;
    UIImageView* bannerView;
    BOOL isStatic;
    BOOL isHaveCamera;
    BOOL pickerDidDismissed;
}

@property (nonatomic,strong) id <CamOverlayDelegate> delegate;
@property (nonatomic,strong) AVCamCaptureManager *captureManager;
@property (nonatomic,weak) IBOutlet UIView *videoPreviewView;
@property (nonatomic,weak) IBOutlet UIButton* stillButton;
@property (nonatomic,weak) IBOutlet UIButton *cameraToggleButton;
@property (nonatomic,weak) IBOutlet UIButton *retakeButton;
@property (nonatomic,weak) IBOutlet UIButton *switchToLibButton;
@property (weak, nonatomic) IBOutlet UIButton *flashModeBtn;
@property (nonatomic,weak) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *capturedImageView;
@property (weak, nonatomic) IBOutlet UIButton *exitBtn;

@property (nonatomic,strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

@property (nonatomic,strong) UIImage* image;
@property (nonatomic,assign) AVCaptureVideoOrientation orientation;

@property (nonatomic) int index;
@property (nonatomic) AVCaptureFlashMode flashMode;

- (IBAction)captureStillImage:(id)sender;
- (IBAction)toggleCamera:(id)sender;
- (IBAction)retakePhoto:(id)sender;
- (IBAction)switchToLibrary:(id)sender;
- (IBAction)exit:(id)sender;
- (IBAction)flashStateChange:(id)sender;

@end

@protocol CamOverlayDelegate <NSObject>
@optional
- (void)imagePickerController:(CamOverlayController *)picker didFinishPickingMediaWithInfo:(NSMutableDictionary *)info;
- (void)imagePickerControllerDidCancel:(CamOverlayController *)picker;
@end