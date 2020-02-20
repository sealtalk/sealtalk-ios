//
//  RCDPersonInfoView.m
//  SealTalk
//
//  Created by 孙浩 on 2019/5/29.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDPersonInfoView.h"
#import "RCDFriendInfo.h"
#import <RongIMKit/RongIMKit.h>
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "RCDUtilities.h"
#import "DefaultPortraitView.h"

@interface RCDPersonInfoView ()

@property (nonatomic, strong) UIView *infoBgView;
@property (nonatomic, strong) UIImageView *portraitImgView;
@property (nonatomic, strong) UILabel *remarksLabel;
@property (nonatomic, strong) UILabel *stAccountLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *groupNicknameLabel;
@property (nonatomic, strong) UIImageView *genderImgView;

@property (nonatomic, strong) RCDFriendInfo *friendInfo;

@end

@implementation RCDPersonInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubviews];
    }
    return self;
}

#pragma mark - Public Method
- (void)setUserInfo:(RCDFriendInfo *)userInfo {
    self.friendInfo = userInfo;
    // todo：设置头像
    if ([userInfo.userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
        [self updateSubviewsWithHaveRemarks:NO];
        self.nameLabel.text = userInfo.name;
    } else {
        if (userInfo.displayName != nil && ![userInfo.displayName isEqualToString:@""]) {
            [self updateSubviewsWithHaveRemarks:YES];
            self.remarksLabel.text = userInfo.displayName;
            self.nameLabel.text = [NSString stringWithFormat:RCDLocalizedString(@"someone_nickname"), userInfo.name];
        } else {
            [self updateSubviewsWithHaveRemarks:NO];
            self.nameLabel.text = userInfo.name;
        }
    }
    if (userInfo.stAccount.length > 0 && ![userInfo.stAccount isEqualToString:@""]) {
        self.stAccountLabel.text =
            [NSString stringWithFormat:@"%@：%@", RCDLocalizedString(@"SealTalkNumber"), userInfo.stAccount];
    }
    if (!userInfo.portraitUri || userInfo.portraitUri.length <= 0) {
        self.portraitImgView.image = [DefaultPortraitView portraitView:userInfo.userId name:userInfo.name];
    } else {
        [self.portraitImgView sd_setImageWithURL:[NSURL URLWithString:userInfo.portraitUri]
                                placeholderImage:[UIImage imageNamed:@"icon_person"]];
    }
    if (userInfo.gender.length > 0) {
        self.genderImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"gender_%@", userInfo.gender]];
    } else {
        self.genderImgView.image = [UIImage imageNamed:@"gender_male"];
    }
    [self updateInfoViewLayout];
}

- (void)setGroupNickname:(NSString *)groupNickname {
    if (groupNickname.length > 0) {
        self.groupNicknameLabel.hidden = NO;
        self.groupNicknameLabel.text =
            [NSString stringWithFormat:@"%@：%@", RCDLocalizedString(@"GroupNickname"), groupNickname];
        [self updateInfoViewLayout];
    }
}

#pragma mark - Private Method
- (void)updateInfoViewLayout {
    if (!self.groupNicknameLabel.hidden) {
        if (self.remarksLabel.hidden) {
            if (self.stAccountLabel.hidden) {
                [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.infoBgView).offset(20);
                    make.left.equalTo(self.portraitImgView.mas_right).offset(10);
                    make.height.offset(16);
                    make.right.equalTo(self.genderImgView.mas_left).offset(-5);
                }];
            } else {
                [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.infoBgView).offset(14);
                    make.left.equalTo(self.portraitImgView.mas_right).offset(10);
                    make.height.offset(16);
                    make.right.equalTo(self.genderImgView.mas_left).offset(-5);
                }];
            }
            [self.groupNicknameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.stAccountLabel.mas_bottom).offset(4);
                make.left.equalTo(self.remarksLabel);
                make.right.equalTo(self.infoBgView);
                make.height.offset(16);
            }];
        } else {
            if (self.stAccountLabel.hidden) {
                [self.remarksLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.infoBgView).offset(14);
                    make.left.equalTo(self.portraitImgView.mas_right).offset(10);
                    make.height.offset(18);
                    make.right.equalTo(self.genderImgView.mas_left).offset(-5);
                }];
            } else {
                [self.remarksLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.infoBgView).offset(7);
                    make.left.equalTo(self.portraitImgView.mas_right).offset(10);
                    make.height.offset(18);
                    make.right.equalTo(self.genderImgView.mas_left).offset(-5);
                }];
            }
            [self.groupNicknameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.nameLabel.mas_bottom).offset(4);
                make.left.equalTo(self.remarksLabel);
                make.right.equalTo(self.infoBgView);
                make.height.offset(16);
            }];
        }
    }
}

