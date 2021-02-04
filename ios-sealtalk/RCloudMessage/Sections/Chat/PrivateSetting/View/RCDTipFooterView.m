//
//  RCDTipFooterView.m
//  SealTalk
//
//  Created by hrx on 2019/7/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDTipFooterView.h"
#import "UIColor+RCColor.h"
#import "RCDUtilities.h"
#import <RongIMLib/RongIMLib.h>
#import <Masonry/Masonry.h>

static const NSInteger __RCDTipLabelTopSpace = 5;
static const NSInteger __RCDTipLabelBottomSpace = 10;

@interface RCDTipFooterView ()

@property (nonatomic, strong) UILabel *tipLabel;

@end

@implementation RCDTipFooterView

- (instancetype)init {
    if (self == [super init]) {
        [self __addTipLabel];
    }
    return self;
}

- (void)renderWithTip:(NSString *)tip font:(UIFont *)font {
    self.tipLabel.text = tip;
    if (!font) {
        self.tipLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    } else {
        self.tipLabel.font = font;
    }
}

- (void)__addTipLabel {
    self.backgroundColor = RCDDYCOLOR(0xf2f2f3, 0x000000);
    [self addSubview:self.tipLabel];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(5);
        make.left.equalTo(self.mas_left).offset(12);
        make.right.equalTo(self.mas_right).offset(-15);
    }];
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.numberOfLines = 0;
        [_tipLabel setTextColor:RCDDYCOLOR(0x8b8b8b, 0x666666)];
    }
    return _tipLabel;
}

- (CGFloat)heightForTipFooterViewWithTip:(NSString *)tip font:(UIFont *)font constrainedSize:(CGSize)constrainedSize {
    return [RCUtilities getTextDrawingSize:tip font:font constrainedSize:constrainedSize].height +
           __RCDTipLabelTopSpace + __RCDTipLabelBottomSpace;
}

@end
