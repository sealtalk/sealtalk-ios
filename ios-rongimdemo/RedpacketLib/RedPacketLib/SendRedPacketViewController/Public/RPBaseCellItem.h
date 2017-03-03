//
//  YXPCellItem.h
//  YXPFordTransaction
//
//  Created by 都基鹏 on 16/5/12.
//  Copyright © 2016年 优信拍（北京）信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class RPBaseTableViewCell;

@interface RPBaseCellItem : NSObject
- (Class)cellClass;
- (UINib*)nib;
- (NSString*)cellReuseIdentifier;
- (UITableViewCellStyle)cellStyle;//deafule UITableViewCellStyleDefault
- (CGFloat)cellHeight;//deafule 40.0
- (UITableViewCellSelectionStyle)cellSelectionStyle;//deafule UITableViewCellSelectionStyleNone
- (BOOL)deselect; //deafule yes

@property (nonatomic,strong)NSIndexPath * cellIndexPath;
@property (nonatomic,weak)UITableView * tableView;
@property (nonatomic,weak)RPBaseTableViewCell * tableViewCell;
@property (nonatomic,strong)id rawItem;
@end
