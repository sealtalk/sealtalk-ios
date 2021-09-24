//
//  RCDTableViewController.m
//  SealTalk
//
//  Created by Sin on 2017/9/26.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "RCDTableViewController.h"

@interface RCDTableViewController ()

@end

@implementation RCDTableViewController
- (instancetype)initWithStyle:(UITableViewStyle)style{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //关闭iOS11默认开启的self sizing
    [self closeSelfSizing];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = RCDDYCOLOR(0xf5f6f9, 0x111111);
    self.tableView.separatorColor = RCDDYCOLOR(0xE3E5E6, 0x272727);
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 59, 0, 0);
}

- (void)closeSelfSizing {
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView new];
    view.backgroundColor = RCDDYCOLOR(0xf5f6f9, 0x000000);
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
@end
