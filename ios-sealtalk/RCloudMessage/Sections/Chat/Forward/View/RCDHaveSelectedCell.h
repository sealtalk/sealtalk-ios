//
//  RCDHaveSelectedCell.h
//  SealTalk
//
//  Created by 孙浩 on 2019/6/18.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDTableViewCell.h"
#import "RCDForwardCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCDHaveSelectedCell : RCDTableViewCell

@property (nonatomic, copy) void (^deleteButtonBlock)(RCDForwardCellModel *model);

@property (nonatomic, strong) RCDForwardCellModel *model;
//- (void)setModel:(RCConversation *)model;

@end

NS_ASSUME_NONNULL_END
