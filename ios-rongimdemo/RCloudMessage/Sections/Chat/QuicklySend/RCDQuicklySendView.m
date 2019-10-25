//
//  RCDQuicklySendView.m
//  SealTalk
//
//  Created by 孙浩 on 2019/8/1.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDQuicklySendView.h"
#import <Masonry/Masonry.h>
#import "UIColor+RCColor.h"

@interface RCDQuicklySendView ()

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation RCDQuicklySendView

+ (instancetype)quicklSendViewWithFrame:(CGRect)frame image:(UIImage *)image {
    RCDQuicklySendView *view = [[self alloc] initWithFrame:frame];
    view.imageView.image = image;
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

- (instancetype)init {

    if (self = [super init]) {
        [self setupViews];
    }
    return self;
}

- (void)show {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:self];
}

- (void)hide {
    [self removeFromSuperview];
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

- (void)setupViews {

    [self addSubview:self.bgImageView];
    [self.bgImageView addSubview:self.titleLabel];
    [self.bgImageView addSubview:self.imageView];

    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.width.height.equalTo(self);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.bgImageView).inset(10);
        make.top.equalTo(self.bgImageView).offset(5);
        make.height.offset(28);
    }];

    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(5);
        make.height.width.offset(80);
        make.centerX.equalTo(self.bgImageView);
    }];
}

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.userInteractionEnabled = YES;
        _bgImageView.image = [UIImage imageNamed:@"preview_popup"];
    }
    return _bgImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 0;
        _titleLabel.text = RCDLocalizedString(@"PhotosYouWantToSend");
        _titleLabel.font = [UIFont systemFontOfSize:10];
        _titleLabel.textColor = [UIColor colorWithHexString:@"666666" alpha:1];
    }
    return _titleLabel;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

@end
