//
//  PriceFormatter.h
//  iSaler
//
//  Created by Chingis Gomboev on 22.11.12.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface PriceFormatter : NSObject <CLLocationManagerDelegate>

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLGeocoder *geocoder;

@property (nonatomic, retain) NSLocale *locale;
@property (nonatomic, retain) NSNumberFormatter* formatter;
+ (PriceFormatter *)sharedFormatter;

- (void)prepareLocale;

- (NSString *)formatPrice:(float)price;

- (NSString *)formatPriceString:(NSString *)priceString dividerWithString:(NSString *)dividerString;

- (NSString *)countryDivider;

@end
