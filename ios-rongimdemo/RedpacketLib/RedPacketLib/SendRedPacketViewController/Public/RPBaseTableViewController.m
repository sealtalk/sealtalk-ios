//
//  YXPBaseTableViewController.m
//  YXPFordTransaction
//
//  Created by 都基鹏 on 16/5/15.
//  Copyright © 2016年 优信拍（北京）信息科技有限公司. All rights reserved.
//

#import "RPBaseTableViewController.h"

@interface RPBaseTableViewController ()

@end

@implementation RPBaseTableViewController
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dataSource = [NSMutableArray array];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"";
    RPBaseTableView * tableView = [[self.tableViewClass alloc]initWithFrame:self.view.bounds style:self.tableViewStyel];
    tableView.RPDelegate = self;
    self.tableView = tableView;
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:tableView];
    
}
- (Class)tableViewClass{
    return [RPBaseTableView class];
}
- (UITableViewStyle)tableViewStyel{
    return UITableViewStylePlain;
}
- (NSArray *)items{
    return self.dataSource;
}
- (void)tableView:(UITableView *)tableView didSelectRawItem:(RPBaseCellItem *)cellItem{
}
- (void)actionWithTableViewCell:(RPBaseTableViewCell *)cell sender:(UIView *)sender cellItem:(RPBaseCellItem *)cellItem{

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
