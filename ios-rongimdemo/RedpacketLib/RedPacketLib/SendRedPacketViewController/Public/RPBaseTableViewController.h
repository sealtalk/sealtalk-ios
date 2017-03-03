//
//  YXPBaseTableViewController.h
//  YXPFordTransaction
//
//  Created by 都基鹏 on 16/5/15.
//  Copyright © 2016年 优信拍（北京）信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHBaseViewController.h"
#import "RPBaseTableView.h"

@interface RPBaseTableViewController : YZHBaseViewController<RPBaseTableViewProtocol,RPBaseTableViewCellProtocol>
@property (nonatomic,weak)RPBaseTableView * tableView;
@property (nonatomic,strong)NSMutableArray * dataSource;

- (Class)tableViewClass;
- (UITableViewStyle)tableViewStyel;
@end
