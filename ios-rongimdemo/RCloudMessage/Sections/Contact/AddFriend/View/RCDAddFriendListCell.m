//
//  RCDAddFriendListCell.m
//  SealTalk
//
//  Created by 孙浩 on 2019/7/9.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDAddFriendListCell.h"
#import <Masonry/Masonry.h>
#import "UIColor+RCColor.h"
#import "RCDUtilities.h"
@implementation RCDAddFriendListCell

- (instancetype)init {

    if (self = [super init]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self.contentView addSubview:self.headerImgView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.detailLabel];

    [self.headerImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(8.5);
        make.height.width.offset(39);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerImgView.mas_right).offset(10);
        make.top.equalTo(self.contentView).offset(5);
        make.right.equalTo(self.contentView).offset(-10);
        make.height.offset(20);
    }];

    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(4);
        make.height.offset(16.5);
    }];
}

- (UIImageView *)headerImgView {
    if (!_headerImgView) {
        _headerImgView = [[UIImageView alloc] init];
        _headerImgView.layer.cornerRadius = 5;
        _headerImgView.layer.masksToBounds = YES;
    }
    return _headerImgView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = RCDDYCOLOR(0x333333, 0x9f9f9f);
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont systemFontOfSize:12];
        _detailLabel.textColor = [UIColor colorWithHexString:@"999999" alpha:1];
    }
    return _detailLabel;
}

@end