- (void)updateSubviewsWithHaveRemarks:(BOOL)haveRemarks {
    self.remarksLabel.hidden = !haveRemarks;
    if (haveRemarks == YES) {
        self.nameLabel.font = [UIFont systemFontOfSize:14];
        self.nameLabel.textColor = [UIColor colorWithHexString:@"999999" alpha:1];
        [self.remarksLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.infoBgView).offset(14);
            make.left.equalTo(self.portraitImgView.mas_right).offset(10);
            make.height.offset(18);
            make.right.equalTo(self.genderImgView.mas_left).offset(-5);
        }];
        [self.genderImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.remarksLabel);
            make.left.equalTo(self.remarksLabel.mas_right).offset(5);
            make.height.width.equalTo(@15);
            make.right.lessThanOrEqualTo(self.infoBgView);
        }];

        if (self.friendInfo.stAccount.length > 0 && ![self.friendInfo.stAccount isEqualToString:@""]) {
            [self.stAccountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.remarksLabel.mas_bottom).offset(4);
                make.left.equalTo(self.remarksLabel);
                make.right.equalTo(self.infoBgView);
                make.height.offset(16);
            }];
        } else {
            [self.stAccountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.remarksLabel.mas_bottom).offset(4);
                make.left.equalTo(self.remarksLabel);
                make.right.equalTo(self.infoBgView);
                make.height.offset(0.1);
            }];
        }
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.stAccountLabel.mas_bottom).offset(4);
            make.left.equalTo(self.remarksLabel);
            make.right.equalTo(self.infoBgView);
            make.height.offset(16);
        }];
    } else {
        self.nameLabel.font = [UIFont systemFontOfSize:16];
        self.nameLabel.textColor = RCDDYCOLOR(0x000000, 0x9f9f9f);

        if (self.friendInfo.stAccount.length > 0 && ![self.friendInfo.stAccount isEqualToString:@""]) {
            self.stAccountLabel.hidden = NO;
            [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.infoBgView).offset(20);
                make.left.equalTo(self.portraitImgView.mas_right).offset(10);
                make.height.offset(18);
                make.right.equalTo(self.genderImgView.mas_left).offset(-5);
            }];

            [self.stAccountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.nameLabel.mas_bottom).offset(8);
                make.left.equalTo(self.remarksLabel);
                make.right.equalTo(self.infoBgView);
                make.height.offset(16);
            }];
        } else {
            self.stAccountLabel.hidden = YES;
            [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.infoBgView);
                make.left.equalTo(self.portraitImgView.mas_right).offset(10);
                make.height.offset(18);
                make.right.equalTo(self.genderImgView.mas_left).offset(-5);
            }];
        }

        [self.genderImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.nameLabel);
            make.left.equalTo(self.nameLabel.mas_right).offset(5);
            make.height.width.equalTo(@15);
            make.right.lessThanOrEqualTo(self.infoBgView);
        }];
    }
}

