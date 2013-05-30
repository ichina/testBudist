//
//  MessageCell.h
//  seller
//
//  Created by Чина on 19.09.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

@interface MessageCell : UITableViewCell

@property(nonatomic,weak) IBOutlet UILabel* body;
@property (nonatomic, retain) IBOutlet UILabel *name;
@property(nonatomic,weak) IBOutlet UIImageView* avatar;
//@property(nonatomic,strong) NSDictionary* message;
@property (weak, nonatomic) IBOutlet UIImageView *cloud;
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;

// Бул на прочитанность
@property (nonatomic, assign) BOOL isFresh;

-(void) setBodyText:(NSString*) strBody;
- (void)setIsFresh:(BOOL)isFresh  andIsOwn:(BOOL)isOwn;

-(void)setMessageInfo:(Message*) message;

@end
