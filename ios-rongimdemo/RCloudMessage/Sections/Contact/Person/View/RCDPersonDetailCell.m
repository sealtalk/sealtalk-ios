//
//  RCDPersonDetailCell.m
//  SealTalk
//
//  Created by 孙浩 on 2019/6/21.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDPersonDetailCell.h"
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>

@implementation RCDPersonDetailCell

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    [self.contentView addSubview:self.titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView).inset(6);
        make.centerY.equalTo(self.contentView);
        make.height.offset(24);
    }];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.textColor = [UIColor colorWithHexString:@"262626" alpha:1.f];
    }
    return _titleLabel;
}

@end
