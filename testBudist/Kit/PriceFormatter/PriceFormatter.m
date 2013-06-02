//
//  PriceFormatter.m
//  iSaler
//
//  Created by Chingis Gomboev on 22.11.12.
//
// ₷

#import "PriceFormatter.h"

#define SHOWCASE 0

@implementation PriceFormatter

@synthesize locale, geocoder, locationManager;
@synthesize formatter;

#pragma mark Singleton methods

static PriceFormatter *instance_;

+ (PriceFormatter *)sharedFormatter {
    @synchronized(self) {
        if( instance_ == nil ) {
            instance_ = [[self alloc] init];
        }
    }
    
    return instance_;
}

- (id)init {
    self = [super init];
    instance_ = self;
    
    self.locale = [[NSLocale alloc] initWithLocaleIdentifier:[NSLocale localeIdentifierFromComponents:[NSDictionary dictionaryWithObjectsAndKeys:@"ISO 3166-2:RU", NSLocaleCountryCode, @"ru_RU", NSLocaleLanguageCode, nil]]];
    
    
    self.formatter = [[NSNumberFormatter alloc] init];
    
    switch (SHOWCASE) {
        case 0:
            [self.formatter setLocale:self.locale];
            break;
        case 1:
            [self.formatter setLocale:[NSLocale currentLocale]];
            break;
            
        default:
            break;
    }
    
    [self.formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    return self;
}

- (void)prepareLocale {
    
    self.locationManager = [[CLLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];
    
    [self.locationManager startUpdatingLocation];
        
    //ISO 3166-2:RU, ru_RU
}

- (NSString *)formatPrice:(float)price {
    
    //NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    //[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    /*
     switch (SHOWCASE) {
     case 0:
     [formatter setLocale:self.locale];
     break;
     case 1:
     [formatter setLocale:[NSLocale currentLocale]];
     break;
     
     default:
     break;
     }
     */

    NSString* result = [self.formatter stringFromNumber:[NSNumber numberWithFloat:price]];
    result = [result stringByReplacingCharactersInRange:[result rangeOfString:[self.formatter currencySymbol]] withString: NSLocalizedString([formatter currencySymbol], nil)];
    //NSLog(@"%@",);
    return result;
}

- (NSString *)formatPriceString:(NSString *)priceString dividerWithString:(NSString *)dividerString {
    
    //NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    //[formatter currencyDecimalSeparator];
    /*
    switch (SHOWCASE) {
        case 0:
            [formatter setLocale:self.locale];
            break;
        case 1:
            [formatter setLocale:[NSLocale currentLocale]];
            break;
            
        default:
            break;
    }
    */
    return [priceString stringByReplacingOccurrencesOfString:[formatter currencyDecimalSeparator] withString:dividerString];
    
}

- (NSString *)countryDivider {
    //NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    switch (SHOWCASE) {
        case 0:
            [formatter setLocale:self.locale];
            break;
        case 1:
            [formatter setLocale:[NSLocale currentLocale]];
            break;
            
        default:
            break;
    }
    
    return [formatter currencyDecimalSeparator];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    self.geocoder = [CLGeocoder new];
            
    [self.geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error){
                
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
                
        NSDictionary *components = [NSDictionary dictionaryWithObjectsAndKeys:placemark.ISOcountryCode, NSLocaleCountryCode, [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode], NSLocaleLanguageCode, nil];
        NSString *localeIdentity = [NSLocale localeIdentifierFromComponents:components];
        self.locale = [[NSLocale alloc] initWithLocaleIdentifier:localeIdentity];
                        
    }];
        
    [self.locationManager stopUpdatingLocation];
        
}

@end
