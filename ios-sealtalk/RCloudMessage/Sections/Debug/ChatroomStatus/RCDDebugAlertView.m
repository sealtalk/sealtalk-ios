//
//  RCDDebugAlertView.m
//  SealTalk
//
//  Created by 孙浩 on 2019/10/18.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDDebugAlertView.h"
#import <Masonry/Masonry.h>

#define VerticalInterval 10

@interface RCDDebugAlertView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UITextField *keyTextField;
@property (nonatomic, strong) UITextField *valueTextField;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *noticeButton;
@property (nonatomic, strong) UITextField *extraTextField;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;

@property (nonatomic, assign) RCDDebugAlertViewType alertViewType;

@end

@implementation RCDDebugAlertView

- (instancetype)initWithAlertViewType:(RCDDebugAlertViewType)type {
    if (self = [super init]) {
        [self setupUI:type];
    }
    return self;
}

- (void)setupUI:(RCDDebugAlertViewType)type {

    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    self.alertViewType = type;
    [self addSubview:self.contentView];

    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self).offset(-70);
        make.width.equalTo(self).inset(20);

    }];

    UIView *lastView = nil;
    NSString *rightTitle = @"";
    if (type == RCDDebugAlertViewTypeSet) {
        [self.contentView addSubview:self.keyTextField];
        [self.contentView addSubview:self.valueTextField];
        [self.contentView addSubview:self.deleteButton];
        [self.contentView addSubview:self.noticeButton];
        [self.contentView addSubview:self.extraTextField];
        rightTitle = @"设置";

        [self.keyTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(VerticalInterval);
            make.left.right.equalTo(self.contentView).inset(20);
            make.height.offset(30);
        }];

        [self.valueTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.keyTextField.mas_bottom).offset(VerticalInterval);
            make.left.right.height.equalTo(self.keyTextField);
        }];

        [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.valueTextField.mas_bottom).offset(VerticalInterval);
            make.centerX.equalTo(self.contentView);
            make.height.offset(40);
            make.width.offset(150);
        }];

        [self.noticeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.deleteButton.mas_bottom).offset(VerticalInterval);
            make.centerX.width.height.equalTo(self.deleteButton);
        }];

        [self.extraTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.noticeButton.mas_bottom).offset(VerticalInterval);
            make.left.right.height.equalTo(self.keyTextField);
        }];
        lastView = self.extraTextField;
    } else if (type == RCDDebugAlertViewTypeGet) {
        [self.contentView addSubview:self.keyTextField];
        rightTitle = @"获取";
        [self.keyTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(VerticalInterval);
            make.left.right.equalTo(self.contentView).inset(20);
            make.height.offset(30);
        }];
        lastView = self.keyTextField;
    } else {
        [self.contentView addSubview:self.keyTextField];
        [self.contentView addSubview:self.noticeButton];
        [self.contentView addSubview:self.extraTextField];
        rightTitle = @"删除";

        [self.keyTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(VerticalInterval);
            make.left.right.equalTo(self.contentView).inset(20);
            make.height.offset(30);
        }];

        [self.noticeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.keyTextField.mas_bottom).offset(VerticalInterval);
            make.centerX.width.equalTo(self.keyTextField);
            make.height.offset(40);
            make.width.offset(150);
        }];

        [self.extraTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.noticeButton.mas_bottom).offset(VerticalInterval);
            make.left.right.height.equalTo(self.keyTextField);
        }];

        lastView = self.extraTextField;
    }

    [self.contentView addSubview:self.leftButton];
    [self.contentView addSubview:self.rightButton];

    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lastView.mas_bottom).offset(VerticalInterval);
        make.left.equalTo(self.contentView).offset(10);
        make.right.equalTo(self.rightButton.mas_left).offset(-10);
        make.height.offset(40);
    }];

    [self.rightButton setTitle:rightTitle forState:UIControlStateNormal];
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.width.equalTo(self.leftButton);
        make.right.equalTo(self.contentView).offset(-10);
        make.bottom.equalTo(self.contentView).offset(-VerticalInterval);
    }];
}

- (void)showAlertView {
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

- (void)dismissAlertView {
    [self removeFromSuperview];
}

- (void)cancelAction {
    [self dismissAlertView];
}

- (void)rightAction {
    if (self.alertViewType == RCDDebugAlertViewTypeSet) {
        self.value = self.valueTextField.text;
        self.isDelete = self.deleteButton.isSelected;
        self.isNotice = self.noticeButton.isSelected;
        self.extra = self.extraTextField.text;
    } else if (self.alertViewType == RCDDebugAlertViewTypeDelete) {
        self.isNotice = self.noticeButton.isSelected;
        self.extra = self.extraTextField.text;
    }

    self.key = self.keyTextField.text;

    if (self.finishBlock) {
        self.finishBlock(self);
    }

    [self dismissAlertView];
}

- (void)deleteAction {
    self.deleteButton.selected = !self.deleteButton.selected;
}

- (void)noticeAction {
    self.noticeButton.selected = !self.noticeButton.selected;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.cornerRadius = 8;
        _contentView.layer.masksToBounds = YES;
    }
    return _contentView;
}

- (UITextField *)keyTextField {
    if (!_keyTextField) {
        _keyTextField = [[UITextField alloc] init];
        _keyTextField.placeholder = @"key";
        _keyTextField.layer.borderWidth = 1;
    }
    return _keyTextField;
}

- (UITextField *)valueTextField {
    if (!_valueTextField) {
        _valueTextField = [[UITextField alloc] init];
        _valueTextField.placeholder = @"value";
        _valueTextField.layer.borderWidth = 1;
    }
    return _valueTextField;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [[UIButton alloc] init];
        [_deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [_deleteButton setTitle:@"□ 退出是否删除" forState:UIControlStateNormal];
        [_deleteButton setTitle:@"✅ 退出是否删除" forState:UIControlStateSelected];
        [_deleteButton addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
        _deleteButton.layer.borderWidth = 1;
        _deleteButton.layer.cornerRadius = 8;
    }
    return _deleteButton;
}

- (UIButton *)noticeButton {
    if (!_noticeButton) {
        _noticeButton = [[UIButton alloc] init];
        [_noticeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_noticeButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [_noticeButton setTitle:@"□ 是否发送通知" forState:UIControlStateNormal];
        [_noticeButton setTitle:@"✅ 是否发送通知" forState:UIControlStateSelected];
        [_noticeButton addTarget:self action:@selector(noticeAction) forControlEvents:UIControlEventTouchUpInside];
        _noticeButton.layer.borderWidth = 1;
        _noticeButton.layer.cornerRadius = 8;
    }
    return _noticeButton;
}

- (UITextField *)extraTextField {
    if (!_extraTextField) {
        _extraTextField = [[UITextField alloc] init];
        _extraTextField.placeholder = @"extra";
        _extraTextField.layer.borderWidth = 1;
    }
    return _extraTextField;
}

- (UIButton *)leftButton {
    if (!_leftButton) {
        _leftButton = [[UIButton alloc] init];
        [_leftButton setTitle:@"取消" forState:UIControlStateNormal];
        [_leftButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        [_leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _leftButton.layer.borderWidth = 1;
        _leftButton.layer.cornerRadius = 8;
    }
    return _leftButton;
}

- (UIButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [[UIButton alloc] init];
        [_rightButton addTarget:self action:@selector(rightAction) forControlEvents:UIControlEventTouchUpInside];
        [_rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _rightButton.layer.borderWidth = 1;
        _rightButton.layer.cornerRadius = 8;
    }
    return _rightButton;
}

@end
