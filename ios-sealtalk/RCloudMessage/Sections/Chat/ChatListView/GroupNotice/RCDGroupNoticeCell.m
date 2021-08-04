//
//  RCDGroupNoticeCell.m
//  SealTalk
//
//  Created by 张改红 on 2019/7/9.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDGroupNoticeCell.h"
#import <Masonry/Masonry.h>
#import "RCDGroupManager.h"
#import "RCDUserInfoManager.h"
#import <SDWebImage/SDWebImage.h>
#import <RongIMKit/RongIMKit.h>
#import "RCDUtilities.h"

@interface RCDGroupNoticeCell ()
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *portraitImageView;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *agreeButton;
@property (nonatomic, strong) UIButton *ignoreButton;
@property (nonatomic, strong) UILabel *statusLabel;

@property (nonatomic, strong) RCDGroupNotice *notice;
@end
@implementation RCDGroupNoticeCell
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    RCDGroupNoticeCell *cell =
        (RCDGroupNoticeCell *)[tableView dequeueReusableCellWithIdentifier:RCDGroupNoticeCellIdentifier];
    if (!cell) {
        cell = [[RCDGroupNoticeCell alloc] init];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubviews];
    }
    return self;
}

- (void)setDataModel:(RCDGroupNotice *)model {
    self.notice = model;
    RCDGroupInfo *group = [RCDGroupManager getGroupInfo:model.groupId];
    if (!group) {
        [RCDGroupManager getGroupInfoFromServer:model.groupId
                                       complete:^(RCDGroupInfo *groupInfo) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               if (groupInfo) {
                                                   [self setGroupInfo:groupInfo];
                                               }
                                           });
                                       }];
    } else {
        [self setGroupInfo:group];
    }

    [self setUserInfo];
    [self setStatusInfo];
    self.timeLabel.text = [RCKitUtility ConvertMessageTime:self.notice.createTime / 1000];
}

- (void)reloadCell:(RCDGroupInviteStatus)status {
    self.notice.status = status;
    [self setStatusInfo];
}

- (void)getUserInfo:(NSString *)userId complete:(void (^)(RCDUserInfo *))completeBlock {
    RCDUserInfo *user = [RCDUserInfoManager getUserInfo:userId];
    if (!user) {
        [RCDUserInfoManager getUserInfoFromServer:userId
                                         complete:^(RCDUserInfo *userInfo) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 RCDFriendInfo *friend = [RCDUserInfoManager getFriendInfo:userId];
                                                 if (friend && friend.displayName.length > 0) {
                                                     userInfo.name = friend.displayName;
                                                 }
                                                 completeBlock(userInfo);
                                             });
                                         }];
    } else {
        RCDFriendInfo *friend = [RCDUserInfoManager getFriendInfo:userId];
        if (friend && friend.displayName.length > 0) {
            user.name = friend.displayName;
        }
        completeBlock(user);
    }
}

- (void)setStatusInfo {
    if (self.notice.status == RCDGroupInviteStatusIgnored) {
        [self setStatusLabelHidden:NO];
        self.statusLabel.text = RCDLocalizedString(@"Ignored");
    } else if (self.notice.status == RCDGroupInviteStatusAgreed) {
        [self setStatusLabelHidden:NO];
        self.statusLabel.text = RCDLocalizedString(@"Agreed");
    } else if (self.notice.status == RCDGroupInviteStatusApproving) {
        [self setStatusLabelHidden:YES];
    } else if (self.notice.status == RCDGroupInviteStatusExpired) {
        [self setStatusLabelHidden:NO];
        self.statusLabel.text = RCDLocalizedString(@"Expired");
    }
}

- (void)setGroupInfo:(RCDGroupInfo *)group {
    if (self.notice.noticeType == RCDGroupNoticeTypeInviteeApproving) {
        self.nameLabel.text = group.groupName;
        if (group.portraitUri.length == 0) {
            group.portraitUri = [RCDUtilities defaultGroupPortrait:group];
        }
        [self.portraitImageView
            sd_setImageWithURL:[NSURL URLWithString:group.portraitUri]
              placeholderImage:[RCKitUtility imageNamed:@"default_group_portrait" ofBundle:@"RongCloud.bundle"]];
    } else if (self.notice.noticeType == RCDGroupNoticeTypeManagerApproving) {
        self.infoLabel.text = [NSString stringWithFormat:RCDLocalizedString(@"RequestJoinGroup"), group.groupName];
    }
}

