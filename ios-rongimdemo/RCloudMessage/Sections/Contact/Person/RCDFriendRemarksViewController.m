//
//  RCDFrienfRemarksViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/8/11.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDFriendRemarksViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "RCDUserInfoManager.h"
#import "UIColor+RCColor.h"
#import "RCDUIBarButtonItem.h"
#import <Masonry/Masonry.h>
#import <RongIMKit/RongIMKit.h>

#define MAX_STARWORDS_LENGTH 16

@interface RCDFriendRemarksViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) UILabel *rightLabel;
@property (nonatomic, strong) UITextField *remarksTextField;
@property (nonatomic, strong) NSString *displayName;

@end

@implementation RCDFriendRemarksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavi];
    [self setupSubviews];
    [self setupData];
    [self addObserver];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Target Action
- (void)clickRightBtn:(id)sender {
    self.rightBtn.userInteractionEnabled = NO;
    [self.remarksTextField resignFirstResponder];
    NSString *remarksStr = self.remarksTextField.text;
    if ([remarksStr isEqualToString:self.friendInfo.displayName]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = RCDLocalizedString(@"setting");
        [hud show:YES];
        [RCDUserInfoManager setFriendNickname:remarksStr
                                     byUserId:self.friendInfo.userId
                                     complete:^(BOOL result) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             self.rightBtn.userInteractionEnabled = YES;
                                             [hud hide:YES];
                                             if (result == YES) {
                                                 self.setRemarksSuccess();
                                                 [self.navigationController popViewControllerAnimated:YES];
                                             } else {
                                                 [self alertInfo:RCDLocalizedString(@"set_fail")];
                                             }
                                         });
                                     }];
    }
}

- (void)clickBackBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private Method
- (void)setupNavi {
    self.navigationItem.title = RCDLocalizedString(@"set_remarks");
    [self.rightBtn addSubview:self.rightLabel];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:self.rightBtn];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    RCDUIBarButtonItem *leftButton = [[RCDUIBarButtonItem alloc] initWithLeftBarButton:RCDLocalizedString(@"back") target:self action:@selector(clickBackBtn:)];
    self.navigationItem.leftBarButtonItem = leftButton;
}

- (void)setupSubviews {
    self.view.backgroundColor = [UIColor colorWithHexString:@"f0f0f6" alpha:1.f];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:14.f];
    titleLabel.textColor = [UIColor colorWithHexString:@"999999" alpha:1.f];
    titleLabel.text = RCDLocalizedString(@"Remark_name");
    [self.view addSubview:titleLabel];

    UIView *inputView = [[UIView alloc] init];
    inputView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:inputView];
    [inputView addSubview:self.remarksTextField];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(8);
        make.left.right.equalTo(self.view).inset(10);
        make.height.offset(20);
    }];
    
    [inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(8.5);
        make.left.right.equalTo(self.view);
        make.height.offset(44);
    }];
    
    [self.remarksTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.centerY.equalTo(inputView);
        make.left.right.equalTo(inputView).inset(10);
    }];
}

- (void)setupData {
    if (self.friendInfo.displayName != nil) {
        self.remarksTextField.text = self.friendInfo.displayName;
        self.displayName = self.friendInfo.displayName;
    } else {
        self.displayName = @"";
    }
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:self.remarksTextField];
}

- (void)alertInfo:(NSString *)infoStr {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:infoStr delegate:nil cancelButtonTitle:RCDLocalizedString(@"confirm") otherButtonTitles:nil];
    [alert show];
}

//限制备注输入长度不能大于16
- (void)textFieldEditChanged:(NSNotification *)obj {
    UITextField *textField = (UITextField *)obj.object;
    NSString *toBeString = textField.text;
    NSString *lang = [textField.textInputMode primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入
        //获取高亮部分
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];

        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > MAX_STARWORDS_LENGTH) {
                textField.text = [toBeString substringToIndex:MAX_STARWORDS_LENGTH];
            }
        }

    } else { // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        if (toBeString.length > MAX_STARWORDS_LENGTH) {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:MAX_STARWORDS_LENGTH];
            if (rangeIndex.length == 1) {
                textField.text = [toBeString substringToIndex:MAX_STARWORDS_LENGTH];
            } else {
                NSRange rangeRange =
                    [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, MAX_STARWORDS_LENGTH)];
                textField.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
    if (![toBeString isEqualToString:self.displayName]) {
        self.rightBtn.userInteractionEnabled = YES;
        [self.rightLabel setTextColor:[UIColor whiteColor]];
    } else {
        [self.rightLabel setTextColor:[UIColor colorWithHexString:@"9fcdfd" alpha:1.0]];
        self.rightBtn.userInteractionEnabled = NO;
    }
}

#pragma mark - Setter && Getter
- (UIButton *)rightBtn {
    if (!_rightBtn) {
        _rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 34)];
        _rightBtn.userInteractionEnabled = NO;
        [_rightBtn addTarget:self action:@selector(clickRightBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightBtn;
}

- (UILabel *)rightLabel {
    if (!_rightLabel) {
        _rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(22.5, 0, 50, 34)];
        _rightLabel.text = RCDLocalizedString(@"done");
        [_rightLabel setTextColor:[UIColor colorWithHexString:@"9fcdfd" alpha:1.0]];
    }
    return _rightLabel;
}

- (UITextField *)remarksTextField {
    if (!_remarksTextField) {
        _remarksTextField = [[UITextField alloc] init];
        _remarksTextField.delegate = self;
        _remarksTextField.font = [UIFont systemFontOfSize:16.f];
        _remarksTextField.textColor = [UIColor colorWithHexString:@"000000" alpha:1.f];
        _remarksTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _remarksTextField;
}

@end
