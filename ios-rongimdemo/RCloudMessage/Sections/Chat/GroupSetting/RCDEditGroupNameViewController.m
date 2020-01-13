//
//  RCDEditGroupNameViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/3/28.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDEditGroupNameViewController.h"
#import "RCDUIBarButtonItem.h"
#import "RCDGroupManager.h"
#import "UIColor+RCColor.h"
#import <RongIMKit/RongIMKit.h>

@interface RCDEditGroupNameViewController ()
/**
 *  修改群名称的textFiled
 */
@property (nonatomic, strong) UITextField *groupNameTextField;

@property (nonatomic, strong) RCDUIBarButtonItem *rightBtn;

@end

@implementation RCDEditGroupNameViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.groupNameTextField.text = self.groupInfo.groupName;
    [self initSubViews];
    [self setNaviItem];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
    NSString *changedStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (changedStr.length > 0) {
        [self.rightBtn buttonIsCanClick:YES buttonColor:RCDDYCOLOR(0xffffff, 0xA8A8A8) barButtonItem:self.rightBtn];
    } else {
        [self.rightBtn
            buttonIsCanClick:NO
                 buttonColor:[RCDUtilities generateDynamicColor:HEXCOLOR(0x9fcdfd)
                                                      darkColor:[HEXCOLOR(0xA8A8A8) colorWithAlphaComponent:0.4]]
               barButtonItem:self.rightBtn];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self.rightBtn buttonIsCanClick:NO
                        buttonColor:[RCDUtilities generateDynamicColor:HEXCOLOR(0x9fcdfd)
                                                             darkColor:[HEXCOLOR(0xA8A8A8) colorWithAlphaComponent:0.4]]
                      barButtonItem:self.rightBtn];
    return YES;
}

#pragma mark - target action
- (void)clickDone:(id)sender {
    [self.rightBtn buttonIsCanClick:NO
                        buttonColor:[RCDUtilities generateDynamicColor:HEXCOLOR(0x9fcdfd)
                                                             darkColor:[HEXCOLOR(0xA8A8A8) colorWithAlphaComponent:0.4]]
                      barButtonItem:self.rightBtn];
    NSString *nameStr =
        [_groupNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([self groupNameIsAvailable:nameStr]) {
        [RCDGroupManager setGroupName:nameStr
                              groupId:self.groupInfo.groupId
                             complete:^(BOOL success) {
                                 rcd_dispatch_main_async_safe(^{
                                     if (success == YES) {
                                         [self.navigationController popViewControllerAnimated:YES];
                                     } else {
                                         [self Alert:RCDLocalizedString(@"Group_name_modification_failed")];
                                     }
                                 });
                             }];
    }
}

#pragma mark - helper
- (void)initSubViews {
    // backgroundView
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, RCDScreenWidth, 44)];
    bgView.backgroundColor = [RCDUtilities generateDynamicColor:HEXCOLOR(0xffffff)
                                                      darkColor:[HEXCOLOR(0x808080) colorWithAlphaComponent:0.2]];
    [self.view addSubview:bgView];

    // groupNameTextField
    CGFloat groupNameTextFieldWidth = RCDScreenWidth - 8 - 8;
    self.groupNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(8, 10, groupNameTextFieldWidth, 44)];
    self.groupNameTextField.clearButtonMode = UITextFieldViewModeAlways;
    self.groupNameTextField.font = [UIFont systemFontOfSize:14];
    self.groupNameTextField.textColor = RCDDYCOLOR(0x000000, 0xffffff);
    [self.view addSubview:self.groupNameTextField];
    self.groupNameTextField.delegate = self;
}

- (void)setNaviItem {
    //自定义rightBarButtonItem
    self.rightBtn = [[RCDUIBarButtonItem alloc]
        initWithbuttonTitle:RCDLocalizedString(@"save")
                 titleColor:[RCDUtilities generateDynamicColor:HEXCOLOR(0x9fcdfd)
                                                     darkColor:[HEXCOLOR(0xA8A8A8) colorWithAlphaComponent:0.4]]
                buttonFrame:CGRectMake(0, 0, 50, 30)
                     target:self
                     action:@selector(clickDone:)];
    [self.rightBtn buttonIsCanClick:NO
                        buttonColor:[RCDUtilities generateDynamicColor:HEXCOLOR(0x9fcdfd)
                                                             darkColor:[HEXCOLOR(0xA8A8A8) colorWithAlphaComponent:0.4]]
                      barButtonItem:self.rightBtn];
    self.navigationItem.rightBarButtonItems = [self.rightBtn setTranslation:self.rightBtn translation:-11];
}

- (void)Alert:(NSString *)alertContent {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                 message:alertContent
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:RCDLocalizedString(@"confirm")
                                                            style:UIAlertActionStyleDefault
                                                          handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

- (BOOL)groupNameIsAvailable:(NSString *)nameStr {
    if ([nameStr length] == 0) {
        //群组名称不存在
        [self Alert:RCDLocalizedString(@"group_name_can_not_nil")];
        return NO;
    } else if ([nameStr length] < 2) {
        //群组名称需要大于2个字
        [self Alert:RCDLocalizedString(@"Group_name_is_too_short")];
        return NO;
    } else if ([nameStr length] > 10) {
        //群组名称需要小于10个字
        [self Alert:RCDLocalizedString(@"Group_name_cannot_exceed_10_words")];
        return NO;
    }
    return YES;
}
@end
