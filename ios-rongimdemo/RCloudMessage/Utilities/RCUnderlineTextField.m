//
//  RCUnderlineTextField.m
//  RCloudMessage
//
//  Created by 杜立召 on 15/3/19.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCUnderlineTextField.h"

@implementation RCUnderlineTextField

- (id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {
        //[self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {

    // Get the current drawing context
    CGContextRef context = UIGraphicsGetCurrentContext();

    // Set the line color and width
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:161 green:163 blue:168 alpha:0.2f].CGColor);
    CGContextSetLineWidth(context, 1.0f);

    // Start a new Path
    CGContextBeginPath(context);

    // Find the number of lines in our textView + add a bit more height to draw
    // lines in the empty part of the view
    // NSUInteger numberOfLines = (self.contentSize.height +
    // self.bounds.size.height) / self.font.leading;

    // Set the line offset from the baseline. (I'm sure there's a concrete way to
    // calculate this.)
    CGFloat baselineOffset = 45.0f;

    // iterate over numberOfLines and draw each line
    // for (int x = 1; x < numberOfLines; x++) {

    // 0.5f offset lines up line with pixel boundary
    CGContextMoveToPoint(context, self.bounds.origin.x, baselineOffset);
    CGContextAddLineToPoint(context, self.bounds.size.width - 10, baselineOffset);
    //}

    // Close our Path and Stroke (draw) it
    CGContextClosePath(context);
    CGContextStrokePath(context);
}

@end
