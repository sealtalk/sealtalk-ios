//
//  YXPBaseTableViewCell.h
//  YXPFordTransaction
//
//  Created by 都基鹏 on 16/5/12.
//  Copyright © 2016年 优信拍（北京）信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RPBaseCellItem.h"
@class RPBaseTableViewCell;

@protocol RPBaseTableViewCellProtocol <NSObject>

@optional
- (void)reloadData;

@required
- (void)actionWithTableViewCell:(RPBaseTableViewCell*)cell
                         sender:(UIView*)sender
                       cellItem:(RPBaseCellItem*)cellItem;

@end

@interface RPBaseTableViewCell : UITableViewCell

@property (nonatomic,weak)id<RPBaseTableViewCellProtocol> RPCellDelagete;
@property (nonatomic,strong)RPBaseCellItem * cellItem;

@property (nonatomic,weak)UIView * topLine;
@property (nonatomic,weak)UIView * bottomLine;

- (void)tableViewCellCustomAction;

@end
