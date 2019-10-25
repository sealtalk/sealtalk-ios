//
//  RCDSearchResultTableViewCell.m
//  RCloudMessage
//
//  Created by Liv on 15/4/7.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDSearchResultTableViewCell.h"
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>
#import "DefaultPortraitView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface RCDSearchResultTableViewCell ()

@property (nonatomic, strong) UIImageView *ivAva;
@property (nonatomic, strong) UILabel *lblName;
@property (nonatomic, strong) UIImageView *genderImgView;
@property (nonatomic, strong) UILabel *stAccountLabel;

@end

@implementation RCDSearchResultTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubviews];
    }
    return self;
}

- (void)setModel:(RCDFriendInfo *)friendInfo {
    if (friendInfo && friendInfo.displayName.length > 0) {
        self.lblName.text = friendInfo.displayName;
    } else {
        self.lblName.text = friendInfo.name;
    }
    if ([friendInfo.portraitUri isEqualToString:@""]) {
        UIImage *portrait = [DefaultPortraitView portraitView:friendInfo.userId name:friendInfo.name];
        ;
        self.ivAva.image = portrait;
    } else {
        [self.ivAva sd_setImageWithURL:[NSURL URLWithString:friendInfo.portraitUri]
                      placeholderImage:[UIImage imageNamed:@"icon_person"]];
    }
    if (friendInfo.gender.length > 0) {
        self.genderImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"gender_%@", friendInfo.gender]];
    } else {
        self.genderImgView.image = [UIImage imageNamed:@"gender_male"];
    }
    if (friendInfo.stAccount.length > 0 && ![friendInfo.stAccount isEqualToString:@""]) {
        self.stAccountLabel.hidden = NO;
        self.stAccountLabel.text =
            [NSString stringWithFormat:@"%@：%@", RCDLocalizedString(@"SealTalkNumber"), friendInfo.stAccount];
        [self.lblName mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.ivAva.mas_right).offset(10);
            make.height.offset(16);
            make.top.equalTo(self.ivAva).offset(7);
        }];
    } else {
        self.stAccountLabel.hidden = YES;
        [self.lblName mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.ivAva);
            make.left.equalTo(self.ivAva.mas_right).offset(10);
            make.height.offset(16);
        }];
    }
}

- (void)addSubviews {
    [self.contentView addSubview:self.ivAva];
    [self.contentView addSubview:self.lblName];
    [self.contentView addSubview:self.genderImgView];
    [self.contentView addSubview:self.stAccountLabel];

    [self.ivAva mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.offset(56);
        make.left.equalTo(self.contentView).offset(10);
        make.centerY.equalTo(self.contentView);
    }];

    [self.lblName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.ivAva.mas_right).offset(10);
        make.height.offset(16);
        make.top.equalTo(self.ivAva).offset(7);
    }];

    [self.genderImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.lblName);
        make.left.equalTo(self.lblName.mas_right).offset(5);
        make.height.width.equalTo(@15);
    }];

    [self.stAccountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lblName.mas_bottom).offset(7);
        make.left.equalTo(self.lblName);
        make.right.equalTo(self.contentView);
        make.height.offset(14);
    }];
}

- (UIImageView *)ivAva {
    if (!_ivAva) {
        _ivAva = [[UIImageView alloc] init];
        _ivAva.clipsToBounds = YES;
        _ivAva.layer.cornerRadius = 5.f;
        _ivAva.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _ivAva;
}

- (UILabel *)lblName {
    if (!_lblName) {
        _lblName = [[UILabel alloc] init];
    }
    return _lblName;
}

- (UIImageView *)genderImgView {
    if (!_genderImgView) {
        _genderImgView = [[UIImageView alloc] init];
        _genderImgView.layer.cornerRadius = 15 / 2;
        _genderImgView.layer.masksToBounds = YES;
    }
    return _genderImgView;
}

- (UILabel *)stAccountLabel {
    if (!_stAccountLabel) {
        _stAccountLabel = [[UILabel alloc] init];
        _stAccountLabel.textColor = [UIColor colorWithHexString:@"999999" alpha:1];
        _stAccountLabel.font = [UIFont systemFontOfSize:14];
    }
    return _stAccountLabel;
}

@end
