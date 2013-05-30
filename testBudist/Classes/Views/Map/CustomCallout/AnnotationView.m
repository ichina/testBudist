 //
//  AnnotationView.m
//  iSeller
//
//  Created by Paul Semionov on 25.01.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "AnnotationView.h"
#import <AFNetworking.h>
#import "PriceFormatter.h"
#import "LocationManager.h"

NSString *const AnnotationViewDidFinishDrag = @"AnnotationViewDidFinishDrag";
NSString *const AnnotationViewKey = @"AnnotationView";

#define kFingerSize 20.0

@interface AnnotationView()

@property (nonatomic) CGPoint fingerPoint;

@end

@implementation AnnotationView

@synthesize delegate = _delegate;

@synthesize calloutView = _calloutView;

@synthesize isCallout;

@synthesize dragState, fingerPoint, mapView;

- (void)setDragState:(MKAnnotationViewDragState)newDragState animated:(BOOL)animated
{
    if(mapView){
        id<MKMapViewDelegate> mapDelegate = (id<MKMapViewDelegate>)mapView.delegate;
        [mapDelegate mapView:mapView annotationView:self didChangeDragState:newDragState fromOldState:dragState];
    }
    
    // Calculate how much to life the pin, so that it's over the finger, no under.
    CGFloat liftValue = -(fingerPoint.y - self.frame.size.height - kFingerSize);
    
    if (newDragState == MKAnnotationViewDragStateStarting)
    {
        CGPoint endPoint = CGPointMake(self.center.x,self.center.y-liftValue);
        [UIView animateWithDuration:0.2
                         animations:^{
                             self.center = endPoint;
                         }
                         completion:^(BOOL finished){
                             dragState = MKAnnotationViewDragStateDragging;
                         }];
        
    }
    else if (newDragState == MKAnnotationViewDragStateEnding)
    {
        // lift the pin again, and drop it to current placement with faster animation.
        
        __block CGPoint endPoint = CGPointMake(self.center.x,self.center.y-liftValue);
        [UIView animateWithDuration:0.2
                         animations:^{
                             self.center = endPoint;
                         }
                         completion:^(BOOL finished){
                             endPoint = CGPointMake(self.center.x,self.center.y+liftValue);
                             [UIView animateWithDuration:0.1
                                              animations:^{
                                                  self.center = endPoint;
                                              }
                                              completion:^(BOOL finished){
                                                  dragState = MKAnnotationViewDragStateNone;
                                                  if(!mapView)
                                                      [[NSNotificationCenter defaultCenter] postNotificationName:AnnotationViewDidFinishDrag object:nil userInfo:[NSDictionary dictionaryWithObject:self.annotation forKey:AnnotationViewKey]];
                                              }];
                         }];
    }
    else if (newDragState == MKAnnotationViewDragStateCanceling)
    {
        // drop the pin and set the state to none
        
        CGPoint endPoint = CGPointMake(self.center.x,self.center.y+liftValue);
        [UIView animateWithDuration:0.2
                         animations:^{
                             self.center = endPoint;
                         }
                         completion:^(BOOL finished){
                             dragState = MKAnnotationViewDragStateNone;
                         }];
    }
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event
{
    // When the user touches the view, we need his point so we can calculate by how
    // much we should life the annotation, this is so that we don't hide any part of
    // the pin when the finger is down.
    
    fingerPoint = point;
    return [super hitTest:point withEvent:event];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    Annotation *annotation = self.annotation;
    
    if(!selected) {
        selected = YES;
        return;
    }
                
    if(selected && !self.isCallout && (![annotation.title isEqualToString:@""] && annotation.title))
    {
        //Add your custom view to self...
                
        for(UIView *subview in [[self superview] subviews]) {
            
            if(![subview isEqual:self]) {
                                
                for(UIView *subSubview in [subview subviews]) {
                    
                    if([subSubview isKindOfClass:[CalloutView class]] && ![self.calloutView isEqual:subSubview]) {
                                                                        
                        CGRect annotationRect = [[self superview] convertRect:self.frame toView:subview];
                        
                        if(CGRectIntersectsRect(subSubview.frame, annotationRect)) {
                                                        
                            [self setSelected:NO animated:animated];
                            
                            [(AnnotationView *)subview bringSubviewToFront:subSubview];
                                                                                    
                            return;
                            
                        }else if([subSubview isKindOfClass:[CalloutView class]] && [self.calloutView isEqual:subSubview]){
                            
                            return;
                            
                        }
                        
                    }
                    
                }
                
                
            }
        
        }
                
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationHideCallouts object:self];
        
        if(!annotation.isDisplayLocation) {
        
            self.calloutView = [[[NSBundle mainBundle] loadNibNamed:@"Callout" owner:self.annotation options:nil] objectAtIndex:0];
            
            [self.calloutView setFrame:CGRectMake(-self.calloutView.frame.size.width/2 + self.frame.size.width/2, -self.calloutView.frame.size.height, self.calloutView.frame.size.width, self.calloutView.frame.size.height)];
            
            [self.calloutView sizeToFit];
            
            self.calloutView.title.text = annotation.title;
            
            self.calloutView.price.text = [[PriceFormatter sharedFormatter] formatPrice:[[annotation.ad price] floatValue]];
            self.calloutView.distance.text = [[LocationManager sharedManager] calculateDistanceWithLocation:annotation.ad.location];
            [self.calloutView.image setImageWithURL:[NSURL URLWithString:annotation.ad.smallImage] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
            
        }else{
            
            self.calloutView = [[[NSBundle mainBundle] loadNibNamed:@"CalloutLocation" owner:self.annotation options:nil] objectAtIndex:0];
            
            [self.calloutView setFrame:CGRectMake(-self.calloutView.frame.size.width/2 + self.frame.size.width/2, -self.calloutView.frame.size.height, self.calloutView.frame.size.width, self.calloutView.frame.size.height)];
            
            [self.calloutView sizeToFit];
            
            self.calloutView.title.text = annotation.title;
            
            [[LocationManager sharedManager] placemarkFromLocation:annotation.coordinate completion:^(CLPlacemark *placemark, NSError *error) {
               
                [self.calloutView.activityView stopAnimating];
                
                NSString *addressString = [[[[NSString stringWithFormat:@"%@, %@, %@, %@", [placemark.addressDictionary objectForKey:@"Street"], [placemark.addressDictionary objectForKey:@"City"] ? [placemark.addressDictionary objectForKey:@"City"] : [placemark.addressDictionary objectForKey:@"Name"], [placemark.addressDictionary objectForKey:@"Country"], [placemark.addressDictionary objectForKey:@"ZIP"]] stringByReplacingOccurrencesOfString:@"(null)," withString:@""] stringByReplacingOccurrencesOfString:@", (null)" withString:@""] stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
                                
                if([addressString hasSuffix:@",  "]) {
                    
                    addressString = [addressString substringToIndex:addressString.length - 3];
                    
                }
                
                if([addressString hasPrefix:@" "]) {
                    
                    addressString = [addressString substringFromIndex:1];
                    
                }
                
                self.calloutView.title.text = addressString;
                                                                
                [self.calloutView sizeToFit];
                
                if([self.calloutView.title.text isEqualToString:@" "]) {
                    
                    [self hideCallout:[NSNotification notificationWithName:@"asd" object:nil]];
                    
                }
                                                                
            }];
            
        }
        
        if([self.delegate respondsToSelector:@selector(annotationView:willShowCallout:)]) {
            
            [self.delegate annotationView:self willShowCallout:self.calloutView];
            
        }
                
        [self animateCalloutAppearance];
        
        [self addSubview:self.calloutView];
        
        [self bringSubviewToFront:self.calloutView];
                
        self.isCallout = YES;
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        [tapGesture setDelegate:self];
        [self.calloutView addGestureRecognizer:tapGesture];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(hideCallout:)
                                                     name:kNotificationHideCallouts
                                                   object:nil];
    }
    else if(selected && self.isCallout) {
        
        /*[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationHideCallouts object:self.annotation];
        
        [self animateCalloutAppearance];
        
        [self addSubview:self.calloutView];
        
        [self bringSubviewToFront:self.calloutView];*/
        
    }
    else
    {
        //Remove your custom view...
        //[calloutView removeFromSuperview];
        
        NSLog(@"Callout should remove");
        
    }
    
    BOOL hasCallout = NO;
    
    for(CalloutView *callout in self.subviews) {
        
        if(callout) {
            
            hasCallout = YES;
            break;
            
        }
        
    }
    
    if(hasCallout) {
        
        [super setSelected:YES animated:animated];
        
    }else{
        
        [super setSelected:NO animated:animated];
        
    }
        
}

- (void)tapGesture:(UITapGestureRecognizer *)tapGestureRecognizer {
        
    if([self.delegate respondsToSelector:@selector(calloutView:touchedWithAnnotation:inPoint:)]) {
        
        [self.delegate calloutView:self.calloutView touchedWithAnnotation:self.annotation inPoint:[tapGestureRecognizer locationInView:self.calloutView]];
        
    }
    
}

- (void)hideCallout:(NSNotification *)notification {
    
    if(![notification.object isEqual:self.annotation]) {
    
        [self.calloutView removeFromSuperview];
        [self setNeedsDisplay];
        self.calloutView = nil;
        self.isCallout = NO;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
        
    if(CGRectContainsPoint(self.calloutView.frame, point) || CGRectContainsPoint(self.bounds, point)) {
        return YES;
    }else{

        /*[self.calloutView removeFromSuperview];
        self.calloutView = nil;
        self.isCallout = NO;*/
        return NO;
    }
}

- (void)didAddSubview:(UIView *)subview{
    Annotation *ann = self.annotation;
    if (ann.state != kAnnotationStateDropped) {
        if ([[[subview class] description] isEqualToString:@"UICalloutView"]) {
            for (UIView *subsubView in subview.subviews) {
                if ([subsubView class] == [UIImageView class]) {
                    UIImageView *imageView = ((UIImageView *)subsubView);                    
                    [imageView removeFromSuperview];
                }else if ([subsubView class] == [UILabel class]) {
                    UILabel *labelView = ((UILabel *)subsubView);
                    [labelView removeFromSuperview];
                }
            }
        }
    }
    
    if([self.delegate respondsToSelector:@selector(annotationView:didShowCallout:)]) {
        
        [self.delegate annotationView:self didShowCallout:self.calloutView];
        
    }
    
}

- (void)animateCalloutAppearance {
    CGFloat scale = 0.001f;
    self.calloutView.transform = CGAffineTransformMake(scale, 0.0f, 0.0f, scale, 0, 35);
    
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationCurveEaseIn animations:^{
        CGFloat scale = 1.1f;
        self.calloutView.transform = CGAffineTransformMake(scale, 0.0f, 0.0f, scale, 0, 2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
            CGFloat scale = 0.95;
            self.calloutView.transform = CGAffineTransformMake(scale, 0.0f, 0.0f, scale, 0, -2);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.075 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
                CGFloat scale = 1.0;
                self.calloutView.transform = CGAffineTransformMake(scale, 0.0f, 0.0f, scale, 0, 0);
            } completion:nil];
        }];
    }];
}

@end
