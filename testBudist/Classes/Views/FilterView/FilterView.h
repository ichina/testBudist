//
//  FilterView.h
//  iSaler
//
//  Created by Paul Semionov on 11.12.12.
//
//

#import <UIKit/UIKit.h>

//#import "GAITrackedViewController.h"

#import "PSSlider.h"

@protocol FilterViewDelegate;

@interface FilterView : UIView <UITextFieldDelegate, PSSliderDelegate> {
    
    id <FilterViewDelegate> delegate;
    
}

@property (nonatomic, retain) id <FilterViewDelegate> delegate;

@property (nonatomic, weak) IBOutlet UIView *cloud;
@property (nonatomic, weak) IBOutlet UILabel *minStat;
@property (nonatomic, weak) IBOutlet UILabel *maxStat;
@property (nonatomic, weak) IBOutlet UILabel *currStat;
@property (nonatomic, weak) IBOutlet PSSlider *slider;
@property (nonatomic, weak) IBOutlet UITextField *priceFrom;
@property (nonatomic, weak) IBOutlet UITextField *priceTo;
@property (nonatomic, weak) IBOutlet UIButton *apply;
@property (nonatomic, weak) IBOutlet UIButton *distanse;

@property (nonatomic, retain) UIView* keyboard;

@property (nonatomic, retain) UIView *touchable;

@property (nonatomic, retain) NSString *minStatText;
@property (nonatomic, retain) NSString *maxStatText;
@property (nonatomic, retain) NSString *currStatText;
@property (nonatomic, retain) NSString *priceFromText;
@property (nonatomic, retain) NSString *priceToText;
@property CGFloat sliderValue;

@property CGRect initialFrame;

@property (nonatomic, assign) BOOL isKeyboardShown;

@end

@protocol FilterViewDelegate <NSObject>

@optional
- (void)filterView:(FilterView *)filterView wantsToDismissWithData:(id)data;
- (void)filterView:(FilterView *)filterView wantsToResizeToSize:(CGSize)size;

@end