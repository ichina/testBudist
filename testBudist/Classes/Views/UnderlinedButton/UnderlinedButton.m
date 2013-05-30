//
//  UnderlinedButton.m
//  iSeller
//
//  Created by Чина on 12.03.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "UnderlinedButton.h"

@implementation UnderlinedButton


- (void) drawRect:(CGRect)rect {
    CGRect textRect = self.titleLabel.frame;
    
    // need to put the line at top of descenders (negative value)
    CGFloat descender = self.titleLabel.font.descender+(self.titleLabel.shadowOffset.height>0?self.titleLabel.shadowOffset.height+1:0);
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    // set to same colour as text
    CGContextSetStrokeColorWithColor(contextRef, self.titleLabel.textColor.CGColor);
    //линия
    CGContextMoveToPoint(contextRef, textRect.origin.x, textRect.origin.y + textRect.size.height + descender);
    
    CGContextAddLineToPoint(contextRef, textRect.origin.x + textRect.size.width, textRect.origin.y + textRect.size.height + descender);
    
    CGContextClosePath(contextRef);
    
    CGContextDrawPath(contextRef, kCGPathStroke);
    
    //тень для линии
    CGContextRef contextRef2 = UIGraphicsGetCurrentContext();

    CGContextSetStrokeColorWithColor(contextRef2, [UIColor blackColor].CGColor);

    CGContextMoveToPoint(contextRef2, textRect.origin.x, textRect.origin.y + textRect.size.height + descender+1);
    CGContextAddLineToPoint(contextRef2, textRect.origin.x + textRect.size.width, textRect.origin.y + textRect.size.height + descender+1);
    
    CGContextClosePath(contextRef2);
    
    CGContextDrawPath(contextRef2, kCGPathStroke);
}


@end