- (void)addSubviews {
    [self addSubview:self.infoBgView];
    [self.infoBgView addSubview:self.portraitImgView];
    [self.infoBgView addSubview:self.remarksLabel];
    [self.infoBgView addSubview:self.stAccountLabel];
    [self.infoBgView addSubview:self.nameLabel];
    [self.infoBgView addSubview:self.genderImgView];
    [self.infoBgView addSubview:self.groupNicknameLabel];

    [self.infoBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(self);
    }];

    [self.portraitImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.centerY.equalTo(self);
        make.width.height.offset(65);
    }];

    [self.remarksLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.infoBgView).offset(14);
        make.left.equalTo(self.portraitImgView.mas_right).offset(10);
        make.height.offset(16);
    }];

    [self.stAccountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.remarksLabel.mas_bottom).offset(4);
        make.left.equalTo(self.remarksLabel);
        make.right.equalTo(self.infoBgView);
        make.height.offset(16);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.stAccountLabel.mas_bottom).offset(3);
        make.left.equalTo(self.remarksLabel);
        make.right.equalTo(self.infoBgView);
        make.height.offset(16);
    }];

    [self.groupNicknameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).offset(4);
        make.left.equalTo(self.remarksLabel);
        make.right.equalTo(self.infoBgView);
        make.height.offset(16);
    }];

    [self.genderImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.remarksLabel);
        make.left.equalTo(self.remarksLabel.mas_right).offset(5);
        make.height.width.equalTo(@15);
    }];
}

#pragma mark - Getter && Setter
- (UIView *)infoBgView {
    if (!_infoBgView) {
        _infoBgView = [[UIView alloc] init];
        _infoBgView.backgroundColor =
            [RCDUtilities generateDynamicColor:HEXCOLOR(0xffffff)
                                     darkColor:[HEXCOLOR(0x1c1c1e) colorWithAlphaComponent:0.4]];
    }
    return _infoBgView;
}

- (UIImageView *)portraitImgView {
    if (!_portraitImgView) {
        _portraitImgView = [[UIImageView alloc] init];
        _portraitImgView.contentMode = UIViewContentModeScaleAspectFill;
        if ([RCIM sharedRCIM].globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
            [RCIM sharedRCIM].globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
            _portraitImgView.layer.cornerRadius = 30;
        } else {
            _portraitImgView.layer.cornerRadius = 5;
        }
        _portraitImgView.clipsToBounds = YES;
    }
    return _portraitImgView;
}

- (UILabel *)remarksLabel {
    if (!_remarksLabel) {
        _remarksLabel = [[UILabel alloc] init];
        _remarksLabel.font = [UIFont systemFontOfSize:16];
        _remarksLabel.textColor = RCDDYCOLOR(0x000000, 0x9f9f9f);
        _remarksLabel.hidden = YES;
    }
    return _remarksLabel;
}

- (UILabel *)stAccountLabel {
    if (!_stAccountLabel) {
        _stAccountLabel = [[UILabel alloc] init];
        _stAccountLabel.textColor = [UIColor colorWithHexString:@"999999" alpha:1];
        _stAccountLabel.font = [UIFont systemFontOfSize:14];
    }
    return _stAccountLabel;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textColor = RCDDYCOLOR(0x000000, 0x9f9f9f);
    }
    return _nameLabel;
}

- (UIImageView *)genderImgView {
    if (!_genderImgView) {
        _genderImgView = [[UIImageView alloc] init];
        _genderImgView.layer.cornerRadius = 15 / 2;
        _genderImgView.layer.masksToBounds = YES;
    }
    return _genderImgView;
}

- (UILabel *)groupNicknameLabel {
    if (!_groupNicknameLabel) {
        _groupNicknameLabel = [[UILabel alloc] init];
        _groupNicknameLabel.font = [UIFont systemFontOfSize:14];
        _groupNicknameLabel.textColor = [UIColor colorWithHexString:@"999999" alpha:1];
        _groupNicknameLabel.hidden = YES;
    }
    return _groupNicknameLabel;
}
@end
