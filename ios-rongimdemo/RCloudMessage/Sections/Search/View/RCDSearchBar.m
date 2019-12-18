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
        if (@available(iOS 13.0, *)) {
            self.searchTextField.backgroundColor =
                [RCDUtilities generateDynamicColor:HEXCOLOR(0xffffff)
                                         darkColor:[HEXCOLOR(0x1c1c1e) colorWithAlphaComponent:0.6]];
        }
        //设置顶部搜索栏的背景色
        self.barTintColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
        self.layer.borderColor = RCDDYCOLOR(0xf0f0f6, 0x000000).CGColor;
        self.layer.borderWidth = 1;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    self.layer.borderColor = RCDDYCOLOR(0xf0f0f6, 0x000000).CGColor;
}
@end
