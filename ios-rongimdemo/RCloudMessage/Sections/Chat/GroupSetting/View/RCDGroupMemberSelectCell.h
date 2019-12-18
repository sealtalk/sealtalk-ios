//
//  RCDGroupMemberSelectCell.h
//  SealTalk
//
//  Created by 张改红 on 2019/6/18.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDTableViewCell.h"
@class RCUserInfo;
NS_ASSUME_NONNULL_BEGIN
static NSString *RCDGroupMemberSelectCellIdentifier = @"RCDGroupMemberSelectCellIdentifier";
typedef NS_ENUM(NSUInteger, RCDGroupMemberSelectCellState) {
    RCDGroupMemberSelectCellStateDisable,
    RCDGroupMemberSelectCellStateUnselected,
    RCDGroupMemberSelectCellStateSelected,
};
@interface RCDGroupMemberSelectCell : RCDTableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
- (void)setDataModel:(NSString *)userId groupId:(NSString *)groupId;
- (void)setCellSelectState:(RCDGroupMemberSelectCellState)state;
@end

NS_ASSUME_NONNULL_END
