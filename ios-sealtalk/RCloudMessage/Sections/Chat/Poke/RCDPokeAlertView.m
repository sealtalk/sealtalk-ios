//
//  RCDPokeAlertView.m
//  SealTalk
//
//  Created by 张改红 on 2019/8/1.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDPokeAlertView.h"
#import <Masonry/Masonry.h>
#import "RCDGroupManager.h"
#import "RCDUserInfoManager.h"
#import "RCDGroupMemberSelectController.h"
#import "RCDPokeMessage.h"
#import "UIView+MBProgressHUD.h"
#import "RCDPokeManager.h"
#import "RCDUtilities.h"
@interface RCDPokeAlertView () <UITextFieldDelegate>
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *pokeIcon;
@property (nonatomic, strong) UILabel *infolabel;
@property (nonatomic, strong) UILabel *sendLabel;
@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, strong) UIImageView *arrowIcon;
@property (nonatomic, strong) UITextField *inputTextField;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, assign) RCConversationType type;
@property (nonatomic, strong) NSString *targetId;
@property (nonatomic, strong) UIViewController *baseController;
@property (nonatomic, strong) NSArray *selectIds;
@end
@implementation RCDPokeAlertView
+ (void)showPokeAlertView:(RCConversationType)type
                 targetId:(NSString *)targetId
         inViewController:(UIViewController *)controller {
    NSInteger restTime = 60 - [[RCDPokeManager sharedInstance] getLastSendPokeTimeInterval:type targetId:targetId];
    if (restTime > 0) {
        [controller.view showHUDMessage:[NSString stringWithFormat:RCDLocalizedString(@"PokeTime"), restTime]];
    } else {
        RCDPokeAlertView *pokeView = [[RCDPokeAlertView alloc] initWithFrame:controller.view.bounds];
        [pokeView registerNotification];
        pokeView.backgroundColor = [RCDUtilities generateDynamicColor:[HEXCOLOR(0x000000) colorWithAlphaComponent:0.21]
                                                            darkColor:[HEXCOLOR(0x6a6a6a) colorWithAlphaComponent:0.6]];
        pokeView.type = type;
        pokeView.targetId = targetId;
        pokeView.baseController = controller;
        [pokeView setupSubviews];
        [pokeView show];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UITapGestureRecognizer *resetBottomTapGesture =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
        [self.bgView addGestureRecognizer:resetBottomTapGesture];
        [self addGestureRecognizer:resetBottomTapGesture];
    }
    return self;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self hideKeyboard];
    return YES;
}

- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (text.length > 20) {
        textField.text = [text substringWithRange:NSMakeRange(0, 20)];
        [self showHUDMessage:RCDLocalizedString(@"PokeContentMaxCount")];
        return NO;
    }
    return YES;
}

#pragma mark - helper
- (void)hideKeyboard {
    [self.inputTextField resignFirstResponder];
}

- (void)show {
    [self hideKeyboard];
    [self hiden];
    [RCDPokeManager sharedInstance].isShowPokeAlert = YES;
    [self.baseController.view addSubview:self];
    [self registerNotification];
}

- (void)hiden {
    [RCDPokeManager sharedInstance].isShowPokeAlert = NO;
    [self removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onSelectPressed {
    RCDGroupMemberSelectController *selectVC =
        [[RCDGroupMemberSelectController alloc] initWithGroupId:self.targetId type:(RCDGroupMemberSelectTypePoke)];
    __weak typeof(self) weakSelf = self;
    [selectVC setSelectResult:^(NSArray<NSString *> *_Nonnull memberIds) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.selectIds = memberIds;
            [weakSelf setSelectUserInfo];
        });
    }];
    [self.baseController.navigationController pushViewController:selectVC animated:YES];
}

- (void)onCanelPressed {
    [self hiden];
}

- (void)onConfirmPressed {
    RCDPokeMessage *message = [[RCDPokeMessage alloc] init];
    message.content = self.inputTextField.text.length > 0 ? self.inputTextField.text : self.inputTextField.placeholder;
    if (self.selectIds.count > 0) {
        [[RCIM sharedRCIM] sendDirectionalMessage:self.type
            targetId:self.targetId
            toUserIdList:self.selectIds
            content:message
            pushContent:nil
            pushData:nil
            success:^(long messageId) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[RCDPokeManager sharedInstance] saveSendPokeTime:self.type targetId:self.targetId];
                });
            }
            error:^(RCErrorCode nErrorCode, long messageId){

            }];
    } else {
        [[RCIM sharedRCIM] sendMessage:self.type
            targetId:self.targetId
            content:message
            pushContent:nil
            pushData:nil
            success:^(long messageId) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[RCDPokeManager sharedInstance] saveSendPokeTime:self.type targetId:self.targetId];
                });
            }
            error:^(RCErrorCode nErrorCode, long messageId){

            }];
    }
    [self hiden];
}

