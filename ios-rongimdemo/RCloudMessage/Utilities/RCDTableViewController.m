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
}
- (void)closeSelfSizing {
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
}
@end
