//
//  RCDDescriptionView.m
//  SealTalk
//
//  Created by 孙浩 on 2019/8/5.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDDescriptionView.h"
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>
#import "RCDUtilities.h"

@interface RCDDescriptionView () <RCDTextViewDelegate, UITextViewDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *textNumberLabel;

@end

@implementation RCDDescriptionView
@synthesize inputText = _inputText;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {

    self.backgroundColor = [RCDUtilities generateDynamicColor:HEXCOLOR(0xffffff)
                                                    darkColor:[HEXCOLOR(0x808080) colorWithAlphaComponent:0.2]];

    UIView *titleBgView = [[UIView alloc] init];
    titleBgView.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x000000);

    [self addSubview:titleBgView];

    [titleBgView addSubview:self.titleLabel];
    [self addSubview:self.textNumberLabel];
    [self addSubview:self.textView];

    [titleBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.offset(26.5);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self);
        make.left.equalTo(titleBgView).offset(10);
        make.height.offset(26.5);
    }];

    [self.textNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.right.equalTo(self).offset(-10);
        make.height.offset(26.5);
        make.width.offset(60);
    }];

    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.left.equalTo(self).offset(10);
        make.right.bottom.equalTo(self);
    }];
}

#pragma mark - RCDTextViewDelegate
- (void)rcdTextView:(RCDTextView *)textView textDidChange:(NSString *)text {

    NSString *toBeString = textView.text;
    NSString *lang = [textView.textInputMode primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入
        //获取高亮部分
        UITextRange *selectedRange = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];

        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > self.charMaxCount) {
                textView.text = [toBeString substringToIndex:self.charMaxCount];
            }
        }

    } else { // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        if (toBeString.length > self.charMaxCount) {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:self.charMaxCount];
            if (rangeIndex.length == 1) {
                textView.text = [toBeString substringToIndex:self.charMaxCount];
            } else {
                NSRange rangeRange =
                    [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, self.charMaxCount)];
                textView.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }

    self.textNumberLabel.text =
        [NSString stringWithFormat:@"%lu/%lu", (unsigned long)textView.text.length, (unsigned long)self.charMaxCount];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TextViewTextChanged" object:self.textView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    if ([text isEqualToString:@"\n"]) {
        [self endEditing:YES];
        return NO;
    }
    //不支持系统表情的输入
    if ([[[UITextInputMode currentInputMode] primaryLanguage] isEqualToString:@"emoji"] ||
        [RCDUtilities stringContainsEmoji:text]) {
        return NO;
    }
    return YES;
}

- (void)setShowTextNumber:(BOOL)showTextNumber {
    _showTextNumber = showTextNumber;
    self.textNumberLabel.hidden = !showTextNumber;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.textView.placeholder = placeholder;
}

- (void)setCharMaxCount:(NSUInteger)charMaxCount {
    _charMaxCount = charMaxCount;
    self.textNumberLabel.text = [NSString stringWithFormat:@"0/%lu", (unsigned long)charMaxCount];
}

- (BOOL)rcdIsFirstResponder {
    return self.textView.isFirstResponder;
}

- (void)setInputText:(NSString *)inputText {
    _inputText = inputText;
    self.textView.text = inputText;
}

- (NSString *)inputText {
    return self.textView.text;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textColor = [UIColor colorWithHexString:@"999999" alpha:1];
    }
    return _titleLabel;
}

- (UILabel *)textNumberLabel {
    if (!_textNumberLabel) {
        _textNumberLabel = [[UILabel alloc] init];
        _textNumberLabel.hidden = YES;
        _textNumberLabel.font = [UIFont systemFontOfSize:12];
        _textNumberLabel.textColor = [UIColor colorWithHexString:@"999999" alpha:1];
        _textNumberLabel.textAlignment = NSTextAlignmentRight;
    }
    return _textNumberLabel;
}

- (RCDTextView *)textView {
    if (!_textView) {
        _textView = [[RCDTextView alloc] init];
        _textView.textColor = RCDDYCOLOR(0x000000, 0x9f9f9f);
        _textView.textChangeDelegate = self;
        _textView.delegate = self;
        _textView.returnKeyType = UIReturnKeyDone;
        _textView.backgroundColor = [HEXCOLOR(0x808080) colorWithAlphaComponent:0];
        _textView.placeholderColor = HEXCOLOR(0x999999);
    }
    return _textView;
}

@end
