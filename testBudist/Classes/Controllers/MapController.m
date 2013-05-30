//
//  MapViewController.m
//  iSeller
//
//  Created by Paul Semionov on 24.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "MapController.h"

#import "Advertisement.h"

#import "Annotation.h"

#import "PriceFormatter.h"

#import "LocationManager.h"

#import "AdvertisementController.h"

#import "AnnotationsListController.h"

#import "NSString+Extensions.h"

@interface MapController ()

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityView;

@property (nonatomic, retain) UISearchBar *searchBar;

@property (nonatomic, retain) NSMutableArray *adsArray;

@property (nonatomic, retain) NSMutableSet *mapAnnotationsIds;

@property (nonatomic, retain) NSTimer *swipeTimer;

@property (nonatomic, assign) BOOL *isSwiped;

- (IBAction)returnButtonPressed:(id)sender;

- (IBAction)searchButtonPressed:(id)sender;

- (IBAction)locationButtonPressed:(id)sender;

- (void)zoomToRegionWithCoordinate:(CLLocationCoordinate2D)coordinate span:(MKCoordinateSpan)span andUserDecidesSpan:(BOOL)userSpan;

@end

@implementation MapController

@synthesize mapView = _mapView;

@synthesize activityView = _activityView;

@synthesize adsArray;

@synthesize mapAnnotationsIds;

@synthesize swipeTimer;

@synthesize isSwiped;

@synthesize query = _query, priceFrom = _priceFrom, priceTo = _priceTo;

@synthesize isSearching;

@synthesize searchBar = _searchBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.tabBarController setHidden:YES animated:YES];
    
    if(self.isSearching) {
        
    }
    
    self.mapView.delegate = self;
    
    if(self.mapView.annotations.count == 0) {
        return;
    }
                
    for(Annotation *annotation in self.mapView.selectedAnnotations) {
                
        [self.mapView deselectAnnotation:annotation animated:NO];
        
    }
        
    for(Annotation *annotation in self.mapView.annotations) {
        
        for(UIView *subview in [[self.mapView viewForAnnotation:annotation] subviews]) {
            
            if([subview isKindOfClass:[CalloutView class]]) {
                
                [self.mapView selectAnnotation:annotation animated:NO];
                
                break;
                
            }
            
        }
        
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if(self.isSearching) {
        
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        
    }
    
    self.mapView.delegate = nil;
    
}

- (void)viewDidLoad
{
    
    self.skipAuth = YES;
    
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    
    self.isSwiped = NO;
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    
    [self.searchBar setDelegate:self];
    
    [self.mapView addSubview:self.searchBar];
    
    if(self.isSearching) {
        
        [self.searchBar setText:self.query];
        
        [self.searchBar setShowsCancelButton:YES animated:YES];
        
    }
        
    self.isSearching = YES;
    
    for(UIView *subview in self.searchBar.subviews){
        
        if([subview isKindOfClass:UIButton.class]){
            
            [(UIButton*)subview setEnabled:YES];
            
        }
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapTapGesture:)];
    [tapGesture setNumberOfTapsRequired:1];
    [self.mapView addGestureRecognizer:tapGesture];
    
    self.adsArray = [NSMutableArray array];
    
    self.mapAnnotationsIds = [NSMutableSet set];
    
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

- (BOOL)canBecomeFirstResponder {
    
    return YES;
    
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
    if(motion == UIEventSubtypeMotionShake) {
        
        NSLog(@"Visible annotations count: %i", [self.mapView annotationsInMapRect:self.mapView.visibleMapRect].count);
        
    }
    
}

#pragma mark --
#pragma mark IBActions

- (IBAction)searchButtonPressed:(id)sender {
    
}

- (IBAction)locationButtonPressed:(id)sender {
            
    [self zoomToRegionWithCoordinate:self.mapView.userLocation.coordinate span:MKCoordinateSpanMake(0.01, 0.018) andUserDecidesSpan:NO];
    
}

- (IBAction)returnButtonPressed:(id)sender {
    
    //[self.navigationController popViewControllerAnimated:YES];
    
    if(self.query.length > 0) {
        
        [[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] indexOfObject:self] - 1] setValue:self.query forKeyPath:@"adDataSource.query"];
        
    }
    
    [UIView
     transitionWithView:self.navigationController.view
     duration:0.8f
     options:UIViewAnimationOptionTransitionFlipFromRight
     animations:^{
         
         [self.navigationController popViewControllerAnimated:NO];
         
     }
     completion:NULL];
}

