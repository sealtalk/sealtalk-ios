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
        self.nameLabel.text = user.name;
        if ([user.portraitUri isEqualToString:@""]) {
            UIImage *portrait = [DefaultPortraitView portraitView:user.userId name:user.name];
            self.portraitImageView.image = portrait;
        } else {
            [self.portraitImageView sd_setImageWithURL:[NSURL URLWithString:user.portraitUri] placeholderImage:[UIImage imageNamed:@"contact"]];
        }
    }
    
    if (user.status == RCDFriendStatusRequest) {
        self.rightLabel.text = RCDLocalizedString(@"had_invite");
        self.selected = NO;
        self.arrowImgView.hidden = YES;
        self.acceptBtn.hidden = YES;
    } else if (user.status == RCDFriendStatusRequested) {
        self.selected = NO;
        self.acceptBtn.hidden = NO;
        self.arrowImgView.hidden = YES;
    } else if (user.status == RCDFriendStatusAgree) {
        self.rightLabel.text = RCDLocalizedString(@"had_accept");
        self.acceptBtn.hidden = YES;
        self.arrowImgView.hidden = NO;
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
    
    [self.acceptBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-8);
        make.width.offset(65);
        make.height.offset(CellHeight - 16.5 - 16 - 8);
    }];
}

- (void)doAccept {
    if (self.acceptBlock) {
        self.acceptBlock(self.currentUserInfo.userId);
    }
}

#pragma mark - Setter && Getter
- (UIImageView *)portraitImageView {
    if (!_portraitImageView) {
        _portraitImageView = [[UIImageView alloc] init];
        if ([RCIM sharedRCIM].globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
            [RCIM sharedRCIM].globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
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
        self.rightLabel.font = [UIFont systemFontOfSize:14];
        self.rightLabel.textAlignment = NSTextAlignmentRight;
    }
    return _rightLabel;
}

- (UIButton *)acceptBtn {
    if (!_acceptBtn) {
        _acceptBtn = [[UIButton alloc] init];
        _acceptBtn.tag = self.tag;
        [_acceptBtn setTitle:RCDLocalizedString(@"accept") forState:UIControlStateNormal];
        [_acceptBtn setTintColor:[UIColor whiteColor]];
        [_acceptBtn setBackgroundColor:[[UIColor alloc] initWithRed:23 / 255.f green:136 / 255.f blue:213 / 255.f alpha:1]];
        _acceptBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [_acceptBtn.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
        [_acceptBtn addTarget:self action:@selector(doAccept) forControlEvents:UIControlEventTouchUpInside];
    }
    return _acceptBtn;
}
@end
