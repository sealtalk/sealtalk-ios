//
//  RCDTableView.m
//  SealTalk
//
//  Created by Sin on 2017/9/26.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "RCDTableView.h"

@implementation RCDTableView

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
