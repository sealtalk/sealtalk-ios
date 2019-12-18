//
//  RCDGroupLeftUserListCell.m
//  SealTalk
//
//  Created by 张改红 on 2019/8/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDGroupLeftUserListCell.h"
#import <Masonry/Masonry.h>
#import "RCDUserInfoManager.h"
#import <SDWebImage/SDWebImage.h>
#import <RongIMKit/RongIMKit.h>
#import "RCDUtilities.h"

@interface RCDGroupLeftUserListCell ()
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *portraitImageView;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) RCDGroupLeftMember *model;
@property (nonatomic, strong) NSString *groupId;
@end
@implementation RCDGroupLeftUserListCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    RCDGroupLeftUserListCell *cell =
        (RCDGroupLeftUserListCell *)[tableView dequeueReusableCellWithIdentifier:RCDGroupLeftUserListCellIdentifier];
    if (!cell) {
        cell = [[RCDGroupLeftUserListCell alloc] init];
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

- (void)setDataModel:(RCDGroupLeftMember *)model groupId:(nonnull NSString *)groupId {
    self.model = model;
    [self setUserInfo];
    self.timeLabel.text = [RCKitUtility ConvertMessageTime:model.time / 1000];
}

- (void)setUserInfo {
    [RCDUtilities getGroupUserDisplayInfo:self.model.userId
                                  groupId:self.groupId
                                   result:^(RCUserInfo *user) {
                                       self.nameLabel.text = user.name;
                                       if (user.portraitUri.length == 0) {
                                           user.portraitUri = [RCDUtilities defaultUserPortrait:user];
                                       }
                                       [self.portraitImageView sd_setImageWithURL:[NSURL URLWithString:user.portraitUri]
                                                                 placeholderImage:[UIImage imageNamed:@"contact"]];
                                   }];
    if (self.model.reason != RCDGroupMemberLeftReasonSelf) {
        [RCDUtilities
            getGroupUserDisplayInfo:self.model.operatorId
                            groupId:self.groupId
                             result:^(RCUserInfo *user) {
                                 if (self.model.reason == RCDGroupMemberLeftReasonManager) {
                                     self.infoLabel.text = [NSString
                                         stringWithFormat:RCDLocalizedString(@"KickGroupByManager"), user.name];
                                 } else if (self.model.reason == RCDGroupMemberLeftReasonOwner) {
                                     self.infoLabel.text =
                                         [NSString stringWithFormat:RCDLocalizedString(@"KickGroupByOwner"), user.name];
                                 }
                             }];
    } else {
        self.infoLabel.text = RCDLocalizedString(@"KickGroupBySelf");
    }
}

- (void)addSubviews {
    [self.contentView addSubview:self.portraitImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.infoLabel];

    [self.portraitImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(12);
        make.height.width.offset(40);
    }];

    [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.portraitImageView);
        make.left.equalTo(self.portraitImageView.mas_right).offset(9);
        make.right.equalTo(self.contentView).offset(-12);
        make.height.offset(24);
    }];

    [self.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-10);
        make.top.equalTo(self.infoLabel);
        make.height.offset(17);
    }];

    [self.infoLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.portraitImageView);
        make.left.equalTo(self.portraitImageView.mas_right).offset(9);
        make.right.equalTo(self.timeLabel.mas_left).offset(-9);
        make.height.offset(17);
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
        _nameLabel.font = [UIFont systemFontOfSize:17];
        _nameLabel.textColor = RCDDYCOLOR(0x262626, 0x9f9f9f);
    }
    return _nameLabel;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.font = [UIFont systemFontOfSize:12];
        _infoLabel.textColor = HEXCOLOR(0x999999);
    }
    return _infoLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.textColor = HEXCOLOR(0x999999);
    }
    return _timeLabel;
}
@end
