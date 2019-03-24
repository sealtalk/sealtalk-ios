//
//  RCDUpdateNameViewController.m
//  RCloudMessage
//
//  Created by Liv on 15/4/2.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDUpdateNameViewController.h"

#import "UIColor+RCColor.h"
#import <RongIMKit/RongIMKit.h>

NSString *const RCDUpdateNameTableViewCellIdentifier = @"RCDUpdateNameTableViewCellIdentifier";

#define ScreenSize [UIScreen mainScreen].bounds.size

@implementation RCDUpdateNameViewController

+ (instancetype)updateNameViewController {
    return [[[self class] alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = [UIColor colorWithRed:239 / 255.0 green:239 / 255.0 blue:244 / 255.0 alpha:1];
        [self.tableView registerClass:[UITableViewCell class]
               forCellReuseIdentifier:RCDUpdateNameTableViewCellIdentifier];
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHexString:@"0195ff" alpha:1.0f]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];

    self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:RCDLocalizedString(@"cancel")

                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(backBarButtonItemClicked:)];

    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:RCDLocalizedString(@"save")

                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(rightBarButtonItemClicked:)];

    self.nameTextField.text = self.displayText;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.nameTextField.text = self.displayText;
}

- (void)backBarButtonItemClicked:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)rightBarButtonItemClicked:(id)sender {
    //保存讨论组名称
    if (self.nameTextField.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:RCDLocalizedString(@"please_type_discuss_group_name")
                                                           delegate:nil
                                                  cancelButtonTitle:RCDLocalizedString(@"confirm")

                                                  otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    //讨论组名称不能包含空格
    NSRange range = [self.nameTextField.text rangeOfString:@" "];
    if (range.location != NSNotFound) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:RCDLocalizedString(@"discuss_group_can_not_space")
                                                           delegate:nil
                                                  cancelButtonTitle:RCDLocalizedString(@"confirm")

                                                  otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }

    //回传值
    if (self.setDisplayTextCompletion) {
        self.setDisplayTextCompletion(self.nameTextField.text);
    }

    //保存设置
    [[RCIM sharedRCIM] setDiscussionName:self.targetId
                                    name:self.nameTextField.text
                                 success:^{

                                 }
                                   error:^(RCErrorCode status){

                                   }];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    //收起键盘
    [self.nameTextField resignFirstResponder];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:RCDUpdateNameTableViewCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:RCDUpdateNameTableViewCellIdentifier];
    }
    [cell.contentView addSubview:self.nameTextField];
    return cell;
}

- (UITextField *)nameTextField {
    if (!_nameTextField) {
        _nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(8, 0, ScreenSize.width - 8 - 8, 44.0f)];
        _nameTextField.font = [UIFont systemFontOfSize:14];
        _nameTextField.clearButtonMode = UITextFieldViewModeAlways;
    }
    return _nameTextField;
}
@end
