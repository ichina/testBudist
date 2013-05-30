//
//  MyCell.h
//  iSaler
//
//  Created by Paul Semionov on 28.11.12.
//
//

#import "CustomCellForSelecting.h"

#import "LKBadgeView.h"
#import "PSBadgeStatusView.h"
#import "Advertisement.h"

@interface MyCell : CustomCellForSelecting

@property (nonatomic, retain) IBOutlet UILabel *titleOfAd;
@property (nonatomic, retain) IBOutlet UILabel *price;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet LKBadgeView *badge;

@property (nonatomic, retain) PSBadgeStatusView *badgeView;
@property (nonatomic, retain) NSString *state;

@property (nonatomic, retain) UIImage *justCreatedImage;

- (void)setViewCount:(NSString *)viewCount;
-(void) setAdvertisementInfo :(Advertisement*) ad;

@property (nonatomic, retain) NSArray* statusArray;

@end
