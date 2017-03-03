//
//  YXPBaseTableVIew.m
//  YXPFordTransaction
//
//  Created by 都基鹏 on 16/5/12.
//  Copyright © 2016年 优信拍（北京）信息科技有限公司. All rights reserved.
//

#import "RPBaseTableView.h"
#import "RPBaseCellItem.h"
#import "RPBaseTableViewCell.h"
@interface RPBaseTableView()
@end
@implementation RPBaseTableView
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.backgroundColor = [UIColor grayColor];
    }
    return self;
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([self.RPDelegate.items isKindOfClass:[NSArray class]]) {
        return self.RPDelegate.items.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RPBaseCellItem * cellItem = [self.RPDelegate.items objectAtIndex:indexPath.row];
    RPBaseTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellItem.cellReuseIdentifier];
    if (!cell) {
        if (cellItem.nib) {
            cell = [[cellItem.nib instantiateWithOwner:nil options:nil]firstObject];
        }else if (cellItem.cellClass){
            cell = [[cellItem.cellClass alloc]initWithStyle:cellItem.cellStyle reuseIdentifier:cellItem.cellReuseIdentifier];
        }
    }
    cell.selectionStyle = cellItem.cellSelectionStyle;
    cell.RPCellDelagete = self.RPDelegate;
    cell.cellItem = cellItem;
    cellItem.cellIndexPath = indexPath;
    cellItem.tableView = self;
    cellItem.tableViewCell = cell;
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    RPBaseCellItem * cellItem = [self.RPDelegate.items objectAtIndex:indexPath.row];
    return cellItem.cellHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.0f;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RPBaseCellItem * cellItem = [self.RPDelegate.items objectAtIndex:indexPath.row];
    if (cellItem.deselect) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    if ([self.RPDelegate respondsToSelector:@selector(tableView:didSelectRawItem:)]) {
        [self.RPDelegate tableView:tableView didSelectRawItem:cellItem];
    }
    [self endEditing:YES];
}

@end
