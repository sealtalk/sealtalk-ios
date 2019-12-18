//
//  RCDAddressBookFriendCell.m
//  SealTalk
//
//  Created by 孙浩 on 2019/7/15.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDAddressBookFriendCell.h"
#import <Masonry/Masonry.h>
#import "UIColor+RCColor.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DefaultPortraitView.h"
#import "RCDUtilities.h"
@interface RCDAddressBookFriendCell ()

@property (nonatomic, strong) UIImageView *headerImgView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UILabel *addLabel;
@property (nonatomic, strong) UIButton *addButton;

@property (nonatomic, strong) NSString *userId;

@end

@implementation RCDAddressBookFriendCell

- (instancetype)init {

    if (self = [super init]) {
        [self setupViews];
    }
    return self;
}

- (void)setModel:(RCDContactsInfo *)model {
    self.userId = model.userId;
    self.titleLabel.text = model.name;
    self.detailLabel.text = model.nickname;

    if ([model.portraitUri isEqualToString:@""]) {
        UIImage *portrait = [DefaultPortraitView portraitView:model.userId name:model.name];
        self.headerImgView.image = portrait;
    } else {
        [self.headerImgView sd_setImageWithURL:[NSURL URLWithString:model.portraitUri]
                              placeholderImage:[UIImage imageNamed:@"default_portrait_msg"]];
    }

    self.addLabel.hidden = !model.isRelationship;
    self.addButton.hidden = model.isRelationship;
}

- (void)addAction {
    if (self.addBlock) {
        self.addBlock(self.userId);
    }
}

- (void)setupViews {
    [self.contentView addSubview:self.headerImgView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.detailLabel];
    [self.contentView addSubview:self.addLabel];
    [self.contentView addSubview:self.addButton];

    [self.headerImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(7);
        make.left.equalTo(self.contentView).offset(8);
        make.height.width.offset(46);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerImgView.mas_right).offset(9);
        make.top.equalTo(self.headerImgView);
        make.right.equalTo(self.contentView).offset(-64);
        make.height.offset(23);
    }];

    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(3);
        make.height.offset(20);
    }];

    [self.addLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-10);
        make.height.offset(20);
        make.width.offset(52);
    }];

    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-10);
        make.height.offset(27);
        make.width.offset(52);
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
        _titleLabel.font = [UIFont systemFontOfSize:16.5];
        _titleLabel.textColor = RCDDYCOLOR(0x333333, 0x9f9f9f);
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont systemFontOfSize:14];
        _detailLabel.textColor = RCDDYCOLOR(0x999999, 0x707070);
    }
    return _detailLabel;
}

- (UILabel *)addLabel {
    if (!_addLabel) {
        _addLabel = [[UILabel alloc] init];
        _addLabel.font = [UIFont systemFontOfSize:14];
        _addLabel.textColor = [UIColor colorWithHexString:@"999999" alpha:1];
        _addLabel.textAlignment = NSTextAlignmentRight;
        _addLabel.text = RCDLocalizedString(@"Added");
    }
    return _addLabel;
}

- (UIButton *)addButton {
    if (!_addButton) {
        _addButton = [[UIButton alloc] init];
        _addButton.backgroundColor = RCDDYCOLOR(0x0399FF, 0x666666);
        _addButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _addButton.layer.cornerRadius = 2;
        _addButton.layer.masksToBounds = YES;
        [_addButton setTitle:RCDLocalizedString(@"Add") forState:UIControlStateNormal];
        [_addButton addTarget:self action:@selector(addAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addButton;
}

@end
