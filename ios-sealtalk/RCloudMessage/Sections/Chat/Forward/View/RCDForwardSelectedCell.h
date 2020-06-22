//
//  RCDForwardSelectedCell.h
//  SealTalk
//
//  Created by 孙浩 on 2019/6/17.
//  Copyright © 2019 RongCloud. All rights reserved.
//
#import "RCDTableViewCell.h"
#import "RCDFriendInfo.h"
#import "RCDGroupInfo.h"
#import "RCDForwardCellModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RCDForwardSelectedStatus) {
    RCDForwardSelectedStatusSingleSelect = 0,
    RCDForwardSelectedStatusMultiUnSelected,
    RCDForwardSelectedStatusMultiSelected,
};

@interface RCDForwardSelectedCell : RCDTableViewCell

@property (nonatomic, assign) RCDForwardSelectedStatus selectStatus;

@property (nonatomic, assign) BOOL canSelect;

- (void)setModel:(RCDForwardCellModel *)model;

- (void)setFriendInfo:(RCDFriendInfo *)friendInfo;

- (void)setGroupInfo:(RCDGroupInfo *)groupInfo;

@end

NS_ASSUME_NONNULL_END
