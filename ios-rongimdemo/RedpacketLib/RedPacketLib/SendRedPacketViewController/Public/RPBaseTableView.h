//
//  YXPBaseTableVIew.h
//  YXPFordTransaction
//
//  Created by 都基鹏 on 16/5/12.
//  Copyright © 2016年 优信拍（北京）信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RPBaseTableViewCell.h"

@class RPBaseCellItem;
@protocol RPBaseTableViewProtocol <NSObject>
@required
- (NSArray*)items;
- (void)tableView:(UITableView*)tableView
 didSelectRawItem:(RPBaseCellItem*)cellItem;

@end

@interface RPBaseTableView : UITableView<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,weak)id<RPBaseTableViewProtocol,RPBaseTableViewCellProtocol> RPDelegate;

@end