- (void)setSelectUserInfo {
    NSString *names = @"";
    for (NSString *userId in self.selectIds) {
        if (names.length >= 10) {
            names = [names stringByAppendingString:@"..."];
            break;
        }
        RCUserInfo *user = [RCDUserInfoManager getUserInfo:userId];
        RCDFriendInfo *friend = [RCDUserInfoManager getFriendInfo:user.userId];
        NSString *str = user.name;
        if (friend.displayName.length > 0) {
            str = friend.displayName;
        }
        names = [names stringByAppendingString:str];
        if (names.length >= 10) {
            names = [names substringWithRange:NSMakeRange(0, 10)];
            break;
        }
        if (names.length > 0 && ![self.selectIds[self.selectIds.count - 1] isEqual:userId]) {
            names = [names stringByAppendingString:@","];
        }
    }
    [self.selectButton setTitle:names forState:(UIControlStateNormal)];
}

#pragma mark - Notification

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

//键盘升起时动画
- (void)keyboardWillShow:(NSNotification *)notif {
    CGRect keyboardBounds = [notif.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat space = CGRectGetMaxY(self.bgView.frame) - keyboardBounds.origin.y;
    if (space > 0) {
        CGFloat bgHeight = (self.type == ConversationType_PRIVATE ? 300 : 335);
        [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self).offset(-space);
            make.centerX.equalTo(self);
            make.height.offset(bgHeight);
            make.width.offset(310);
        }];
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
}

//键盘关闭时动画
- (void)keyboardWillHide:(NSNotification *)notif {
    CGFloat bgHeight = (self.type == ConversationType_PRIVATE ? 300 : 335);
    [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.centerX.equalTo(self);
        make.height.offset(bgHeight);
        make.width.offset(310);
    }];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - Subviews
- (void)setupSubviews {
    [self addSubview:self.bgView];
    CGFloat bgHeight = (self.type == ConversationType_PRIVATE ? 300 : 335);
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.centerX.equalTo(self);
        make.height.offset(bgHeight);
        make.width.offset(310);
    }];

    [self.bgView addSubview:self.pokeIcon];
    [self.bgView addSubview:self.infolabel];
    UIView *inputBgView = [[UIView alloc] init];
    inputBgView.backgroundColor = [RCDUtilities generateDynamicColor:HEXCOLOR(0xf8f8f8)
                                                           darkColor:[HEXCOLOR(0x808080) colorWithAlphaComponent:0.2]];
    inputBgView.layer.masksToBounds = YES;
    inputBgView.layer.borderColor = [RCDUtilities generateDynamicColor:HEXCOLOR(0x999999)
                                                             darkColor:[HEXCOLOR(0x808080) colorWithAlphaComponent:0.3]]
                                        .CGColor;
    inputBgView.layer.borderWidth = 0.5;
    [self.bgView addSubview:inputBgView];
    [self.bgView addSubview:self.inputTextField];
    [self.bgView addSubview:self.cancelButton];
    [self.bgView addSubview:self.confirmButton];
    UIView *hLineView = [self getLineView];
    UIView *vLineView = [self getLineView];
    [self.bgView addSubview:hLineView];
    [self.bgView addSubview:vLineView];
    [self.pokeIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgView).offset(32);
        make.centerX.equalTo(self.bgView);
        make.height.offset(110);
        make.width.offset(88);
    }];
    [self.infolabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pokeIcon.mas_bottom).offset(20);
        make.left.equalTo(self.bgView).offset(10);
        make.centerX.equalTo(self.bgView);
        make.height.offset(24);
    }];

    if (self.type == ConversationType_GROUP) {
        [self.bgView addSubview:self.sendLabel];
        [self.bgView addSubview:self.selectButton];
        [self.bgView addSubview:self.arrowIcon];
        [self.sendLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.infolabel.mas_bottom).offset(15);
            make.left.equalTo(self.bgView).offset(10);
            make.height.offset(24);
        }];
        [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.sendLabel);
            make.left.equalTo(self.sendLabel.mas_right).offset(10);
            make.right.equalTo(self.bgView).offset(-20);
            make.height.offset(24);
        }];
        [self.arrowIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.sendLabel);
            make.right.equalTo(self.bgView).offset(-10);
            make.height.offset(13);
            make.width.offset(8);
        }];
    }
    CGFloat inputTop = (self.type == ConversationType_PRIVATE ? 200 : 236);
    [inputBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgView).offset(inputTop);
        make.left.equalTo(self.bgView).offset(10);
        make.centerX.equalTo(self.bgView);
        make.height.offset(35);
    }];
    [self.inputTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.centerX.equalTo(inputBgView);
        make.left.equalTo(inputBgView).offset(10);
    }];

    [hLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.inputTextField.mas_bottom).offset(20);
        make.left.right.equalTo(self.bgView);
        make.height.offset(0.5);
    }];

    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.equalTo(self.bgView);
        make.top.equalTo(hLineView.mas_bottom);
        make.width.equalTo(self.bgView).multipliedBy(0.5);
    }];
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.equalTo(self.bgView);
        make.top.equalTo(self.cancelButton);
        make.width.equalTo(self.cancelButton);
    }];

    [vLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(self.confirmButton);
        make.width.equalTo(@0.5);
        make.height.equalTo(self.cancelButton);
    }];
}

