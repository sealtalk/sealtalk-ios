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
@property (nonatomic, strong) UILabel *phoneNumberLabel;
@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, copy) NSString *phoneNumber;

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
    if ([userInfo.userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
        self.remarksLabel.hidden = YES;
        self.phoneNumberLabel.hidden = YES;
        
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.infoBgView);
            make.left.equalTo(self.portraitImgView.mas_right).offset(10);
            make.height.offset(16);
            make.right.equalTo(self.infoBgView).offset(-10);
        }];
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
    if (!userInfo.portraitUri || userInfo.portraitUri.length <= 0) {
        self.portraitImgView.image = [DefaultPortraitView portraitView:userInfo.userId name:userInfo.name];
    }else{
        [self.portraitImgView sd_setImageWithURL:[NSURL URLWithString:userInfo.portraitUri] placeholderImage:[UIImage imageNamed:@"icon_person"]];
    }
}

- (void)setUserPhoneNumer:(NSString *)phoneNumber {
    self.phoneNumberLabel.text = [NSString stringWithFormat:@"%@: %@", RCDLocalizedString(@"mobile_number"), phoneNumber];
    NSUInteger textLength = RCDLocalizedString(@"mobile_number").length + 1;
    NSMutableAttributedString *attributedStr =
    [[NSMutableAttributedString alloc] initWithString:self.phoneNumberLabel.text];
    [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"0099ff" alpha:1.f] range:NSMakeRange(textLength, self.phoneNumberLabel.text.length-textLength)];
    self.phoneNumberLabel.attributedText = attributedStr;
    self.phoneNumber = phoneNumber;
}

#pragma mark - Private Method
- (void)updateSubviewsWithHaveRemarks:(BOOL)haveRemarks {
    self.remarksLabel.hidden = !haveRemarks;
    if (haveRemarks == YES) {
        self.nameLabel.font = [UIFont systemFontOfSize:14];
        self.nameLabel.textColor = [UIColor colorWithHexString:@"999999" alpha:1];
        [self.remarksLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.infoBgView).offset(14);
            make.left.equalTo(self.portraitImgView.mas_right).offset(10);
            make.height.offset(16);
            make.right.equalTo(self.infoBgView).offset(-10);
        }];
        [self.phoneNumberLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.remarksLabel.mas_bottom).offset(5);
            make.left.right.equalTo(self.remarksLabel);
            make.height.offset(14);
        }];
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.phoneNumberLabel.mas_bottom).offset(5);
            make.left.right.equalTo(self.remarksLabel);
            make.height.offset(16);
        }];
    } else {
        self.nameLabel.font = [UIFont systemFontOfSize:16];
        self.nameLabel.textColor = [UIColor colorWithHexString:@"000000" alpha:1];
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.infoBgView).offset(20);
            make.left.equalTo(self.portraitImgView.mas_right).offset(10);
            make.height.offset(16);
            make.right.equalTo(self.infoBgView).offset(-10);
        }];
        [self.phoneNumberLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(8);
            make.left.right.equalTo(self.remarksLabel);
            make.height.offset(14);
        }];
    }
}

- (void)addSubviews {
    [self addSubview:self.infoBgView];
    [self.infoBgView addSubview:self.portraitImgView];
    [self.infoBgView addSubview:self.remarksLabel];
    [self.infoBgView addSubview:self.phoneNumberLabel];
    [self.infoBgView addSubview:self.nameLabel];
    
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
        make.right.equalTo(self.infoBgView).offset(-10);
    }];
    
    [self.phoneNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.remarksLabel.mas_bottom).offset(5);
        make.left.right.equalTo(self.remarksLabel);
        make.height.offset(14);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.phoneNumberLabel.mas_bottom).offset(3);
        make.left.right.equalTo(self.remarksLabel);
        make.height.offset(16);
    }];
}

- (void)tapPhoneNumber:(UIButton *)sender {
    self.phoneNumberLabel.userInteractionEnabled = NO;
    [self performSelector:@selector(changePhoneNumberLabelInteractionEnabled) withObject:sender afterDelay:1];
    if (self.delegate && [self.delegate respondsToSelector:@selector(personInfoViewDidTapPhoneNumber:)]) {
        [self.delegate personInfoViewDidTapPhoneNumber:self.phoneNumber];
    }
}

- (void)changePhoneNumberLabelInteractionEnabled {
    self.phoneNumberLabel.userInteractionEnabled = YES;
}

#pragma mark - Getter && Setter
- (UIView *)infoBgView {
    if (!_infoBgView) {
        _infoBgView = [[UIView alloc] init];
        _infoBgView.backgroundColor = [UIColor whiteColor];
    }
    return _infoBgView;
}

- (UIImageView *)portraitImgView {
    if (!_portraitImgView) {
        _portraitImgView = [[UIImageView alloc] init];
        _portraitImgView.contentMode = UIViewContentModeScaleAspectFill;
        if ([RCIM sharedRCIM].globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE && [RCIM sharedRCIM].globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
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
        _remarksLabel.textColor = [UIColor colorWithHexString:@"000000" alpha:1];
        _remarksLabel.hidden = YES;
    }
    return _remarksLabel;
}

- (UILabel *)phoneNumberLabel {
    if (!_phoneNumberLabel) {
        _phoneNumberLabel = [[UILabel alloc] init];
        _phoneNumberLabel.textColor = [UIColor colorWithHexString:@"999999" alpha:1];
        _phoneNumberLabel.font = [UIFont systemFontOfSize:14];
        _phoneNumberLabel.text = [NSString stringWithFormat:@"%@: --", RCDLocalizedString(@"mobile_number")];
        _phoneNumberLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPhoneNumber:)];
        [_phoneNumberLabel addGestureRecognizer:tap];
    }
    return _phoneNumberLabel;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textColor = [UIColor colorWithHexString:@"000000" alpha:1];
    }
    return _nameLabel;
}

@end
