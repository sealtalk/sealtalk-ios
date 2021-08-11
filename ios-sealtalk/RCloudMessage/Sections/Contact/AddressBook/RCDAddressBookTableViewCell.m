//
//  RCDAddressBookTableViewCell.m
//  RCloudMessage
//
//  Created by Liv on 15/3/13.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDAddressBookTableViewCell.h"
#import "DefaultPortraitView.h"
#import "RCDCommonDefine.h"
#import "RCDFriendInfo.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <RongIMKit/RongIMKit.h>
#import <Masonry/Masonry.h>
#import "RCDUtilities.h"
#define CellHeight 65.0f

@interface RCDAddressBookTableViewCell ()
/**
 *  昵称
 */
@property (nonatomic, strong) UILabel *nameLabel;

/**
 *  头像
 */
@property (nonatomic, strong) UIImageView *portraitImageView;

/**
 *  “已接受”、“已邀请”
 */
@property (nonatomic, strong) UILabel *rightLabel;

/**
 *  右箭头
 */
@property (nonatomic, strong) UIImageView *arrowImgView;

/**
 *  “接受”按钮
 */
@property (nonatomic, strong) UIButton *acceptBtn;

@property (nonatomic, strong) UIButton *ignoreButton;

@property (nonatomic, strong) RCDFriendInfo *currentUserInfo;

@end

@implementation RCDAddressBookTableViewCell

#pragma mark - Life Cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        [self initSubviews];
    }
    return self;
}

#pragma mark - Public Method
- (void)setModel:(RCDFriendInfo *)user {
    self.currentUserInfo = user;
    if (user) {
        self.nameLabel.text = [RCKitUtility getDisplayName:user];
        if ([user.portraitUri isEqualToString:@""]) {
            UIImage *portrait = [DefaultPortraitView portraitView:user.userId name:user.name];
            self.portraitImageView.image = portrait;
        } else {
            [self.portraitImageView sd_setImageWithURL:[NSURL URLWithString:user.portraitUri]
                                      placeholderImage:[UIImage imageNamed:@"contact"]];
        }
    }

    if (user.status == RCDFriendStatusRequest) {
        self.rightLabel.text = RCDLocalizedString(@"had_invite");
        self.selected = NO;
        self.arrowImgView.hidden = YES;
        self.acceptBtn.hidden = YES;
        self.ignoreButton.hidden = YES;
    } else if (user.status == RCDFriendStatusRequested) {
        self.selected = NO;
        self.acceptBtn.hidden = NO;
        self.ignoreButton.hidden = NO;
        self.arrowImgView.hidden = YES;
    } else if (user.status == RCDFriendStatusAgree) {
        self.rightLabel.text = RCDLocalizedString(@"had_accept");
        self.acceptBtn.hidden = YES;
        self.ignoreButton.hidden = YES;
        self.arrowImgView.hidden = NO;
    } else if (user.status == RCDFriendStatusIgnore || user.status == RCDFriendStatusDelete) {
        NSString *string =
            user.status == RCDFriendStatusIgnore ? RCDLocalizedString(@"Ignored") : RCDLocalizedString(@"HadDelete");
        self.rightLabel.text = string;
        self.acceptBtn.hidden = YES;
        self.ignoreButton.hidden = YES;
        self.arrowImgView.hidden = YES;
    } else {
        self.rightLabel.text = RCDLocalizedString(@"had_accept");
        self.acceptBtn.hidden = YES;
        self.ignoreButton.hidden = YES;
        self.arrowImgView.hidden = YES;
    }
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

+ (CGFloat)cellHeight {
    return CellHeight;
}

#pragma mark - Private Method
- (void)initSubviews {
    [self.contentView addSubview:self.portraitImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.rightLabel];
    [self.contentView addSubview:self.arrowImgView];
    [self.contentView addSubview:self.acceptBtn];
    [self.contentView addSubview:self.ignoreButton];

    [self.portraitImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(22);
        make.height.width.offset(36);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.portraitImageView.mas_right).offset(8);
        make.width.offset(150);
        make.height.offset(21);
    }];

    [self.arrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-8);
        make.centerY.equalTo(self.contentView);
        make.width.offset(15);
        make.height.offset(CellHeight - 19.5 - 19 - 8 - 8);
    }];

    [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.arrowImgView.mas_left).offset(-5);
        make.centerY.equalTo(self.contentView);
        make.width.offset(80);
        make.height.offset(CellHeight - 16.5 - 16);
    }];

    [self.ignoreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.acceptBtn.mas_left).offset(-10);
        make.height.offset(CellHeight - 16.5 - 16 - 8);
    }];

    [self.acceptBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-8);
        make.height.offset(CellHeight - 16.5 - 16 - 8);
    }];
}

- (void)doAccept {
    if (self.acceptBlock) {
        self.acceptBlock(self.currentUserInfo.userId);
    }
}

- (void)doIgnore {
    if (self.ignoreBlock) {
        self.ignoreBlock(self.currentUserInfo.userId);
    }
}

#pragma mark - Setter && Getter
- (UIImageView *)portraitImageView {
    if (!_portraitImageView) {
        _portraitImageView = [[UIImageView alloc] init];
        if (RCKitConfigCenter.ui.globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
            RCKitConfigCenter.ui.globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
            _portraitImageView.layer.cornerRadius = 18.f;
        } else {
            _portraitImageView.layer.cornerRadius = 5.f;
        }
        _portraitImageView.layer.masksToBounds = YES;
        _portraitImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _portraitImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:17];
        _nameLabel.textColor = RCDDYCOLOR(0x000000, 0x9f9f9f);
    }
    return _nameLabel;
}

- (UIImageView *)arrowImgView {
    if (!_arrowImgView) {
        _arrowImgView = [[UIImageView alloc] init];
        _arrowImgView.image = [UIImage imageNamed:@"grayarrow"];
    }
    return _arrowImgView;
}

- (UILabel *)rightLabel {
    if (!_rightLabel) {
        _rightLabel = [[UILabel alloc] init];
        _rightLabel.font = [UIFont systemFontOfSize:14];
        _rightLabel.textAlignment = NSTextAlignmentRight;
        _rightLabel.textColor = RCDDYCOLOR(0x000000, 0x9f9f9f);
    }
    return _rightLabel;
}

- (UIButton *)acceptBtn {
    if (!_acceptBtn) {
        _acceptBtn = [[UIButton alloc] init];
        [_acceptBtn setTitle:RCDLocalizedString(@"Agree") forState:(UIControlStateNormal)];
        [_acceptBtn setTitleColor:HEXCOLOR(0x3098fc) forState:(UIControlStateNormal)];
        [_acceptBtn addTarget:self action:@selector(doAccept) forControlEvents:(UIControlEventTouchUpInside)];
        _acceptBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _acceptBtn;
}

- (UIButton *)ignoreButton {
    if (!_ignoreButton) {
        _ignoreButton = [[UIButton alloc] init];
        [_ignoreButton setTitle:RCDLocalizedString(@"Ignore") forState:(UIControlStateNormal)];
        [_ignoreButton setTitleColor:RCDDYCOLOR(0x333333, 0x9f9f9f) forState:(UIControlStateNormal)];
        [_ignoreButton addTarget:self action:@selector(doIgnore) forControlEvents:(UIControlEventTouchUpInside)];
        _ignoreButton.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _ignoreButton;
}

@end
