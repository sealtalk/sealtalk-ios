//
//  RCDSearchBar.m
//  RCloudMessage
//
//  Created by 张改红 on 16/9/7.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDSearchBar.h"
#import "RCDCommonDefine.h"
#import "RCDUtilities.h"
@implementation RCDSearchBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.placeholder = RCDLocalizedString(@"search");
        self.keyboardType = UIKeyboardTypeDefault;
        self.backgroundImage = [RCDUtilities getImageWithColor:[UIColor clearColor] andHeight:44.0f];
        //设置顶部搜索栏的背景色
        [self setBackgroundColor:HEXCOLOR(0xf0f0f6)];
    }
    return self;
}

@end
