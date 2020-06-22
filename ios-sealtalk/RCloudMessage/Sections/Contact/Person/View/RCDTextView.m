//
//  RCDTextView.m
//  SealTalk
//
//  Created by 孙浩 on 2019/8/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDTextView.h"
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>

@interface RCDTextView ()

@property (nonatomic, strong) UILabel *placeholderLabel;

@end

@implementation RCDTextView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
        [self addObserver];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupViews {
    self.scrollEnabled = NO;
    self.textContainerInset = UIEdgeInsetsMake(11.5, -4, 11.5, 0);
    self.layoutManager.allowsNonContiguousLayout = NO;
    [self addSubview:self.placeholderLabel];

    self.placeholderColor = [UIColor colorWithHexString:@"C0C0C0" alpha:1];
    self.placeholderFont = [UIFont systemFontOfSize:15.0f];
    self.font = [UIFont systemFontOfSize:15.0f];

    [self.placeholderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.height.equalTo(self);
        make.left.right.equalTo(self);
    }];
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
}

- (void)textDidChange {
    self.placeholderLabel.hidden = self.hasText;
    if (self.textChangeDelegate && [self.textChangeDelegate respondsToSelector:@selector(rcdTextView:textDidChange:)]) {
        [self.textChangeDelegate rcdTextView:self textDidChange:self.text];
    }
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    _placeholderColor = placeholderColor;
    self.placeholderLabel.textColor = placeholderColor;
}

- (void)setPlaceholderFont:(UIFont *)placeholderFont {
    _placeholderFont = placeholderFont;
    self.placeholderLabel.font = placeholderFont;
}

- (void)setPlaceholder:(NSString *)placeholder color:(UIColor *)color font:(UIFont *)font {
    self.placeholder = placeholder;
    self.placeholderColor = color;
    self.placeholderFont = font;
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.placeholderLabel.text = placeholder;
}

- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc] init];
        _placeholderLabel.backgroundColor = [UIColor clearColor];
    }
    return _placeholderLabel;
}

#pragma mark - Override
- (void)setText:(NSString *)text {
    [super setText:text];
    [self textDidChange];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    [self textDidChange];
}

- (void)setSelectedRange:(NSRange)selectedRange {
    [super setSelectedRange:selectedRange];
    [self textDidChange];
}

@end
