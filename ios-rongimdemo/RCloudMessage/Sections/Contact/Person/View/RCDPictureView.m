//
//  RCDPictureView.m
//  SealTalk
//
//  Created by 孙浩 on 2019/8/5.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDPictureView.h"
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>
#import "RCDUtilities.h"
@interface RCDPictureView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, strong) CAShapeLayer *border;

@end

@implementation RCDPictureView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
        [self addBorder];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.border.path = [UIBezierPath bezierPathWithRect:self.imageView.bounds].CGPath;
    self.border.frame = self.imageView.bounds;
}

- (void)tapAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(pictureViewDidTap)]) {
        [self.delegate pictureViewDidTap];
    }
}

// 添加虚线边框
- (void)addBorder {
    self.border = [CAShapeLayer layer];
    self.border.strokeColor = [UIColor colorWithHexString:@"979797" alpha:1].CGColor;
    self.border.fillColor = [UIColor clearColor].CGColor;
    self.border.lineWidth = .5f;
    self.border.lineCap = @"square";
    self.border.lineDashPattern = @[ @8, @8 ];
    [self.imageView.layer addSublayer:self.border];
}

- (void)setupViews {
    self.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
    [self addSubview:self.titleLabel];
    [self addSubview:self.imageView];
    [self addSubview:self.promptLabel];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(5);
        make.left.right.equalTo(self).inset(10);
        make.height.offset(16.5);
    }];

    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(20);
        make.left.right.equalTo(self).inset(10);
        make.height.equalTo(self.mas_width).multipliedBy(147.5 / 355);
        make.bottom.equalTo(self);
    }];

    [self.promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.width.equalTo(self.imageView);
        make.height.offset(23);
    }];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)setPromptTitle:(NSString *)promptTitle {
    _promptTitle = promptTitle;
    self.promptLabel.text = promptTitle;
    if (promptTitle) {
        self.promptLabel.hidden = NO;
    } else {
        self.promptLabel.hidden = YES;
    }
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textColor = [UIColor colorWithHexString:@"999999" alpha:1];
    }
    return _titleLabel;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.userInteractionEnabled = YES;
        _imageView.layer.masksToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [_imageView addGestureRecognizer:tap];
    }
    return _imageView;
}

- (UILabel *)promptLabel {
    if (!_promptLabel) {
        _promptLabel = [[UILabel alloc] init];
        _promptLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        _promptLabel.textColor = [UIColor colorWithHexString:@"999999" alpha:1];
        _promptLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _promptLabel;
}

@end