- (void)setUserInfo {
    if (self.notice.noticeType == RCDGroupNoticeTypeInviteeApproving) {
        [self getUserInfo:self.notice.operatorId
                 complete:^(RCDUserInfo *user) {
                     self.infoLabel.text =
                         [NSString stringWithFormat:RCDLocalizedString(@"InviteYouJoinGroup"), user.name];
                 }];
    } else if (self.notice.noticeType == RCDGroupNoticeTypeManagerApproving) {
        [self getUserInfo:self.notice.targetId
                 complete:^(RCDUserInfo *user) {
                     self.nameLabel.text = user.name;
                     if (user.portraitUri.length == 0) {
                         user.portraitUri = [RCDUtilities defaultUserPortrait:user];
                     }
                     [self.portraitImageView sd_setImageWithURL:[NSURL URLWithString:user.portraitUri]
                                               placeholderImage:[UIImage imageNamed:@"contact"]];
                 }];
    }
}

- (void)didClickAgreeButton {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickAgreeButton:)]) {
        [self.delegate didClickAgreeButton:self];
    }
}

- (void)didClickIgnoreButton {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickIgnoreButton:)]) {
        [self.delegate didClickIgnoreButton:self];
    }
}

- (void)setStatusLabelHidden:(BOOL)hidden {
    self.agreeButton.hidden = !hidden;
    self.ignoreButton.hidden = !hidden;
    self.agreeButton.enabled = hidden;
    self.ignoreButton.enabled = hidden;
    self.statusLabel.hidden = hidden;
}

- (void)addSubviews {
    [self.contentView addSubview:self.portraitImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.infoLabel];
    [self.contentView addSubview:self.statusLabel];
    [self.contentView addSubview:self.agreeButton];
    [self.contentView addSubview:self.ignoreButton];

    [self.portraitImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(10);
        make.height.width.offset(46);
    }];

    [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.portraitImageView).offset(2);
        make.left.equalTo(self.portraitImageView.mas_right).offset(9);
        make.height.offset(20);
        make.width.offset(200);
    }];

    [self.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-10);
        make.top.equalTo(self.nameLabel);
        make.height.offset(17);
    }];

    [self.infoLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.portraitImageView);
        make.left.equalTo(self.portraitImageView.mas_right).offset(9);
        make.height.offset(20);
        make.width.offset([UIScreen mainScreen].bounds.size.width - 200);
    }];

    [self.agreeButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.timeLabel);
        make.bottom.equalTo(self.contentView).offset(-5);
        make.height.offset(30);
    }];

    [self.ignoreButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.agreeButton.mas_left).offset(-40);
        make.bottom.equalTo(self.agreeButton);
        make.height.offset(30);
    }];

    [self.statusLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.timeLabel);
        make.bottom.equalTo(self.agreeButton);
        make.height.offset(30);
    }];
}
#pragma mark - getter
- (UIImageView *)portraitImageView {
    if (!_portraitImageView) {
        _portraitImageView = [[UIImageView alloc] init];
        _portraitImageView.layer.cornerRadius = 2.f;
        _portraitImageView.layer.masksToBounds = YES;
        _portraitImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _portraitImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textColor = RCDDYCOLOR(0x333333, 0x9f9f9f);
    }
    return _nameLabel;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.font = [UIFont systemFontOfSize:14];
        _infoLabel.textColor = RCDDYCOLOR(0x999999, 0x707070);
    }
    return _infoLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.textColor = RCDDYCOLOR(0x9b9b9b, 0x707070);
    }
    return _timeLabel;
}

- (UIButton *)agreeButton {
    if (!_agreeButton) {
        _agreeButton = [[UIButton alloc] init];
        [_agreeButton setTitle:RCDLocalizedString(@"Agree") forState:(UIControlStateNormal)];
        [_agreeButton setTitleColor:HEXCOLOR(0x3098fc) forState:(UIControlStateNormal)];
        [_agreeButton addTarget:self
                         action:@selector(didClickAgreeButton)
               forControlEvents:(UIControlEventTouchUpInside)];
        _agreeButton.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _agreeButton;
}

- (UIButton *)ignoreButton {
    if (!_ignoreButton) {
        _ignoreButton = [[UIButton alloc] init];
        [_ignoreButton setTitle:RCDLocalizedString(@"Ignore") forState:(UIControlStateNormal)];
        [_ignoreButton setTitleColor:RCDDYCOLOR(0x333333, 0x9f9f9f) forState:(UIControlStateNormal)];
        [_ignoreButton addTarget:self
                          action:@selector(didClickIgnoreButton)
                forControlEvents:(UIControlEventTouchUpInside)];
        _ignoreButton.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _ignoreButton;
}

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.font = [UIFont systemFontOfSize:14];
        _statusLabel.textAlignment = NSTextAlignmentRight;
        _statusLabel.textColor = RCDDYCOLOR(0x999999, 0x707070);
    }
    return _statusLabel;
}

@end
