//
//  RCDForwardSelectedCell.m
//  SealTalk
//
//  Created by 孙浩 on 2019/6/17.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDForwardSelectedCell.h"
#import <Masonry/Masonry.h>
#import "UIColor+RCColor.h"
#import "RCDGroupManager.h"
#import "RCDUserInfoManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DefaultPortraitView.h"
#import "RCDUtilities.h"
@interface RCDForwardSelectedCell ()

@property (nonatomic, strong) UIButton *selectedButton;
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UILabel *conversationTitleLabel;

@end

@implementation RCDForwardSelectedCell

- (instancetype)init {

    if (self = [super init]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.selectedButton];
    [self.contentView addSubview:self.headerImageView];
    [self.contentView addSubview:self.conversationTitleLabel];

    [self.selectedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(12);
        make.height.width.offset(22);
    }];

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
}

- (void)setModel:(RCDForwardCellModel *)model {
    if (model.conversationType == ConversationType_GROUP) {
        RCDGroupInfo *group = [RCDGroupManager getGroupInfo:model.targetId];
        if (group) {
            [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:group.portraitUri]
                                    placeholderImage:[UIImage imageNamed:@"default_group_portrait"]];
            self.conversationTitleLabel.text = group.groupName;
        } else {
            [RCDGroupManager
                getGroupInfoFromServer:model.targetId
                              complete:^(RCDGroupInfo *groupInfo) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [self.headerImageView
                                          sd_setImageWithURL:[NSURL URLWithString:groupInfo.portraitUri]
                                            placeholderImage:[UIImage imageNamed:@"default_group_portrait"]];
                                      self.conversationTitleLabel.text = groupInfo.groupName;
                                  });
                              }];
        }
    } else if (model.conversationType == ConversationType_PRIVATE) {
        RCUserInfo *currentUserInfo = [RCIM sharedRCIM].currentUserInfo;
        if ([model.targetId isEqualToString:currentUserInfo.userId]) {
            if (currentUserInfo) {
                if (currentUserInfo.portraitUri.length <= 0) {
                    self.headerImageView.image =
                        [DefaultPortraitView portraitView:currentUserInfo.userId name:currentUserInfo.name];
                } else {
                    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:currentUserInfo.portraitUri]
                                            placeholderImage:[UIImage imageNamed:@"default_portrait_msg"]];
                }
                self.conversationTitleLabel.text = currentUserInfo.name;
            }
        } else {
            RCDFriendInfo *friend = [RCDUserInfoManager getFriendInfo:model.targetId];
            if (friend) {
                [self setFriendInfo:friend];
            } else {
                [RCDUserInfoManager getFriendInfoFromServer:model.targetId
                                                   complete:^(RCDFriendInfo *friendInfo) {
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           [self setFriendInfo:friendInfo];
                                                       });
                                                   }];
            }
        }
    }
}

- (void)setFriendInfo:(RCDFriendInfo *)friendInfo {
    if (friendInfo) {
        if (friendInfo.portraitUri.length <= 0) {
            self.headerImageView.image = [DefaultPortraitView portraitView:friendInfo.userId name:friendInfo.name];
        } else {
            [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:friendInfo.portraitUri]
                                    placeholderImage:[UIImage imageNamed:@"default_portrait_msg"]];
        }
        self.conversationTitleLabel.text = friendInfo.displayName.length > 0 ? friendInfo.displayName : friendInfo.name;
    }
}

- (void)setGroupInfo:(RCDGroupInfo *)groupInfo {
    if (groupInfo) {
        if (groupInfo.portraitUri.length <= 0) {
            self.headerImageView.image = [DefaultPortraitView portraitView:groupInfo.groupId name:groupInfo.groupName];
        } else {
            [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:groupInfo.portraitUri]
                                    placeholderImage:[UIImage imageNamed:@"default_group_portrait"]];
        }
        self.conversationTitleLabel.text = [NSString stringWithFormat:@"%@(%@)", groupInfo.groupName, groupInfo.number];
    }
}

- (void)setSelectStatus:(RCDForwardSelectedStatus)selectStatus {

    _selectStatus = selectStatus;
    if (selectStatus == RCDForwardSelectedStatusSingleSelect) {
        self.selectedButton.hidden = YES;
        [self.headerImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(12);
            make.top.equalTo(self.contentView).offset(7.5);
            make.height.width.offset(40);
        }];
    } else {
        self.selectedButton.hidden = NO;
        if (selectStatus == RCDForwardSelectedStatusMultiUnSelected) {
            self.selectedButton.selected = NO;
        } else {
            self.selectedButton.selected = YES;
        }
        [self.selectedButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(12);
            make.height.width.offset(22);
        }];
        [self.headerImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.selectedButton.mas_right).offset(12);
            make.top.equalTo(self.contentView).offset(7.5);
            make.height.width.offset(40);
        }];
    }
}

- (void)setCanSelect:(BOOL)canSelect {
    self.selectedButton.enabled = canSelect;
    UIImage *normalImage =
        canSelect ? [UIImage imageNamed:@"forward_unselected"] : [UIImage imageNamed:@"not_selected"];
    [_selectedButton setImage:normalImage forState:UIControlStateNormal];
}

- (UIButton *)selectedButton {
    if (!_selectedButton) {
        _selectedButton = [[UIButton alloc] init];
        _selectedButton.userInteractionEnabled = NO;
        [_selectedButton setImage:[UIImage imageNamed:@"forward_unselected"] forState:UIControlStateNormal];
        [_selectedButton setImage:[UIImage imageNamed:@"forward_selected"] forState:UIControlStateSelected];
    }
    return _selectedButton;
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
        _conversationTitleLabel.font = [UIFont systemFontOfSize:16];
        _conversationTitleLabel.textColor = RCDDYCOLOR(0x262626, 0x9f9f9f);
    }
    return _conversationTitleLabel;
}

@end
