//
//  RCDGroupConversationCell.m
//  SealTalk
//
//  Created by 张改红 on 2019/7/19.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDGroupConversationCell.h"
#import "RCDGroupManager.h"
#import "RCDCommonString.h"
#import "RCDUserInfoManager.h"
#import "RCDUtilities.h"
@interface RCDGroupConversationCell ()
@property (nonatomic, strong) RCDGroupNotice *notice;
@end
@implementation RCDGroupConversationCell
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    RCDGroupConversationCell *cell =
        (RCDGroupConversationCell *)[tableView dequeueReusableCellWithIdentifier:RCDGroupConversationCellIdentifier];
    if (!cell) {
        cell = [[RCDGroupConversationCell alloc] init];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateGroupNotice)
                                                     name:RCDGroupNoticeUpdateKey
                                                   object:nil];
    }
    return self;
}

- (void)setDataModel:(RCConversationModel *)model {
    model.unreadMessageCount = [RCDGroupManager getGroupNoticeUnreadCount];
    [super setDataModel:model];
    self.hideSenderName = YES;
    UIImageView *imageView = (UIImageView *)self.headerImageView;
    imageView.image = [UIImage imageNamed:@"group_notice"];
    self.conversationTitle.text = RCDLocalizedString(@"GroupNoti");
    [self updateGroupNotice];
}

- (void)updateGroupNotice {
    NSArray *array = [RCDGroupManager getGroupNoticeList];
    if (array.count > 0) {
        self.notice = array[0];
        [self setContentInfo];
    }
    [self.bubbleTipView setBubbleTipNumber:(int)[RCDGroupManager getGroupNoticeUnreadCount]];
}

- (void)setContentInfo {
    if (self.notice.noticeType == RCDGroupNoticeTypeManagerApproving) {
        RCDGroupInfo *group = [RCDGroupManager getGroupInfo:self.notice.groupId];
        if (!group) {
            [RCDGroupManager getGroupInfoFromServer:self.notice.groupId
                                           complete:^(RCDGroupInfo *groupInfo) {
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   if (!groupInfo) {
                                                       RCDGroupInfo *groupInfo = [[RCDGroupInfo alloc] init];
                                                       groupInfo.groupId = self.notice.groupId;
                                                       groupInfo.groupName =
                                                           [NSString stringWithFormat:@"group<%@>", groupInfo.groupId];
                                                       [self setGroupInfo:groupInfo];
                                                   }
                                                   [self setGroupInfo:groupInfo];
                                               });
                                           }];
        } else {
            [self setGroupInfo:group];
        }
    }
    [self setUserInfo];
}

- (void)setGroupInfo:(RCDGroupInfo *)group {
    if (self.notice.noticeType == RCDGroupNoticeTypeManagerApproving) {
        self.detailContentView.messageContentLabel.text =
            [NSString stringWithFormat:RCDLocalizedString(@"RequestJoinGroup"), group.groupName];
    }
}

- (void)setUserInfo {
    if (self.notice.noticeType == RCDGroupNoticeTypeInviteeApproving) {
        [self getUserInfo:self.notice.operatorId
                 complete:^(RCDUserInfo *user) {
                     self.detailContentView.messageContentLabel.text =
                         [NSString stringWithFormat:RCDLocalizedString(@"InviteYouJoinGroup"), [RCKitUtility getDisplayName:user]];
                 }];
    }
}

- (void)getUserInfo:(NSString *)userId complete:(void (^)(RCDUserInfo *))completeBlock {
    RCDUserInfo *user = [RCDUserInfoManager getUserInfo:userId];
    if (!user) {
        [RCDUserInfoManager getUserInfoFromServer:userId
                                         complete:^(RCDUserInfo *userInfo) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 RCDFriendInfo *friend = [RCDUserInfoManager getFriendInfo:userId];
                                                 if (friend && friend.alias.length > 0) {
                                                     userInfo.alias = friend.alias;
                                                 }
                                                 completeBlock(userInfo);
                                             });
                                         }];
    } else {
        RCDFriendInfo *friend = [RCDUserInfoManager getFriendInfo:userId];
        if (friend && friend.displayName.length > 0) {
            user.alias = friend.displayName;
        }
        completeBlock(user);
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
