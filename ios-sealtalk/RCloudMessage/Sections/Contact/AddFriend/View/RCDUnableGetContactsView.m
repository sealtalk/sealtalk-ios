//
//  RCDUnableGetContactsView.m
//  SealTalk
//
//  Created by 孙浩 on 2019/7/15.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDUnableGetContactsView.h"
#import <Masonry/Masonry.h>
#import "UIColor+RCColor.h"
#import "RCDUtilities.h"
@interface RCDUnableGetContactsView ()

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *headerImgView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;

@end

@implementation RCDUnableGetContactsView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews {

    self.backgroundColor = RCDDYCOLOR(0xFAFAFA, 0x000000);
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.headerImgView];
    [self.bgView addSubview:self.titleLabel];
    [self.bgView addSubview:self.detailLabel];
    [self.bgView addSubview:self.settingButton];

    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.centerY.equalTo(self);
    }];

    [self.headerImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.centerX.equalTo(self.bgView);
        make.width.height.offset(110);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerImgView.mas_bottom).offset(25);
        make.left.right.equalTo(self.bgView).inset(10);
        make.height.offset(24);
    }];

    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(15);
        make.left.right.equalTo(self.bgView).inset(10);
        make.height.offset(40);
    }];

    [self.settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.detailLabel.mas_bottom).offset(42);
        make.left.right.equalTo(self.bgView).inset(15);
        make.height.offset(45);
        make.bottom.equalTo(self.bgView);
    }];
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
    }
    return _bgView;
}

- (UIImageView *)headerImgView {
    if (!_headerImgView) {
        _headerImgView = [[UIImageView alloc] init];
        _headerImgView.layer.cornerRadius = 4;
        _headerImgView.layer.masksToBounds = YES;
        _headerImgView.image = [UIImage imageNamed:@"contacts_matching"];
    }
    return _headerImgView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = RCDDYCOLOR(0x333333, 0x9f9f9f);
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = RCDLocalizedString(@"UnableToAccessAddressBookInformation");
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.textColor = RCDDYCOLOR(0x262626, 0x9f9f9f);
        _detailLabel.font = [UIFont systemFontOfSize:14];
        _detailLabel.textAlignment = NSTextAlignmentCenter;
        _detailLabel.text = RCDLocalizedString(@"ToSettingContactsPermissions");
    }
    return _detailLabel;
}

- (UIButton *)settingButton {
    if (!_settingButton) {
        _settingButton = [[UIButton alloc] init];
        _settingButton.backgroundColor = [UIColor colorWithHexString:@"0497FF" alpha:1];
        [_settingButton setTitle:RCDLocalizedString(@"ToSetting") forState:UIControlStateNormal];
        _settingButton.layer.cornerRadius = 4;
        _settingButton.layer.masksToBounds = YES;
    }
    return _settingButton;
}

@end
