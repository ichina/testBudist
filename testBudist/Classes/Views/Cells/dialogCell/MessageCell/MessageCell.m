//
//  Messageself.m
//  seller
//
//  Created by Чина on 19.09.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MessageCell.h"
#import "NSString+Extensions.h"

@interface MessageCell()

- (void)readMe;

@property BOOL needAnimation;

@end

@implementation MessageCell
@synthesize avatar, body, cloud, name, dateLabel;

@synthesize isFresh = _isFresh;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
/*
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    static UIImage* prevStatImage;
    if(highlighted)
    {
        if(self.cloud.image)
        {
            prevStatImage = self.cloud.image;
            [self.cloud setImage:[[UIImage imageNamed:@"dialog_cloud_selected.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 6, 6, 6)]];
        }
    }else
    {
        if(prevStatImage)
            [self.cloud setImage:prevStatImage];
    }
}
*/
- (void)setIsFresh:(BOOL)isFresh  andIsOwn:(BOOL)isOwn{
    
    _isFresh = isFresh;
    if(isFresh) {
        [self.cloud setImage:[[UIImage imageNamed:@"dialog_incoming_cloud.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 6, 6, 6)]];
        if(isOwn)
        {
            [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(readMe) userInfo:nil repeats:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReadMessages" object:self];
        }
    }else{
        [self.cloud setImage:[[UIImage imageNamed:@"dialog_outgoing_cloud.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 6, 6, 6)]];
    }
}

- (void)readMe {
    self.isFresh = NO;
     [self.cloud setImage:[[UIImage imageNamed:@"dialog_outgoing_cloud.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 6, 6, 6)]];
}

-(void) setBodyText:(NSString*) strBody
{
    [self.body setFrame:CGRectMake(63, 25, 246, self.body.frame.size.height)];
    body.lineBreakMode = NSLineBreakByWordWrapping;
    body.text = strBody;
    
    [body sizeToFit];
}

-(void)setMessageInfo:(Message* )message
{
    ////АВАТАРКИ ЗАДАТЬ СНАРУЖИ
    [self.body setNumberOfLines:0];
    [self setBodyText:message.body];

    [self.dateLabel setText:[message.createdAt formatStringDateWithFormat:nil withTime:YES]];
    
    if([message.incoming boolValue]) {
        
        //[self.avatar setImage:companionAvatar];
        [self.name setText:message.name];
        
        [self.body setFrame:CGRectMake(63, 43, 246, self.body.frame.size.height)];
        
        [self.name setHidden:NO];
        [self.name setFrame:CGRectMake(63, 25, 246, 21)];
        
    }else{
        //[self.avatar setImage:userAvatar];
        [self.name setText:@""];
        
        [self.name setHidden:YES];
        [self.body setFrame:CGRectMake(63, 25, 246, self.body.frame.size.height)];
    }
    
    //CGSize size = [message.body sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:17.0f] constrainedToSize:CGSizeMake(237, 10000) lineBreakMode:NSLineBreakByWordWrapping];
    CGSize size = [message.body sizeWithFont:[UIFont systemFontOfSize:17.0f] constrainedToSize:CGSizeMake(247, 10000) lineBreakMode:NSLineBreakByWordWrapping];
    
    [self.cloud setFrame:CGRectMake(48, 6, 261, size.height+([message.incoming boolValue] ? 43.0f : 25.0f) + 4.0f)];
    
    [self setIsFresh:[message.isFresh boolValue] andIsOwn:[message.incoming boolValue]];
    if(message.incoming.boolValue)
        message.isFresh = @NO;
}

-(void)layoutSubviews
{   
    [super layoutSubviews];
}

@end
