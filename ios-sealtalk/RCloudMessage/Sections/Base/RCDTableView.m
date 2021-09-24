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
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:UITableViewStyleGrouped]) {
        self.estimatedRowHeight = 0;
        self.estimatedSectionHeaderHeight = 0;
        self.estimatedSectionFooterHeight = 0;
        self.backgroundColor = RCDDYCOLOR(0xf5f6f9, 0x000000);
        self.separatorColor = RCDDYCOLOR(0xE3E5E6, 0x272727);
        self.separatorInset = UIEdgeInsetsMake(0, 59, 0, 0);
    }
    return self;
}
@end
