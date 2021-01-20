//
//  RCDGroupMyInfoCell.m
//  SealTalk
//
//  Created by 张改红 on 2019/8/6.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDGroupMemberDetailCell.h"
#import <Masonry/Masonry.h>
#import "RCDUtilities.h"

@interface RCDGroupMemberDetailCell () <UITextViewDelegate>
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIButton *regionButton;
@property (nonatomic, strong) UIButton *clearButton;
@end
@implementation RCDGroupMemberDetailCell
+ (CGFloat)getCellHeight:(UITableView *)tableView leftTitle:(NSString *)leftTitle text:(NSString *)text {
    CGFloat height = 44;
    RCDGroupMemberDetailCell *cell = [[RCDGroupMemberDetailCell alloc] init];
    CGRect rect = cell.contentView.frame;
    rect.size.width = tableView.frame.size.width;
    cell.contentView.frame = rect;
    cell.titleLabel.text = leftTitle;
    [cell setDetailInfo:text];
    [cell showClearButton:NO];
    if ([leftTitle isEqualToString:RCDLocalizedString(@"Describe")]) {
        [cell showClearButton:YES];
    }
    if (text && cell.textView.contentSize.height > 44) {
        height = cell.textView.contentSize.height + 10;
    }
    return height;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    RCDGroupMemberDetailCell *cell =
        (RCDGroupMemberDetailCell *)[tableView dequeueReusableCellWithIdentifier:RCDGroupMyInfoCellIdentifier];
    if (!cell) {
        cell = [[RCDGroupMemberDetailCell alloc] init];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubviews];
    }
    return self;
}

- (void)setLeftTitle:(NSString *)leftTitle placeholder:(nonnull NSString *)placeholder {

    [self setPhoneRegionCode:@""];
    self.titleLabel.text = leftTitle;
    if (placeholder.length > 0) {
        self.textView.userInteractionEnabled = YES;
        self.textView.myPlaceholder = placeholder;
    } else {
        self.textView.userInteractionEnabled = NO;
    }

    if ([leftTitle isEqualToString:RCDLocalizedString(@"Describe")]) {
        [self showSeparateLine:YES];
        self.textView.textAlignment = NSTextAlignmentLeft;
    } else {
        [self showSeparateLine:NO];
        self.textView.textAlignment = NSTextAlignmentRight;
    }
}

- (void)setDetailInfo:(NSString *)detail {
    self.textView.text = detail;
}

- (void)setPhoneRegionCode:(NSString *)code {
    if (code.length > 0) {
        self.regionButton.enabled = YES;
        self.regionButton.hidden = NO;
        [self.regionButton setTitle:[NSString stringWithFormat:@"+%@     ", code] forState:(UIControlStateNormal)];
    } else {
        self.regionButton.hidden = YES;
        self.regionButton.enabled = NO;
    }
}

- (void)showClearButton:(BOOL)show {
    if (show) {
        [self.contentView addSubview:self.clearButton];
        [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.regionButton.mas_right);
            make.right.equalTo(self.clearButton.mas_left).offset(0);
            make.centerY.equalTo(self.contentView);
            make.height.greaterThanOrEqualTo(self.contentView).offset(-10);
        }];
        [self.clearButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView);
            make.centerY.equalTo(self.contentView);
            make.width.height.offset(32);
        }];
    } else {
        [self.clearButton removeFromSuperview];
        [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.regionButton.mas_right);
            make.right.equalTo(self.contentView).offset(-10);
            make.centerY.equalTo(self.contentView);
            make.height.greaterThanOrEqualTo(self.contentView).offset(-10);
        }];
    }
    [self.contentView updateConstraintsIfNeeded];
    [self.contentView layoutIfNeeded];
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewWillBeginEditing:inCell:)]) {
        [self.delegate textViewWillBeginEditing:textView inCell:self];
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    //在末尾输入，不拦截，textViewDidChange里面会截取处理
    if (range.location == textView.text.length - 1) {
        return YES;
    }
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:inCell:)]) {
        return [self.delegate textView:textView shouldChangeTextInRange:range replacementText:text inCell:self];
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidChange:inCell:)]) {
        [self.delegate textViewDidChange:textView inCell:self];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidEndEditing:inCell:)]) {
        [self.delegate textViewDidEndEditing:textView inCell:self];
    }
}

