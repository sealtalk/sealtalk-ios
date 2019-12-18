//
//  RCDGroupMemberCell.h
//  SealTalk
//
//  Created by 张改红 on 2019/6/18.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDTableViewCell.h"
@class RCUserInfo;
NS_ASSUME_NONNULL_BEGIN
static NSString *RCDGroupMemberCellIdentifier = @"RCDGroupMemberCellIdentifier";

@interface RCDGroupMemberCell : RCDTableViewCell
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *portraitImageView;
+ (instancetype)cellWithTableView:(UITableView *)tableView;
- (void)setDataModel:(NSString *)userId groupId:(NSString *)groupId;
- (void)setUserRole:(NSString *)role;
@end

NS_ASSUME_NONNULL_END