#pragma mark - getter
- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [RCDUtilities generateDynamicColor:HEXCOLOR(0xf8f8f8)
                                                           darkColor:[HEXCOLOR(0x000000) colorWithAlphaComponent:0.8]];
        _bgView.layer.masksToBounds = YES;
        _bgView.layer.cornerRadius = 6;
    }
    return _bgView;
}

- (UIImageView *)pokeIcon {
    if (!_pokeIcon) {
        _pokeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"poke_alert"]];
    }
    return _pokeIcon;
}

- (UILabel *)infolabel {
    if (!_infolabel) {
        _infolabel = [[UILabel alloc] init];
        _infolabel.font = [UIFont systemFontOfSize:17];
        _infolabel.textColor = RCDDYCOLOR(0x333333, 0x9f9f9f);
        _infolabel.textAlignment = NSTextAlignmentCenter;
        if (self.type == ConversationType_GROUP) {
            RCGroup *group = [[RCIM sharedRCIM] getGroupInfoCache:self.targetId];
            _infolabel.text = [NSString stringWithFormat:RCDLocalizedString(@"SendToPokeNotice"), group.groupName];
        } else {
            RCUserInfo *userInfo = [[RCIM sharedRCIM] getUserInfoCache:self.targetId];
            _infolabel.text = [NSString stringWithFormat:RCDLocalizedString(@"SendToPokeNotice"), userInfo.name];
        }
    }
    return _infolabel;
}

- (UILabel *)sendLabel {
    if (!_sendLabel) {
        _sendLabel = [[UILabel alloc] init];
        _sendLabel.font = [UIFont systemFontOfSize:17];
        _sendLabel.textColor = RCDDYCOLOR(0x333333, 0x9f9f9f);
        _sendLabel.text = RCDLocalizedString(@"SendTo");
    }
    return _sendLabel;
}

- (UIButton *)selectButton {
    if (!_selectButton) {
        _selectButton = [[UIButton alloc] init];
        [_selectButton setTitle:RCDLocalizedString(@"SendToGroupAllMembers") forState:UIControlStateNormal];
        [_selectButton setTitleColor:HEXCOLOR(0x666666) forState:(UIControlStateNormal)];
        [_selectButton addTarget:self action:@selector(onSelectPressed) forControlEvents:UIControlEventTouchUpInside];
        [_selectButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
        _selectButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    }
    return _selectButton;
}

- (UIImageView *)arrowIcon {
    if (!_arrowIcon) {
        _arrowIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right_arrow"]];
    }
    return _arrowIcon;
}

- (UITextField *)inputTextField {
    if (!_inputTextField) {
        _inputTextField = [[UITextField alloc] init];
        _inputTextField.font = [UIFont systemFontOfSize:15];
        _inputTextField.textColor = RCDDYCOLOR(0x333333, 0x9f9f9f);
        _inputTextField.placeholder = RCDLocalizedString(@"PokeInputPlaceholder");
        NSAttributedString *attrString =
            [[NSAttributedString alloc] initWithString:_inputTextField.placeholder
                                            attributes:@{
                                                NSForegroundColorAttributeName : RCDDYCOLOR(0x999999, 0x666666),
                                                NSFontAttributeName : _inputTextField.font
                                            }];
        _inputTextField.attributedPlaceholder = attrString;
        _inputTextField.delegate = self;
    }
    return _inputTextField;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] init];
        [_cancelButton setTitle:RCDLocalizedString(@"cancel") forState:UIControlStateNormal];
        [_cancelButton setTitleColor:RCDDYCOLOR(0x999999, 0x666666) forState:(UIControlStateNormal)];
        [_cancelButton addTarget:self action:@selector(onCanelPressed) forControlEvents:UIControlEventTouchUpInside];
        [_cancelButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    }
    return _cancelButton;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] init];
        [_confirmButton setTitle:RCDLocalizedString(@"confirm") forState:UIControlStateNormal];
        [_confirmButton setTitleColor:RCDDYCOLOR(0x0099ff, 0x007acc) forState:(UIControlStateNormal)];
        [_confirmButton addTarget:self action:@selector(onConfirmPressed) forControlEvents:UIControlEventTouchUpInside];
        [_confirmButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    }
    return _confirmButton;
}

- (UIView *)getLineView {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = RCDDYCOLOR(0xd8d8d8, 0x3a3a3a);
    return view;
}
@end
