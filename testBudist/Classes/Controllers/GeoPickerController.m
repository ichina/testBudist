//
//  GeoPickerController.m
//  iSeller
//
//  Created by Paul Semionov on 04.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "GeoPickerController.h"

#import "LocationManager.h"

#import <MBProgressHUD.h>

@interface GeoPickerController ()

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

@property (nonatomic, assign) CLLocationCoordinate2D coordinates;

@end

@implementation GeoPickerController

@synthesize delegate;

@synthesize coordinates;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    self.mapView.delegate = nil;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
            
    [self.mapView setDelegate:self];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
    [longPress setNumberOfTouchesRequired:1];
    [longPress setMinimumPressDuration:0.1];
    
    [self.mapView addGestureRecognizer:longPress];
    
    [[LocationManager sharedManager] getLocationWithSuccess:^(CLLocation *location) {
        
        [self zoomToRegionWithCoordinate:location.coordinate span:MKCoordinateSpanMake(0.01, 0.018) andUserDecidesSpan:NO];
        
    } failure:^(NSError *error) {
        
        NSLog(@"Error: %@", [error localizedDescription]);
        
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)longPressGesture:(UILongPressGestureRecognizer *)longPressGesture {
        
    if(longPressGesture.state == UIGestureRecognizerStateBegan) {
        
        [self.mapView.annotations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            if(![obj isKindOfClass:[MKUserLocation class]]) {
                
                [(AnnotationView *)[self.mapView viewForAnnotation:obj] hideCallout:[NSNotification notificationWithName:@"asd" object:nil]];
                [self.mapView removeAnnotation:obj];
                
            }
            
        }];
        
        if(self.mapView.annotations.count < 2) {
            
            CLLocationCoordinate2D tapCoordiante = [self.mapView convertPoint:[longPressGesture locationInView:self.mapView] toCoordinateFromView:self.mapView];
            
            Annotation *annotation = [[Annotation alloc] init];
            [annotation setCoordinate:tapCoordiante];
            [annotation setTitle:@" "];
            [annotation setIsDisplayLocation:YES];
            
            [self.mapView addAnnotation:annotation];
            
            self.coordinates = annotation.coordinate;
        }
        
    }
    
}

- (void)annotationView:(AnnotationView *)annotationView willShowCallout:(CalloutView *)calloutView {
    
    CGRect mapRect = [self.mapView convertRegion:self.mapView.region toRectToView:annotationView];
    
    if(!CGRectContainsRect(mapRect, calloutView.frame)) {
        
        [self.mapView setCenterCoordinate:[(Annotation *)[annotationView annotation] coordinate] animated:YES];
        
    }
    
}

#pragma mark --
#pragma mark Map methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if (annotation == mapView.userLocation) {
        
        mapView.userLocation.title = @"";
        
        return nil;
    }
    static NSString* customAnnotationIdentifier = @"customAnnotationIdentifier";
    
    AnnotationView* annotationView = (AnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:customAnnotationIdentifier];
    
    if (!annotationView) {
        annotationView = [[AnnotationView alloc] initWithAnnotation:annotation
                                                    reuseIdentifier:customAnnotationIdentifier];
        
        annotationView.image = [UIImage imageNamed:@"on_map_pin.png"];
        
        annotationView.centerOffset = CGPointMake(0, -annotationView.frame.size.height/2);
        
        [annotationView setDelegate:self];
                
    }
        
    return annotationView;
    
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    MKAnnotationView *aV;
    
    for (aV in views) {
        
        // Don't pin drop if annotation is user location
        if ([aV.annotation isKindOfClass:[MKUserLocation class]]) {
            continue;
        }
        
        // Check if current annotation is inside visible map rect, else go to next one
        MKMapPoint point =  MKMapPointForCoordinate(aV.annotation.coordinate);
        if (!MKMapRectContainsPoint(self.mapView.visibleMapRect, point)) {
            continue;
        }
        
        CGRect endFrame = aV.frame;
        
        //endFrame.origin.y -= endFrame.size.height/2;
        
        // Move annotation out of view
        aV.frame = CGRectMake(aV.frame.origin.x, aV.frame.origin.y - self.view.frame.size.height, aV.frame.size.width, aV.frame.size.height);
        
        // Animate drop
        [UIView animateWithDuration:0.5 delay:0.04*[views indexOfObject:aV] options:UIViewAnimationCurveLinear animations:^{
            
            aV.frame = endFrame;
            
            // Animate squash
        }completion:^(BOOL finished){
            if (finished) {
                [UIView animateWithDuration:0.05 animations:^{
                    aV.transform = CGAffineTransformMakeScale(1.0, 0.8);
                    
                }completion:^(BOOL finished){
                    [UIView animateWithDuration:0.1 animations:^{
                        aV.transform = CGAffineTransformIdentity;
                    }];
                }];
            }
        }];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    
    [self.mapView.annotations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if(![obj isKindOfClass:[MKUserLocation class]]) {
            
            [(AnnotationView *)[self.mapView viewForAnnotation:obj] setDragState:newState animated:YES];
            
        }
        
    }];
    
}

#pragma mark --

- (void)zoomToRegionWithCoordinate:(CLLocationCoordinate2D)coordinate span:(MKCoordinateSpan)span andUserDecidesSpan:(BOOL)userSpan {
    MKCoordinateRegion region;
    region.center = coordinate;
    region.span = span;
    
    [self.mapView setRegion:region animated:YES];
}

- (MKMapRect)mapRectForRect:(CGRect)rect fromView:(UIView *)canvasView
{
    CLLocationCoordinate2D topleft = [self.mapView convertPoint:CGPointMake(rect.origin.x, rect.origin.y) toCoordinateFromView:canvasView];
    CLLocationCoordinate2D bottomeright = [self.mapView convertPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect)) toCoordinateFromView:canvasView];
    MKMapPoint topleftpoint = MKMapPointForCoordinate(topleft);
    MKMapPoint bottomrightpoint = MKMapPointForCoordinate(bottomeright);
    
    return MKMapRectMake(topleftpoint.x, topleftpoint.y, bottomrightpoint.x - topleftpoint.x, bottomrightpoint.y - topleftpoint.y);
}

#pragma mark --

- (IBAction)cancelButtonPressed:(id)sender {
        
    [self.delegate geoPickerWantsToDismissWithCancel];
    
}

- (IBAction)doneButtonPressed:(id)sender {
    
    [sender setEnabled:NO];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setSquare:YES];
    [hud setMinSize:CGSizeMake(126, 126)];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = NSLocalizedString(@"Geocoding...", nil);
    
    if(!self.coordinates.latitude && !self.coordinates.longitude)
        self.coordinates = self.mapView.userLocation.coordinate;
    [[LocationManager sharedManager] placemarkFromLocation:self.coordinates completion:^(CLPlacemark *placemark, NSError *error) {
        
        if(error) {
            
            hud.mode = MBProgressHUDModeCustomView;
            hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
            hud.labelText = NSLocalizedString(@"Failed", nil);
            
            [hud hide:YES afterDelay:2];
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
            
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [self.delegate geoPickerWantsToDismissWithPlacemark:nil];

            });
            
        }else{
            
            hud.mode = MBProgressHUDModeCustomView;
            hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"success.png"]];
            hud.labelText = NSLocalizedString(@"Success", nil);
            
            [hud hide:YES afterDelay:2];
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
            
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [self.delegate geoPickerWantsToDismissWithPlacemark:placemark];
                
            });
                        
        }
        
        [sender setEnabled:YES];
        
    }];
        
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end
