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

- (void)viewDidLoad {
    [super viewDidLoad];
    //关闭iOS11默认开启的self sizing
    [self closeSelfSizing];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
    self.tableView.separatorColor = RCDDYCOLOR(0xdfdfdf, 0x1a1a1a);
}

- (void)closeSelfSizing {
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView new];
    view.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
    return view;
}
@end
