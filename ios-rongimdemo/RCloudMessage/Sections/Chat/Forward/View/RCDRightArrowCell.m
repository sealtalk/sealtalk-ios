//
//  RCDRightArrowCell.m
//  SealTalk
//
//  Created by 孙浩 on 2019/6/18.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDRightArrowCell.h"
#import <Masonry/Masonry.h>
#import "UIColor+RCColor.h"
#import "RCDUtilities.h"
@implementation RCDRightArrowCell

- (instancetype)init {

    if (self = [super init]) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.leftLabel];
    [self.contentView addSubview:self.rightArrow];

    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.contentView).inset(15);
        make.left.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.rightArrow.mas_left).offset(-15);
    }];

    [self.rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-12);
        make.centerY.equalTo(self.contentView);
        make.width.height.offset(24);
    }];
}

- (void)setLeftText:(NSString *)leftText {
    self.leftLabel.text = leftText;
}

#pragma mark - Setter && Getter
- (UILabel *)leftLabel {
    if (!_leftLabel) {
        _leftLabel = [[UILabel alloc] init];
        _leftLabel.font = [UIFont systemFontOfSize:17.f];
        _leftLabel.textColor = RCDDYCOLOR(0x262626, 0x9f9f9f);
    }
    return _leftLabel;
}

- (UIImageView *)rightArrow {
    if (!_rightArrow) {
        _rightArrow = [[UIImageView alloc] init];
        _rightArrow.image = [UIImage imageNamed:@"forward_arrow"];
    }
    return _rightArrow;
}

@end