#pragma mark --
#pragma mark CCLocation delegate methods



#pragma mark --
#pragma mark Map delegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)_annotation
{
    if (_annotation == mapView.userLocation) {
        
        mapView.userLocation.title = @"";
        
        return nil;
    }
    
    Annotation *annotation = _annotation;
    
    AnnotationView* annotationView = (AnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"AnnotationView"];
    
    if (!annotationView) {
        
        annotationView = [[AnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"AnnotationView"];
        
    }
    
    annotationView.image = [UIImage imageNamed:@"on_map_pin.png"];
    
    annotationView.centerOffset = CGPointMake(0, -annotationView.frame.size.height/2);
    
    [annotationView setDelegate:self];
    
    if(annotationView.alpha == 0) {
        
        [annotationView setAlpha:1.0];
        
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    
    [self.swipeTimer invalidate];
    
    self.swipeTimer = nil;
        
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    self.swipeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick) userInfo:nil repeats:NO];
}

- (void)timerTick {

    [self makeRequestWithQuery:self.query priceTo:self.priceTo priceFrom:self.priceFrom];
    
}

- (void)makeRequestWithQuery:(NSString *)query priceTo:(NSString *)priceTo priceFrom:(NSString *)priceFrom {
    
    [self.activityView setHidden:NO];
    
    // Получаем противоположные углы экрана (левый верхний и правый нижний).
        
    MKMapRect mRect = self.mapView.visibleMapRect;
    MKMapPoint pointOne = MKMapPointMake(mRect.origin.x, mRect.origin.y);
    MKMapPoint pointTwo = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMaxY(mRect));
    CLLocationCoordinate2D upperLeft = MKCoordinateForMapPoint(pointOne);
    CLLocationCoordinate2D lowerRight = MKCoordinateForMapPoint(pointTwo);
    
    NSString *viewPort = [NSString stringWithFormat:@"%f,%f,%f,%f", upperLeft.latitude, upperLeft.longitude, lowerRight.latitude, lowerRight.longitude];
    
    [Advertisement searchMapWithViewPort:viewPort query:query priceFrom:priceFrom andPriceTo:priceTo success:^(NSArray *ads) {
        
        NSMutableArray *annotations = [NSMutableArray array];
        
        self.adsArray = [NSMutableArray arrayWithArray:ads];
        
        for (Advertisement *ad in ads) {
                        
            NSMutableArray *annotationsIds = [NSMutableArray array];
            
            for(Annotation *annotationObj in [self.mapView annotationsInMapRect:self.mapView.visibleMapRect]) {
                
                if(![annotationObj isKindOfClass:[MKUserLocation class]]) {
                    
                    [annotationsIds addObject:annotationObj.tag];
                    
                }
            }
            
            if(![annotationsIds containsObject:[ad.identifier stringValue]] && annotationsIds.count < 11) {
                
                Annotation *annotation = [[Annotation alloc] initWithCoordinate:CLLocationCoordinate2DMake([[[ad.location componentsSeparatedByString:@","] objectAtIndex:0] doubleValue], [[[ad.location componentsSeparatedByString:@","] lastObject] doubleValue])];
                annotation.title = ad.title;
                annotation.tag = [ad.identifier stringValue];
                annotation.ad = ad;
                // Получаем видимые точки на карте.
                    
                [annotations addObject:annotation];
                
            }
            
        }
                    
        [self.mapView performSelectorOnMainThread:@selector(addAnnotations:) withObject:annotations waitUntilDone:NO];
                    
        [self.activityView setHidden:YES];
                    
    } failure:^(NSDictionary *dict, NSError *error) {
        
        [self.activityView setHidden:YES];
        
        NSLog(@"Error: %@", [error localizedDescription]);
        
    }];
    
}

#pragma mark --

- (void)zoomToRegionWithCoordinate:(CLLocationCoordinate2D)coordinate span:(MKCoordinateSpan)span andUserDecidesSpan:(BOOL)userSpan {
    MKCoordinateRegion region;
    region.center = coordinate;
    region.span = span;
    
    [self.mapView setRegion:region animated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:kSegueFromMapToAd]) {
        
        ((AdvertisementController*)segue.destinationViewController).ad = (Advertisement*)sender;
        
    }
}

