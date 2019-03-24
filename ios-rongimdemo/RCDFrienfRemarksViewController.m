//
//  RCDFrienfRemarksViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/8/11.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDFrienfRemarksViewController.h"
#import "MBProgressHUD.h"
#import "RCDHttpTool.h"
#import "RCDataBaseManager.h"
#import "UIColor+RCColor.h"
#import "RCDUIBarButtonItem.h"
#define MAX_STARWORDS_LENGTH 16

@interface RCDFrienfRemarksViewController ()

@property(nonatomic, strong) UIButton *rightBtn;

@property(nonatomic, strong) UILabel *rightLabel;

@property(nonatomic, strong) UITextField *remarks;

@property(nonatomic, strong) MBProgressHUD *hud;

@property(nonatomic, strong) NSString *displayName;

@end

@implementation RCDFrienfRemarksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationItem.title = RCDLocalizedString(@"set_remarks")
;

    [self setNavigationButtons];

    [self setLayouts];

    self.view.backgroundColor = [UIColor colorWithHexString:@"f0f0f6" alpha:1.f];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldEditChanged:)
                                                 name:@"UITextFieldTextDidChangeNotification"
                                               object:self.remarks];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNavigationButtons {
    self.rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 34)];
    self.rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(22.5, 0, 50, 34)];
    self.rightLabel.text = RCDLocalizedString(@"done")
;
    [self.rightBtn addSubview:self.rightLabel];
    [self.rightBtn addTarget:self action:@selector(clickRightBtn:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:self.rightBtn];
    [self.rightLabel setTextColor:[UIColor colorWithHexString:@"9fcdfd" alpha:1.0]];
    self.rightBtn.userInteractionEnabled = NO;
    self.navigationItem.rightBarButtonItem = rightButton;

    RCDUIBarButtonItem *leftButton = [[RCDUIBarButtonItem alloc] initWithLeftBarButton:RCDLocalizedString(@"back") target:self action:@selector(clickBackBtn:)];
    [self.navigationItem setLeftBarButtonItem:leftButton];
}

- (void)clickRightBtn:(id)sender {
    self.rightBtn.userInteractionEnabled = NO;
    [self.remarks resignFirstResponder];
    NSString *remarksStr = self.remarks.text;
    if ([remarksStr isEqualToString:self.friendInfo.displayName]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.labelText = RCDLocalizedString(@"setting");
        [self.hud show:YES];
        [RCDHTTPTOOL setFriendDisplayName:self.friendInfo.userId
                              displayName:remarksStr
                                 complete:^(BOOL result) {
                                     if (result == YES) {
                                         self.rightBtn.userInteractionEnabled = YES;
                                         [self.hud hide:YES];
                                         self.friendInfo.displayName = remarksStr;
                                         [[RCDataBaseManager shareInstance] insertFriendToDB:self.friendInfo];
                                         RCUserInfo *user =
                                             [[RCUserInfo alloc] initWithUserId:self.friendInfo.userId
                                                                           name:remarksStr
                                                                       portrait:self.friendInfo.portraitUri];
                                         if ([remarksStr isEqualToString:@""]) {
                                             user.name = self.friendInfo.name;
                                         }
                                         [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:user.userId];
                                         [self.navigationController popViewControllerAnimated:YES];
                                     } else {
                                         self.rightBtn.userInteractionEnabled = YES;
                                         [self.hud hide:YES];
                                         [self aletrInfo:RCDLocalizedString(@"set_fail")];
                                     }
                                 }];
    }
}

- (void)clickBackBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setLayouts {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:14.f];
    titleLabel.textColor = [UIColor colorWithHexString:@"999999" alpha:1.f];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:titleLabel];
    titleLabel.text = RCDLocalizedString(@"Remark_name");

    UIView *inputView = [[UIView alloc] init];
    inputView.translatesAutoresizingMaskIntoConstraints = NO;
    inputView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:inputView];

    self.remarks = [[UITextField alloc] init];
    self.remarks.translatesAutoresizingMaskIntoConstraints = NO;
    self.remarks.delegate = self;
    self.remarks.font = [UIFont systemFontOfSize:16.f];
    self.remarks.textColor = [UIColor colorWithHexString:@"000000" alpha:1.f];
    self.remarks.clearButtonMode = UITextFieldViewModeWhileEditing;
    if (self.friendInfo.displayName != nil) {
        self.remarks.text = self.friendInfo.displayName;
        self.displayName = self.friendInfo.displayName;
    } else {
        self.displayName = @"";
    }
    [inputView addSubview:self.remarks];

    NSDictionary *subViews = NSDictionaryOfVariableBindings(titleLabel, inputView, _remarks);

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[titleLabel]-8.5-[inputView(44)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:subViews]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[inputView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:subViews]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-9.5-[titleLabel]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:subViews]];

    [inputView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-9.5-[_remarks]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:subViews]];

    [inputView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_remarks]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:subViews]];

    [inputView addConstraint:[NSLayoutConstraint constraintWithItem:self.remarks
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:inputView
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1
                                                           constant:0]];
}

- (void)aletrInfo:(NSString *)infoStr {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:infoStr
                                                   delegate:nil
                                          cancelButtonTitle:RCDLocalizedString(@"confirm")

                                          otherButtonTitles:nil];
    [alert show];
}

//限制备注输入长度不能大于16
- (void)textFieldEditChanged:(NSNotification *)obj {
    UITextField *textField = (UITextField *)obj.object;
    NSString *toBeString = textField.text;
    NSString *lang = [textField.textInputMode primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"]) // 简体中文输入
    {
        //获取高亮部分
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];

        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > MAX_STARWORDS_LENGTH) {
                textField.text = [toBeString substringToIndex:MAX_STARWORDS_LENGTH];
            }
        }

    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else {
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
