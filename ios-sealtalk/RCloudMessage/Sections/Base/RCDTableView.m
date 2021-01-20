//
//  RCDTableView.m
//  SealTalk
//
//  Created by Sin on 2017/9/26.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "RCDTableView.h"
#import "RCDUtilities.h"
@implementation RCDTableView
- (instancetype)init {
    if (self = [super init]) {
        self.tableFooterView = [UIView new];
        self.backgroundColor = RCDDYCOLOR(0xf5f6f9, 0x000000);
        self.separatorColor = RCDDYCOLOR(0xE3E5E6, 0x272727);
        self.separatorInset = UIEdgeInsetsMake(0, 59, 0, 0);

    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        self.tableFooterView = [UIView new];
        self.backgroundColor = RCDDYCOLOR(0xf5f6f9, 0x000000);
        self.separatorColor = RCDDYCOLOR(0xE3E5E6, 0x272727);
        self.separatorInset = UIEdgeInsetsMake(0, 59, 0, 0);
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    //关闭iOS11默认开启的self sizing
    [self closeSelfSizing];
}

- (void)closeSelfSizing {
    self.estimatedRowHeight = 0;
    self.estimatedSectionHeaderHeight = 0;
    self.estimatedSectionFooterHeight = 0;
}

@end
