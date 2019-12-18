//
//  RCDPushSettingViewController.m
//  RCloudMessage
//
//  Created by Jue on 2016/12/26.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDPushSettingViewController.h"
#import "RCDBaseSettingTableViewCell.h"
#import "RCDCommonDefine.h"
#import "RCDUIBarButtonItem.h"
#import "UIColor+RCColor.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDTableView.h"
@interface RCDPushSettingViewController () <UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate,
                                            UIPickerViewDataSource, RCDBaseSettingTableViewCellDelegate>

@property (nonatomic, strong) RCDTableView *tableView;

@property (nonatomic, strong) UIPickerView *pickerView;

@end

@implementation RCDPushSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = RCDLocalizedString(@"push_setting");

    [self initUI];
}

- (void)viewDidLayoutSubviews {
    self.tableView.frame = self.view.bounds;
}

- (void)updateShowPushContentStatus:(BOOL)show {
    [[RCIMClient sharedRCIMClient]
            .pushProfile updateShowPushContentStatus:show
        success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self AlertMessage:RCDLocalizedString(@"setting_success")];
            });
        }
        error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self AlertMessage:RCDLocalizedString(@"set_fail")];
            });
        }];
}

#pragma mark - Table view Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reusableCellWithIdentifier = @"RCDBaseSettingTableViewCell";
    RCDBaseSettingTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    if (cell == nil) {
        cell = [[RCDBaseSettingTableViewCell alloc] init];
    }
    [cell setCellStyle:DefaultStyle_RightLabel];
    switch (indexPath.section) {
    case 0: {
        switch (indexPath.row) {
        case 0: {
            [cell setCellStyle:SwitchStyle];
            cell.switchButton.tag = 101;
            cell.switchButton.on = [RCIMClient sharedRCIMClient].pushProfile.isShowPushContent;
            cell.leftLabel.text = RCDLocalizedString(@"Display_remotely_pushed_content");

        } break;

        case 1: {
            //            RCPushLauguage pushLauguage = [RCIMClient sharedRCIMClient].pushProfile.pushLauguage;
            //            switch (pushLauguage) {
            //                case RCPushLauguage_ZH_CN:
            //                    cell.rightLabel.text = @"中文";
            //                    break;
            //                case RCPushLauguage_EN_US:
            //                    cell.rightLabel.text = @"英文";
            //                    break;
            //
            //                default:
            //                    break;
            //            }
            //            cell.leftLabel.text = @"语言设置";
        } break;

        case 2: {
            //          [cell setCellStyle:SwitchStyle];
            //          cell.switchButton.tag = 102;
            //          cell.switchButton.on = [RCIMClient sharedRCIMClient].pushProfile.enableMultiDevicePush;
            //          cell.leftLabel.text = @"本手机是否接收远程推送";
        } break;
        default:
            break;
        }
    } break;

    default:
        break;
    }
    cell.baseSettingTableViewDelegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
    case 0: {
        /*
        self.pickerView.hidden = NO;
        [self.view bringSubviewToFront:self.pickerView];
         */
    } break;

    default:
        break;
    }
}

#pragma mark - Picker view Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// pickerView 每列个数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 2;
}

// 每列宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return RCDScreenWidth;
}
// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
}

//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title;
    switch (row) {
    case 0:
        title = RCDLocalizedString(@"chinese");
        break;

    case 1:
        title = RCDLocalizedString(@"english");
        break;

    default:
        break;
    }
    return title;
}

#pragma mark 私有方法
- (void)setTableViewLayout {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.tableView.frame = [[UIScreen mainScreen] bounds];
    [self.view addSubview:self.tableView];

    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.scrollEnabled = NO;
}

- (void)setPickerViewLayout {
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.pickerView.showsSelectionIndicator = YES;

    CGRect frame = CGRectMake(0, RCDScreenHeight - 100 - 64, RCDScreenWidth, 100);
    self.pickerView.frame = frame;
    self.pickerView.hidden = YES;
    [self.view addSubview:self.pickerView];
}

- (void)onClickSwitchButton:(id)sender {
    UISwitch *switchButton = (UISwitch *)sender;
    switch (switchButton.tag) {
    case 101: {
        [self updateShowPushContentStatus:switchButton.on];
    } break;

    case 102: {
        //      if (switchButton.on == YES) {
        //        [[RCIMClient sharedRCIMClient].pushProfile updateMultiDevicePushStatus:YES success:^{
        //          dispatch_async(dispatch_get_main_queue(), ^{
        //            [self AlertMessage:RCDLocalizedString(@"setting_success")];
        //          });
        //        } error:^(RCErrorCode status) {
        //          dispatch_async(dispatch_get_main_queue(), ^{
        //            [self AlertMessage:RCDLocalizedString(@"set_fail")];
        //          });
        //        }];      } else {
        //          [[RCIMClient sharedRCIMClient].pushProfile updateMultiDevicePushStatus:NO success:^{
        //            dispatch_async(dispatch_get_main_queue(), ^{
        //              [self AlertMessage:RCDLocalizedString(@"setting_success")];
        //            });
        //          } error:^(RCErrorCode status) {
        //            dispatch_async(dispatch_get_main_queue(), ^{
        //              [self AlertMessage:RCDLocalizedString(@"set_fail")];
        //            });
        //          }];      }
    } break;

    default:
        break;
    }
}

- (void)clickBackBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)AlertMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController =
            [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:RCDLocalizedString(@"confirm")
                                                            style:UIAlertActionStyleDefault
                                                          handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

- (void)initUI {
    RCDUIBarButtonItem *leftBtn = [[RCDUIBarButtonItem alloc] initWithLeftBarButton:RCDLocalizedString(@"me")
                                                                             target:self
                                                                             action:@selector(clickBackBtn:)];
    self.navigationItem.leftBarButtonItem = leftBtn;

    self.tableView = [[RCDTableView alloc] init];
    [self setTableViewLayout];

    self.pickerView = [[UIPickerView alloc] init];
    //[self setPickerViewLayout];
}

@end
