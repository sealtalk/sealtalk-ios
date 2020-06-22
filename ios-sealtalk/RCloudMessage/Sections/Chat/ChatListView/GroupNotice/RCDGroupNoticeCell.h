//
//  RCDGroupNoticeCell.h
//  SealTalk
//
//  Created by 张改红 on 2019/7/9.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDTableViewCell.h"
#import "RCDGroupNotice.h"
@class RCDGroupNoticeCell;

static NSString *_Nullable RCDGroupNoticeCellIdentifier = @"RCDGroupNoticeCellIdentifier";

NS_ASSUME_NONNULL_BEGIN
@protocol RCDGroupNoticeCellDelegate <NSObject>

- (void)didClickAgreeButton:(RCDGroupNoticeCell *)cell;

- (void)didClickIgnoreButton:(RCDGroupNoticeCell *)cell;

@end
@interface RCDGroupNoticeCell : RCDTableViewCell
@property (nonatomic, weak) id<RCDGroupNoticeCellDelegate> delegate;
@property (nonatomic, strong, readonly) RCDGroupNotice *notice;
+ (instancetype)cellWithTableView:(UITableView *)tableView;
- (void)setDataModel:(RCDGroupNotice *)model;
- (void)reloadCell:(RCDGroupInviteStatus)status;
@end

NS_ASSUME_NONNULL_END