#pragma mark --
#pragma mark Annotation view delegate methods

- (void)calloutView:(CalloutView *)calloutView touchedWithAnnotation:(Annotation *)annotation inPoint:(CGPoint)touchPoint {
        
    Advertisement* ad = (Advertisement*)annotation.ad;
    
    [self.mapView selectAnnotation:annotation animated:NO];
    
    [self performSegueWithIdentifier:kSegueFromMapToAd sender:ad];
    
    for(Annotation *annotation in self.mapView.selectedAnnotations) {
                
    }
}

- (void)annotationView:(AnnotationView *)annotationView willShowCallout:(CalloutView *)calloutView {
            
    CGRect mapRect = [self.mapView convertRegion:self.mapView.region toRectToView:annotationView];
                                    
    if(!CGRectContainsRect(mapRect, calloutView.frame)) {
                
        [self.mapView setCenterCoordinate:[(Annotation *)[annotationView annotation] coordinate] animated:YES];
                
    }
    
}

#pragma mark --
#pragma mark Map touches

- (void)mapTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer {
    
    NSMutableSet *annotationsTapped = [NSMutableSet set];
        
    for(Annotation *annotation in [self.mapView annotations]) {
        
        AnnotationView *annotationView = (AnnotationView *)[self.mapView viewForAnnotation:annotation];

        MKMapRect annotationRect = [self mapRectForRect:annotationView.frame fromView:[annotationView superview]];
        
        CLLocationCoordinate2D tapCoordiante = [self.mapView convertPoint:[tapGestureRecognizer locationInView:self.mapView] toCoordinateFromView:self.mapView];
        
        MKMapPoint tapPoint = MKMapPointForCoordinate(tapCoordiante);
                
        if(annotationView && MKMapRectContainsPoint(annotationRect, tapPoint)) {
            
            [annotationsTapped addObject:annotation];
            
            break;
            
            /*if(!annotationView.isCallout) {
                
                //[self.mapView selectAnnotation:annotation animated:YES];
                [annotationView setSelected:YES animated:YES];
                
                break;.
             
                
            }*/
            
        }
        
    }
    
    if(annotationsTapped.count == 0) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationHideCallouts object:nil];
        
    }
}

- (MKMapRect)mapRectForRect:(CGRect)rect fromView:(UIView *)canvasView
{
    CLLocationCoordinate2D topleft = [self.mapView convertPoint:CGPointMake(rect.origin.x, rect.origin.y) toCoordinateFromView:canvasView];
    CLLocationCoordinate2D bottomeright = [self.mapView convertPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect)) toCoordinateFromView:canvasView];
    MKMapPoint topleftpoint = MKMapPointForCoordinate(topleft);
    MKMapPoint bottomrightpoint = MKMapPointForCoordinate(bottomeright);
    
    return MKMapRectMake(topleftpoint.x, topleftpoint.y, bottomrightpoint.x - topleftpoint.x, bottomrightpoint.y - topleftpoint.y);
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
        
        //endFrame.origin.y -= endFrame.size.height;
        
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
                    } completion:nil];
                }];
            }
        }];
    }
}

#pragma mark --
#pragma mark UISearchBar delegate methods

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    [searchBar setShowsCancelButton:YES animated:YES];
    
    return YES;
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    
    [searchBar setText:nil];
    
    [searchBar setShowsCancelButton:NO animated:YES];
    
    self.isSearching = NO;
    
    self.query = @"";
    
    [self makeRequestWithQuery:self.query priceTo:self.priceTo priceFrom:self.priceFrom];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
        
    [searchBar resignFirstResponder];
    
    self.query = searchBar.text;
    
    for(Annotation *annotation in self.mapView.annotations) {
        
        if(![annotation isKindOfClass:[MKUserLocation class]]) {
            
            [self.mapView removeAnnotation:annotation];
            
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationHideCallouts object:nil];
    
    [self makeRequestWithQuery:self.query priceTo:self.priceTo priceFrom:self.priceFrom];
    
    for(UIView *subview in searchBar.subviews){
        
        if([subview isKindOfClass:UIButton.class]){
            
            [(UIButton*)subview setEnabled:YES];
            
        }
    }
    
}

@end
