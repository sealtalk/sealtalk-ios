//
//  RCDContactTableViewCell.m
//  RCloudMessage
//
//  Created by Jue on 16/3/16.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDContactTableViewCell.h"
#import "UIColor+RCColor.h"
#import <RongIMKit/RongIMKit.h>
#import <Masonry/Masonry.h>
#import "RCDCommonString.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "RCDFriendInfo.h"
#import "DefaultPortraitView.h"
#import "RCDUtilities.h"
@interface RCDContactTableViewCell ()

@property (nonatomic, copy) NSString *currentUserId;

@end

@implementation RCDContactTableViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
        [self addLongPress];
    }
    return self;
}

- (void)setModel:(RCUserInfo *)userInfo {
    self.currentUserId = userInfo.userId;

    BOOL isDisplayID = [DEFAULTS boolForKey:RCDDisplayIDKey];
    if (isDisplayID == YES) {
        self.userIdLabel.text = userInfo.userId;
    }

    if ([userInfo isKindOfClass:[RCDFriendInfo class]]) {
        RCDFriendInfo *friendInfo = (RCDFriendInfo *)userInfo;
        if (friendInfo.displayName.length > 0) {
            self.nicknameLabel.text = friendInfo.displayName;
        } else {
            self.nicknameLabel.text = friendInfo.name;
        }
    } else {
        self.nicknameLabel.text = userInfo.name;
    }
    if (userInfo.portraitUri.length <= 0) {
        self.portraitView.image = [DefaultPortraitView portraitView:userInfo.userId name:userInfo.name];
    } else {
        [self.portraitView sd_setImageWithURL:[NSURL URLWithString:userInfo.portraitUri]
                             placeholderImage:[UIImage imageNamed:@"contact"]];
    }
}

- (void)initialize {
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor =
        [RCDUtilities generateDynamicColor:HEXCOLOR(0xf5f5f5)
                                 darkColor:[HEXCOLOR(0x1c1c1e) colorWithAlphaComponent:0.4]];

    [self.contentView addSubview:self.portraitView];
    [self.contentView addSubview:self.nicknameLabel];
    [self.contentView addSubview:self.userIdLabel];
    [self.contentView addSubview:self.noticeLabel];

    [self.portraitView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(14);
        make.centerY.equalTo(self.contentView);
        make.width.height.offset(36);
    }];

    BOOL isDisplayID = [DEFAULTS boolForKey:RCDDisplayIDKey];

    if (isDisplayID) {
        [self.nicknameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.portraitView.mas_right).offset(9);
            make.centerY.height.equalTo(self.portraitView);
            make.right.equalTo(self.userIdLabel.mas_left);
        }];

        [self.userIdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.height.equalTo(self.portraitView);
            make.right.equalTo(self.contentView).offset(-20);
        }];
    } else {
        [self.nicknameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.portraitView.mas_right).offset(9);
            make.centerY.height.equalTo(self.portraitView);
            make.right.equalTo(self.contentView).offset(-20);
        }];
    }

    [self.noticeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-27.5);
        make.centerY.equalTo(self.contentView);
        make.height.width.equalTo(@18);
    }];
}

- (void)addLongPress {
    UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self addGestureRecognizer:longPress];
}

- (void)longPressAction:(UIGestureRecognizer *)sender {
    // 添加判断防止多次回调
    if (sender.state == UIGestureRecognizerStateBegan && self.longPressBlock) {
        self.longPressBlock(self.currentUserId);
    }
}

- (void)showNoticeLabel:(int)noticeCount {
    if (noticeCount > 0) {
        self.noticeLabel.hidden = NO;
        self.noticeLabel.text = [NSString stringWithFormat:@"%d", noticeCount];
    } else {
        self.noticeLabel.hidden = YES;
    }
}

- (UIImageView *)portraitView {
    if (!_portraitView) {
        _portraitView = [[UIImageView alloc] init];
        _portraitView.translatesAutoresizingMaskIntoConstraints = NO;
        _portraitView.contentMode = UIViewContentModeScaleAspectFill;
        if ([RCIM sharedRCIM].globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
            [RCIM sharedRCIM].globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
            _portraitView.layer.cornerRadius = 20.f;
        } else {
            _portraitView.layer.cornerRadius = 5.f;
        }
        _portraitView.layer.masksToBounds = YES;
    }
    return _portraitView;
}

- (UILabel *)nicknameLabel {
    if (!_nicknameLabel) {
        _nicknameLabel = [[UILabel alloc] init];
        _nicknameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _nicknameLabel.font = [UIFont systemFontOfSize:15.f];
        _nicknameLabel.textColor = RCDDYCOLOR(0x000000, 0x9f9f9f);
    }
    return _nicknameLabel;
}

- (UILabel *)userIdLabel {
    if (!_userIdLabel) {
        _userIdLabel = [[UILabel alloc] init];
        _userIdLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_userIdLabel setFont:[UIFont fontWithName:@"Heiti SC" size:15.0]];
        _userIdLabel.textColor = [UIColor colorWithHexString:@"000000" alpha:1.0];
    }
    return _userIdLabel;
}

- (UILabel *)noticeLabel {
    if (!_noticeLabel) {
        _noticeLabel = [[UILabel alloc] init];
        _noticeLabel.backgroundColor = [UIColor colorWithHexString:@"FF0000" alpha:1];
        _noticeLabel.font = [UIFont systemFontOfSize:15];
        _noticeLabel.textColor = [UIColor whiteColor];
        _noticeLabel.layer.cornerRadius = 9;
        _noticeLabel.layer.masksToBounds = YES;
        _noticeLabel.hidden = YES;
        _noticeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _noticeLabel;
}

@end
