//
//  RCDNavigationBar.m
//  RCloudMessage
//
//  Created by Liv on 15/4/3.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDNavigationBar.h"
#import "UIColor+RCColor.h"

@implementation RCDNavigationBar

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {

        [self setBarTintColor:[UIColor colorWithHexString:@"0195ff" alpha:1.0f]];
    }
    return self;
}

@end
