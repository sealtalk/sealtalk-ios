//
//  RCDChatBackgroundCell.m
//  SealTalk
//
//  Created by 孙浩 on 2019/8/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDChatBackgroundCell.h"
#import <Masonry/Masonry.h>

@interface RCDChatBackgroundCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *selectedImgView;

@end

@implementation RCDChatBackgroundCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews {
    self.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.imageView];
    [self.imageView addSubview:self.selectedImgView];

    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.width.height.equalTo(self.contentView);
    }];

    [self.selectedImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.imageView).offset(-5);
        make.bottom.equalTo(self.imageView).offset(-5);
        make.height.width.offset(17);
    }];
}

- (void)setImageName:(NSString *)imageName {
    _imageName = imageName;
    self.imageView.image = [UIImage imageNamed:imageName];
}

- (void)setImgHidden:(BOOL)imgHidden {
    _imgHidden = imgHidden;
    self.selectedImgView.hidden = imgHidden;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (UIImageView *)selectedImgView {
    if (!_selectedImgView) {
        _selectedImgView = [[UIImageView alloc] init];
        _selectedImgView.image = [UIImage imageNamed:@"chat_bg_select"];
        _selectedImgView.hidden = YES;
    }
    return _selectedImgView;
}

@end
