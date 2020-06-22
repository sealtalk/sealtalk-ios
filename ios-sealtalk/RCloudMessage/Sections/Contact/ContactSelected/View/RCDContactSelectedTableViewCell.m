//
//  RCDContactSelectedTableViewCell.m
//  RCloudMessage
//
//  Created by Jue on 16/3/17.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDContactSelectedTableViewCell.h"
#import "RCDFriendInfo.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <RongIMKit/RongIMKit.h>
#import <Masonry/Masonry.h>
#import "RCDUserInfoManager.h"
#import "RCDUtilities.h"
#define CellHeight 70.0f

@implementation RCDContactSelectedTableViewCell

#pragma mark - Life Cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        [self initSubviews];
    }
    return self;
}

#pragma mark - Private Method
- (void)initSubviews {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.selectedImageView];
    [self.contentView addSubview:self.portraitImageView];
    [self.contentView addSubview:self.nicknameLabel];

    [self.selectedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(27);
        make.centerY.equalTo(self.contentView);
        make.height.width.offset(21);
    }];

    [self.portraitImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.selectedImageView.mas_right).offset(8);
        make.centerY.equalTo(self.contentView);
        make.height.width.offset(40);
    }];

    [self.nicknameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.portraitImageView.mas_right).offset(8);
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-27);
        make.height.offset(CellHeight - 15 - 17);
    }];
}

#pragma mark - Public Method
+ (CGFloat)cellHeight {
    return CellHeight;
}

- (void)setModel:(RCDFriendInfo *)user {
    if (user) {
        if (self.groupId.length > 0) {
            __weak typeof(self) weakSelf = self;
            [RCDUtilities getGroupUserDisplayInfo:user.userId
                                          groupId:self.groupId
                                           result:^(RCUserInfo *user) {
                                               weakSelf.nicknameLabel.text = user.name;
                                               [weakSelf.portraitImageView
                                                   sd_setImageWithURL:[NSURL URLWithString:user.portraitUri]
                                                     placeholderImage:[UIImage imageNamed:@"contact"]];
                                           }];
        } else {
            __weak typeof(self) weakSelf = self;
            [RCDUtilities getUserDisplayInfo:user.userId
                                    complete:^(RCUserInfo *user) {
                                        weakSelf.nicknameLabel.text = user.name;
                                        [weakSelf.portraitImageView
                                            sd_setImageWithURL:[NSURL URLWithString:user.portraitUri]
                                              placeholderImage:[UIImage imageNamed:@"contact"]];
                                    }];
        }
    }
}

#pragma mark - Override
- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        _selectedImageView.image = [UIImage imageNamed:@"select"];
    } else {
        _selectedImageView.image = [UIImage imageNamed:@"unselected_full"];
    }
    // Configure the view for the selected state
}

#pragma mark - Setter && Getter
- (UIImageView *)selectedImageView {
    if (!_selectedImageView) {
        _selectedImageView = [[UIImageView alloc] init];
        _selectedImageView.image = [UIImage imageNamed:@"unselected_full"];
    }
    return _selectedImageView;
}

- (UIImageView *)portraitImageView {
    if (!_portraitImageView) {
        _portraitImageView = [[UIImageView alloc] init];
        if ([RCIM sharedRCIM].globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
            [RCIM sharedRCIM].globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
            _portraitImageView.layer.cornerRadius = 20.f;
        } else {
            _portraitImageView.layer.cornerRadius = 5.f;
        }
        _portraitImageView.layer.masksToBounds = YES;
        _portraitImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _portraitImageView;
}

- (UILabel *)nicknameLabel {
    if (!_nicknameLabel) {
        _nicknameLabel = [[UILabel alloc] init];
        _nicknameLabel.font = [UIFont fontWithName:@"Heiti SC" size:14.0];
        _nicknameLabel.textColor = RCDDYCOLOR(0x000000, 0x9f9f9f);
    }
    return _nicknameLabel;
}
@end
