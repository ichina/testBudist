//
//  FilterView.m
//  iSaler
//
//  Created by Paul Semionov on 11.12.12.
//
//

#import <QuartzCore/QuartzCore.h>

#import "FilterView.h"

#import "UIViewController+KNSemiModal.h"

#import "UIView+Extensions.h"
#import "PriceFormatter.h"
#import "NSString+Extensions.h"
@interface FilterView()

@property (nonatomic, assign) BOOL isMaskedCorners;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImage;

- (void)setupInterface;

// View cycle

- (void)viewDidShow;
- (void)viewDidHide;

@end

@implementation FilterView

@synthesize minStat, maxStat, slider = _slider, priceTo, priceFrom, apply, distanse, currStat, cloud;
@synthesize minStatText, maxStatText, sliderValue = _sliderValue, priceToText, priceFromText, currStatText;

@synthesize isKeyboardShown, isMaskedCorners;

@synthesize backgroundImage;

@synthesize initialFrame;

@synthesize delegate;

@synthesize keyboard;

- (id)init {
    self = [super init];
    if(self) {
        
        self.sliderValue = 0.5f;
        self.minStatText = @"1 км";
        self.maxStatText = @"20000 км";
        self.currStatText = @"100 км";
        self.priceFromText = @"";
        self.priceToText = @"";
        
        [self setupInterface];
        
        //NSLog(@" - init : OK");
        
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        
        self.sliderValue = 0.5f;
        self.minStatText = @"1 км";
        self.maxStatText = @"20000 км";
        self.currStatText = @"100 км";
        self.priceFromText = @"";
        self.priceToText = @"";
        
        [self setupInterface];
                
    }
    
    return self;
}

-(void)awakeFromNib
{
    UIImageView* imageView = (UIImageView*)[self viewWithTag:50];
    [imageView setImage:[imageView.image resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)]];
    
    UIImageView* imageView2 = (UIImageView*)[self viewWithTag:51];
    [imageView2 setImage:[imageView2.image resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)]];
    
    UIImageView *imageView3 = (UIImageView*)[self viewWithTag:52];
    [imageView3 setImage:[imageView3.image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)]];
}

- (void)setupInterface {
    
    //self.trackedViewName = @"FilterView";
    
    self.initialFrame = self.frame;
    
    self.slider.value = self.sliderValue;
    self.minStat.text = self.minStatText;
    self.maxStat.text = self.maxStatText;
    self.currStat.text = self.currStatText;
    
    //[self.backgroundImage setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:BG_IMAGE]]];
    //[self.backgroundImage setImage:[UIImage imageNamed:BG_IMAGE]];
    
    self.touchable = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    [self.touchable setCenter:CGPointMake(self.center.x, self.touchable.center.y)];
    [self.touchable setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.touchable];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewDidShow)
                                                 name:kSemiModalDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewDidHide)
                                                 name:kSemiModalDidHideNotification
                                               object:nil];
    
    
   
}

- (void)viewDidShow {
    for(UIView *subview in [self subviews]) {
        
        if(![subview isKindOfClass:[UITextField class]] && ![subview isKindOfClass:[UIButton class]] && ![subview isKindOfClass:[PSSlider class]]) {
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
            [subview addGestureRecognizer:tapGesture];
            
            [subview setUserInteractionEnabled:YES];
                        
        }
        
    }
    self.backgroundImage.layer.cornerRadius = 7;
    self.backgroundImage.layer.masksToBounds = YES;
}

- (void)viewDidHide {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)tapGesture:(UIGestureRecognizer *)getureRecognizer {
    
    UITextField *textField = (UITextField*)[self findFirstResponder];
    
    if([[textField description] hasPrefix:@"<UITextField"]) {
        
        [textField resignFirstResponder];
        
        if(self.isKeyboardShown) {
            
            [self.delegate filterView:self wantsToResizeToSize:CGSizeMake(self.frame.size.width, self.initialFrame.size.height)];
            
            self.isKeyboardShown = NO;
        }
        
    }
    
}

- (void)layoutSubviews {
    
    /*
    if(!self.isMaskedCorners) {
    
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        UIBezierPath *roundedPath =
        [UIBezierPath bezierPathWithRoundedRect:self.backgroundImage.bounds
                              byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                    cornerRadii:CGSizeMake(10.f, 10.f)];
        maskLayer.fillColor = [[UIColor whiteColor] CGColor];
        maskLayer.backgroundColor = [[UIColor clearColor] CGColor];
        maskLayer.path = [roundedPath CGPath];
        
        self.backgroundImage.layer.mask = maskLayer;
        self.backgroundImage.layer.masksToBounds = YES;
        
        self.isMaskedCorners = YES;
    }
    */
    [self.slider setMinStat:0];
    [self.slider setMaxStat:20000];
    [self.slider setDelegate:self];
}

- (void)cancelPressed:(id)sender {
    [self.delegate filterView:self wantsToDismissWithData:nil];
}

- (IBAction)applyClick:(id)sender {
    
    self.priceFromText = [self.priceFrom.text containsString:[[PriceFormatter sharedFormatter] countryDivider]] ? [self.priceFrom.text stringByReplacingOccurrencesOfString:[[PriceFormatter sharedFormatter] countryDivider] withString:@"."] : self.priceFrom.text;
    self.priceToText = [self.priceTo.text containsString:[[PriceFormatter sharedFormatter] countryDivider]] ? [self.priceTo.text stringByReplacingOccurrencesOfString:[[PriceFormatter sharedFormatter] countryDivider] withString:@"."] : self.priceTo.text;
    
    [self endEditing:YES];
    
    [self.delegate filterView:self wantsToDismissWithData:@"asd"];
}

- (IBAction)sliderTouchDown {
    //[cloud setHidden:NO];
}

- (IBAction)sliderTouchup:(id)sender {
    //[cloud setHidden:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if(self.isKeyboardShown) {
        
        [self.delegate filterView:self wantsToResizeToSize:CGSizeMake(self.frame.size.width, self.initialFrame.size.height)];
        
        self.isKeyboardShown = NO;
        }
    
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if(!self.isKeyboardShown) {
        
        [self.delegate filterView:self wantsToResizeToSize:CGSizeMake(self.frame.size.width, self.initialFrame.size.height + 220)];
        
        self.isKeyboardShown = YES;

        }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if(([textField.text containsString:[[PriceFormatter sharedFormatter] countryDivider]] && [string isEqualToString:[[PriceFormatter sharedFormatter] countryDivider]]) || (textField.text.length == 0 && [string isEqualToString:[[PriceFormatter sharedFormatter] countryDivider]])) {
        return NO;
    }else{
        return YES;
    }
}

- (void)psslider:(PSSlider *)psslider valueChanged:(NSString *)value {
        
    self.currStatText = [[NSString alloc] initWithString:value];
    
    //NSLog(@"%f", psslider.value);
        
}

@end
