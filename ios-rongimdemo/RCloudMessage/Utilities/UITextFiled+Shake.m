//
//  UITextFiled+Shake.m
//  RCloudMessage
//
//  Created by 杜立召 on 15/3/23.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "UITextFiled+Shake.h"

@implementation UITextField (Shake)
// self.superView
- (void)shake {
    CAKeyframeAnimation *keyAn = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    [keyAn setDuration:0.5f];
    NSArray *array =
        [[NSArray alloc] initWithObjects:[NSValue valueWithCGPoint:CGPointMake(self.center.x, self.center.y)],
                                         [NSValue valueWithCGPoint:CGPointMake(self.center.x - 5, self.center.y)],
                                         [NSValue valueWithCGPoint:CGPointMake(self.center.x + 5, self.center.y)],
                                         [NSValue valueWithCGPoint:CGPointMake(self.center.x, self.center.y)],
                                         [NSValue valueWithCGPoint:CGPointMake(self.center.x - 5, self.center.y)],
                                         [NSValue valueWithCGPoint:CGPointMake(self.center.x + 5, self.center.y)],
                                         [NSValue valueWithCGPoint:CGPointMake(self.center.x, self.center.y)],
                                         [NSValue valueWithCGPoint:CGPointMake(self.center.x - 5, self.center.y)],
                                         [NSValue valueWithCGPoint:CGPointMake(self.center.x + 5, self.center.y)],
                                         [NSValue valueWithCGPoint:CGPointMake(self.center.x, self.center.y)], nil];
    [keyAn setValues:array];

    NSArray *times =
        [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat:0.1f], [NSNumber numberWithFloat:0.2f],
                                         [NSNumber numberWithFloat:0.3f], [NSNumber numberWithFloat:0.4f],
                                         [NSNumber numberWithFloat:0.5f], [NSNumber numberWithFloat:0.6f],
                                         [NSNumber numberWithFloat:0.7f], [NSNumber numberWithFloat:0.8f],
                                         [NSNumber numberWithFloat:0.9f], [NSNumber numberWithFloat:1.0f], nil];
    [keyAn setKeyTimes:times];
    [self.layer addAnimation:keyAn forKey:@"Shark"];
}
@end
