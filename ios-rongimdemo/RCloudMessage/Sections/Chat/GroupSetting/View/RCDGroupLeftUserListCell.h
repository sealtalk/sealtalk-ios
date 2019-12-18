//
//  RCDGroupLeftUserListCell.h
//  SealTalk
//
//  Created by 张改红 on 2019/8/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDTableViewCell.h"
#import "RCDGroupLeftMember.h"
NS_ASSUME_NONNULL_BEGIN
static NSString *RCDGroupLeftUserListCellIdentifier = @"RCDGroupLeftUserListCellIdentifier";
@interface RCDGroupLeftUserListCell : RCDTableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
- (void)setDataModel:(RCDGroupLeftMember *)model groupId:(NSString *)groupId;
@end

NS_ASSUME_NONNULL_END
