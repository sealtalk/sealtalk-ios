//
//  RCDRemarksView.m
//  SealTalk
//
//  Created by 孙浩 on 2019/5/30.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDRemarksView.h"
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>

@interface RCDRemarksView ()
@property (nonatomic, strong) UILabel *remarkLabel;
@property (nonatomic, strong) UIImageView *rightArrow;
@end

@implementation RCDRemarksView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {

    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor whiteColor];

    [self addSubview:self.remarkLabel];
    [self addSubview:self.rightArrow];

    [self.remarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.centerY.height.equalTo(self);
        make.right.equalTo(self.rightArrow.mas_left).offset(-10);
    }];

    [self.rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-10);
    }];
}

- (UILabel *)remarkLabel {
    if (!_remarkLabel) {
        _remarkLabel = [[UILabel alloc] init];
        _remarkLabel.font = [UIFont systemFontOfSize:16.f];
        _remarkLabel.textColor = [UIColor colorWithHexString:@"000000" alpha:1.f];
        _remarkLabel.text = RCDLocalizedString(@"set_remarks");
    }
    return _remarkLabel;
}

- (UIImageView *)rightArrow {
    if (!_rightArrow) {
        _rightArrow = [[UIImageView alloc] init];
        _rightArrow.image = [UIImage imageNamed:@"right_arrow"];
    }
    return _rightArrow;
}

@end
