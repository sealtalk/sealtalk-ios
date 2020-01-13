//
//  RCDSetupRemarkView.m
//  SealTalk
//
//  Created by 孙浩 on 2019/8/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDSetupRemarkView.h"
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>
#import "RCDUtilities.h"
@interface RCDSetupRemarkView () <UITextFieldDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) UIButton *countryButton;
@property (nonatomic, strong) UIImageView *arrowImgView;

@end

@implementation RCDSetupRemarkView
@synthesize inputText = _inputText;

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
    self.backgroundColor = [RCDUtilities generateDynamicColor:HEXCOLOR(0xffffff)
                                                    darkColor:[HEXCOLOR(0x808080) colorWithAlphaComponent:0.2]];

    UIView *titleBgView = [[UIView alloc] init];
    titleBgView.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
    [self addSubview:titleBgView];

    [titleBgView addSubview:self.titleLabel];
    [self addSubview:self.textField];

    [titleBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.offset(26.5);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self);
        make.left.equalTo(titleBgView).offset(10);
        make.height.offset(26.5);
    }];

    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.left.equalTo(self).offset(10);
        make.right.bottom.equalTo(self);
    }];
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldEditChanged:)
                                                 name:@"UITextFieldTextDidChangeNotification"
                                               object:nil];
}

- (void)updateUI {
    [self addSubview:self.countryButton];
    [self addSubview:self.arrowImgView];
    [self.countryButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.left.equalTo(self).offset(10);
        make.bottom.equalTo(self);
    }];
    [self.arrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.countryButton);
        make.left.equalTo(self.countryButton.mas_right).offset(5);
        make.width.height.offset(20);
        make.right.lessThanOrEqualTo(self.textField.mas_left);
    }];

    [self.textField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.left.equalTo(self).offset(80);
        make.right.bottom.equalTo(self);
    }];
    self.textField.keyboardType = UIKeyboardTypeNumberPad;
}

//限制 textField 输入长度
- (void)textFieldEditChanged:(NSNotification *)obj {
    UITextField *textField = self.textField;
    NSString *toBeString = self.textField.text;
    NSString *lang = [textField.textInputMode primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入
        //获取高亮部分
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];

        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > self.charMaxCount) {
                textField.text = [toBeString substringToIndex:self.charMaxCount];
            }
        }

    } else { // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        if (toBeString.length > self.charMaxCount) {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:self.charMaxCount];
            if (rangeIndex.length == 1) {
                textField.text = [toBeString substringToIndex:self.charMaxCount];
            } else {
                NSRange rangeRange =
                    [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, self.charMaxCount)];
                textField.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self endEditing:YES];
    return YES;
}

- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
    //不支持系统表情的输入
    if ([[[UITextInputMode currentInputMode] primaryLanguage] isEqualToString:@"emoji"] ||
        [RCDUtilities stringContainsEmoji:string]) {
        return NO;
    }

    if (self.isPhoneNumber && [RCDUtilities includeChinese:string]) {
        return NO;
    }
    return YES;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.textField.placeholder = placeholder;
    NSAttributedString *attrString =
        [[NSAttributedString alloc] initWithString:self.textField.placeholder
                                        attributes:@{
                                            NSForegroundColorAttributeName : HEXCOLOR(0x999999),
                                            NSFontAttributeName : self.textField.font
                                        }];
    self.textField.attributedPlaceholder = attrString;
}

- (void)setInputText:(NSString *)inputText {
    _inputText = inputText;
    self.textField.text = inputText;
}

- (NSString *)inputText {
    return self.textField.text;
}

- (void)setShowCountryBtn:(BOOL)showCountryBtn {
    _showCountryBtn = showCountryBtn;
    self.countryButton.hidden = !showCountryBtn;
    [self updateUI];
}

- (void)setBtnTitle:(NSString *)btnTitle {
    if (!btnTitle) {
        btnTitle = @"86";
    }
    _btnTitle = btnTitle;
    [self.countryButton setTitle:[NSString stringWithFormat:@"+%@", btnTitle] forState:UIControlStateNormal];
}

- (void)tapButtonAction {
    if (self.tapAreaCodeBlock) {
        self.tapAreaCodeBlock();
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

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.textColor = RCDDYCOLOR(0x000000, 0x9f9f9f);
        _textField.font = [UIFont systemFontOfSize:15];
        _textField.returnKeyType = UIReturnKeyDone;
        _textField.delegate = self;
        _textField.keyboardType = UIKeyboardTypeDefault;
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _textField;
}

- (UIButton *)countryButton {
    if (!_countryButton) {
        _countryButton = [[UIButton alloc] init];
        _countryButton.titleLabel.font = [UIFont systemFontOfSize:15];
        _countryButton.titleLabel.textAlignment = NSTextAlignmentRight;
        [_countryButton setTitleColor:RCDDYCOLOR(0x000000, 0x9f9f9f) forState:UIControlStateNormal];
        [_countryButton addTarget:self action:@selector(tapButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _countryButton;
}

- (UIImageView *)arrowImgView {
    if (!_arrowImgView) {
        _arrowImgView = [[UIImageView alloc] init];
        _arrowImgView.image = [UIImage imageNamed:@"forward_arrow"];
        _arrowImgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapButtonAction)];
        [_arrowImgView addGestureRecognizer:tap];
    }
    return _arrowImgView;
}

@end