#pragma mark - helper
- (void)didClickRegionAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSelectPhoneRegionCode:)]) {
        [self.delegate onSelectPhoneRegionCode:self];
    }
}

- (void)didClickClearAction {
    self.textView.text = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidChange:inCell:)]) {
        [self.delegate textViewDidChange:self.textView inCell:self];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidEndEditing:inCell:)]) {
        [self.delegate textViewDidEndEditing:self.textView inCell:self];
    }
}

- (void)showSeparateLine:(BOOL)show {
    self.lineView.hidden = !show;
}

- (void)addSubviews {
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.textView];
    [self.contentView addSubview:self.regionButton];
    [self.contentView addSubview:self.lineView];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(10);
        make.height.equalTo(self.contentView);
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.contentView);
        make.height.equalTo(self.contentView);
        make.left.equalTo(self.titleLabel.mas_right).offset(15);
        make.width.offset(1);
    }];
    [self.regionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.lineView.mas_right).offset(-10);
        make.height.equalTo(self.contentView);
    }];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.regionButton.mas_right);
        make.right.equalTo(self.contentView).offset(-10);
        make.centerY.equalTo(self.contentView);
        make.height.greaterThanOrEqualTo(self.contentView).offset(-10);
    }];
}

#pragma mark - getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = RCDDYCOLOR(0x262626, 0x9f9f9f);
    }
    return _titleLabel;
}

- (UITextViewAndPlaceholder *)textView {
    if (!_textView) {
        _textView = [[UITextViewAndPlaceholder alloc] init];
        _textView.delegate = self;
        _textView.font = [UIFont systemFontOfSize:15.f];
        _textView.textColor = RCDDYCOLOR(0x999999, 0x666666);
        _textView.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        _textView.myPlaceholderColor = RCDDYCOLOR(0x999999, 0x666666);
        _textView.returnKeyType = UIReturnKeyDone;
    }
    return _textView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = RCDDYCOLOR(0xd8d8d8, 0x3a3a3a);
    }
    return _lineView;
}

- (UIButton *)regionButton {
    if (!_regionButton) {
        _regionButton = [[UIButton alloc] init];
        [_regionButton setTitleColor:RCDDYCOLOR(0x999999, 0x666666) forState:(UIControlStateNormal)];
        _regionButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_regionButton addTarget:self
                          action:@selector(didClickRegionAction)
                forControlEvents:(UIControlEventTouchUpInside)];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"forward_arrow"]];
        [_regionButton addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_regionButton);
            make.centerY.equalTo(_regionButton);
            make.width.height.offset(20);
        }];
    }
    return _regionButton;
}

- (UIButton *)clearButton {
    if (!_clearButton) {
        _clearButton = [[UIButton alloc] init];
        [_clearButton addTarget:self
                         action:@selector(didClickClearAction)
               forControlEvents:(UIControlEventTouchUpInside)];
        _clearButton.titleLabel.font = [UIFont systemFontOfSize:10];
        [_clearButton setTitle:@"X" forState:(UIControlStateNormal)];
        [_clearButton setTitleColor:HEXCOLOR(0xffffff) forState:(UIControlStateNormal)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(7, 8, 15, 15)];
        label.text = @"X";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = HEXCOLOR(0xffffff);
        label.font = [UIFont systemFontOfSize:10];
        label.backgroundColor = HEXCOLOR(0xc0c0c0);
        label.layer.masksToBounds = YES;
        label.layer.cornerRadius = 7.5;
        [_clearButton addSubview:label];
    }
    return _clearButton;
}
@end
