//
//  RCDHaveSelectedCell.m
//  SealTalk
//
//  Created by 孙浩 on 2019/6/18.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDHaveSelectedCell.h"
#import <Masonry/Masonry.h>
#import "UIColor+RCColor.h"
#import "RCDGroupManager.h"
#import "RCDUserInfoManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DefaultPortraitView.h"
#import "RCDUtilities.h"
@interface RCDHaveSelectedCell ()

@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UILabel *conversationTitleLabel;
@property (nonatomic, strong) UIButton *deleteButton;

@end

@implementation RCDHaveSelectedCell
- (instancetype)init {

    if (self = [super init]) {
        [self setupViews];
    }
    return self;
}

- (void)setModel:(RCDForwardCellModel *)model {
    _model = model;
    if (model.conversationType == ConversationType_GROUP) {
        RCDGroupInfo *groupInfo = [RCDGroupManager getGroupInfo:model.targetId];
        if (groupInfo) {
            if (groupInfo.portraitUri.length <= 0) {
                self.headerImageView.image =
                    [DefaultPortraitView portraitView:groupInfo.groupId name:groupInfo.groupName];
            } else {
                [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:groupInfo.portraitUri]
                                        placeholderImage:[UIImage imageNamed:@"default_group_portrait"]];
            }
            self.conversationTitleLabel.text = groupInfo.groupName;
        }
    } else if (model.conversationType == ConversationType_PRIVATE) {
        RCUserInfo *currentUserInfo = [RCIM sharedRCIM].currentUserInfo;
        if ([model.targetId isEqualToString:currentUserInfo.userId]) {
            [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:currentUserInfo.portraitUri]
                                    placeholderImage:[UIImage imageNamed:@"default_portrait_msg"]];
            self.conversationTitleLabel.text = currentUserInfo.name;
        } else {
            RCDFriendInfo *friendInfo = [RCDUserInfoManager getFriendInfo:model.targetId];
            if (friendInfo) {
                if (friendInfo.portraitUri.length <= 0) {
                    self.headerImageView.image =
                        [DefaultPortraitView portraitView:friendInfo.userId name:friendInfo.name];
                } else {
                    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:friendInfo.portraitUri]
                                            placeholderImage:[UIImage imageNamed:@"default_portrait_msg"]];
                }
                self.conversationTitleLabel.text =
                    friendInfo.displayName.length > 0 ? friendInfo.displayName : friendInfo.name;
            }
        }
    }
}

- (void)deleteAction {
    if (self.deleteButtonBlock) {
        self.deleteButtonBlock(self.model);
    }
}

- (void)setupViews {

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.headerImageView];
    [self.contentView addSubview:self.conversationTitleLabel];
    [self.contentView addSubview:self.deleteButton];

    [self.headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(12);
        make.top.equalTo(self.contentView).offset(7.5);
        make.height.width.offset(40);
    }];

    [self.conversationTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerImageView.mas_right).offset(9);
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-12);
        make.height.offset(24);
    }];

    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-12);
        make.height.width.offset(22);
    }];
}

- (UIImageView *)headerImageView {
    if (!_headerImageView) {
        _headerImageView = [[UIImageView alloc] init];
    }
    return _headerImageView;
}

- (UILabel *)conversationTitleLabel {
    if (!_conversationTitleLabel) {
        _conversationTitleLabel = [[UILabel alloc] init];
        _conversationTitleLabel.backgroundColor = [UIColor clearColor];
        _conversationTitleLabel.font = [UIFont systemFontOfSize:17];
        _conversationTitleLabel.textColor = RCDDYCOLOR(0x262626, 0x9f9f9f);
    }
    return _conversationTitleLabel;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [[UIButton alloc] init];
        [_deleteButton setImage:[UIImage imageNamed:@"forward_delete"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

@end
