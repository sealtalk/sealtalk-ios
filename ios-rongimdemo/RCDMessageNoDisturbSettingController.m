//
//  RCDMessageNoDisturbSettingController.m
//  RCloudMessage
//
//  Created by 张改红 on 15/7/15.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDMessageNoDisturbSettingController.h"
#import <RongIMKit/RongIMKit.h>

#define UserDefaults [NSUserDefaults standardUserDefaults]
@interface RCDMessageNoDisturbSettingController ()
@property(nonatomic, strong) NSIndexPath *indexPath;
@property(nonatomic, copy) NSString *start;
@property(nonatomic, copy) NSString *end;
@property(nonatomic, assign) BOOL displaySetting;
@property(nonatomic, strong) UIDatePicker *datePicker;
@property(nonatomic, strong) NSIndexPath *startIndexPath;
@property(nonatomic, strong) NSIndexPath *endIndexPath;
@end

@implementation RCDMessageNoDisturbSettingController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.displaySetting = NO;
    [self getNoDisturbStaus];
}

- (void)getNoDisturbStaus {
    __weak typeof(self) weakSelf = self;
    [[RCIMClient sharedRCIMClient] getNotificationQuietHours:^(NSString *startTime, int spansMin) {
        NSDateFormatter *formatterE = [[NSDateFormatter alloc] init];
        [formatterE setDateFormat:@"HH:mm:ss"];
        NSDate *startDate = [formatterE dateFromString:startTime];
        NSDate *endDate = [startDate dateByAddingTimeInterval:60 * spansMin];
        NSString *endTime = [formatterE stringFromDate:endDate];
        if (spansMin > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *startIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
                NSIndexPath *endIndexPath = [NSIndexPath indexPathForRow:1 inSection:1];
                UITableViewCell *startCell = [weakSelf.tableView cellForRowAtIndexPath:startIndexPath];
                UITableViewCell *endCell = [weakSelf.tableView cellForRowAtIndexPath:endIndexPath];
                weakSelf.swch.on = YES;
                startCell.detailTextLabel.text = startTime;
                endCell.detailTextLabel.text = endTime;
                weakSelf.displaySetting = YES;
                [weakSelf.tableView reloadData];
                [weakSelf.tableView selectRowAtIndexPath:weakSelf.startIndexPath
                                            animated:YES
                                      scrollPosition:UITableViewScrollPositionMiddle];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *startT = [UserDefaults
                    objectForKey:[NSString stringWithFormat:@"startTime_%@", [RCIM sharedRCIM].currentUserInfo.userId]];
                NSString *endT = [UserDefaults
                    objectForKey:[NSString stringWithFormat:@"endTime_%@", [RCIM sharedRCIM].currentUserInfo.userId]];
                NSIndexPath *startIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
                NSIndexPath *endIndexPath = [NSIndexPath indexPathForRow:1 inSection:1];
                UITableViewCell *startCell = [weakSelf.tableView cellForRowAtIndexPath:startIndexPath];
                UITableViewCell *endCell = [weakSelf.tableView cellForRowAtIndexPath:endIndexPath];
                if (startT && endT) {
                    startCell.detailTextLabel.text = startT;
                    endCell.detailTextLabel.text = endT;
                } else {
                    startCell.detailTextLabel.text = @"23:00:00";
                    endCell.detailTextLabel.text = @"07:00:00";
                }
                weakSelf.swch.on = NO;
            });
        }
    }
        error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *startT = [UserDefaults
                    objectForKey:[NSString stringWithFormat:@"startTime_%@", [RCIM sharedRCIM].currentUserInfo.userId]];
                NSString *endT = [UserDefaults
                    objectForKey:[NSString stringWithFormat:@"endTime_%@", [RCIM sharedRCIM].currentUserInfo.userId]];
                NSIndexPath *startIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
                NSIndexPath *endIndexPath = [NSIndexPath indexPathForRow:1 inSection:1];
                UITableViewCell *startCell = [weakSelf.tableView cellForRowAtIndexPath:startIndexPath];
                UITableViewCell *endCell = [weakSelf.tableView cellForRowAtIndexPath:endIndexPath];
                if (startT && endT) {
                    startCell.detailTextLabel.text = startT;
                    endCell.detailTextLabel.text = endT;
                } else {
                    startCell.detailTextLabel.text = @"23:00:00";
                    endCell.detailTextLabel.text = @"07:00:00";
                }
                weakSelf.swch.on = NO;
            });
        }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _swch = [[UISwitch alloc] init];
    self.title = RCDLocalizedString(@"Do_not_disturb_setting");
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeCountDownTimer;
    NSDateFormatter *formatterE = [[NSDateFormatter alloc] init];
    [formatterE setDateFormat:@"HH:mm:ss"];
    NSString *startTime = [UserDefaults
        objectForKey:[NSString stringWithFormat:@"startTime_%@", [RCIM sharedRCIM].currentUserInfo.userId]];
    if (startTime == nil) {
        startTime = @"23:00:00";
    }
    NSDate *startDate = [formatterE dateFromString:startTime];
    [self.datePicker setDate:startDate];
    [self.datePicker addTarget:self
                        action:@selector(datePickerValueChanged:)
              forControlEvents:UIControlEventValueChanged];
    self.tableView.tableFooterView = [UIView new];
    self.startIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    [self.tableView selectRowAtIndexPath:self.startIndexPath
                                animated:YES
                          scrollPosition:UITableViewScrollPositionMiddle];
    self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    self.endIndexPath = [NSIndexPath indexPathForRow:1 inSection:1];
}

- (void)viewDidLayoutSubviews {
    self.tableView.frame = self.view.frame;
    [self.swch setFrame:CGRectMake(self.view.frame.size.width - self.swch.frame.size.width - 15, 6, 0, 0)];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    UITableViewCell *startCell = [self.tableView cellForRowAtIndexPath:self.startIndexPath];
    UITableViewCell *endCell = [self.tableView cellForRowAtIndexPath:self.endIndexPath];
    NSString *startTime = startCell.detailTextLabel.text;
    NSString *endTime = endCell.detailTextLabel.text;
    if (_swch.on) {
        if (startTime.length == 0 || endTime.length == 0 || (startTime == _start && endTime == _end)) {
            return;
        }
        NSDateFormatter *formatterE = [[NSDateFormatter alloc] init];
        [formatterE setDateFormat:@"HH:mm:ss"];
        NSDate *startDate = [formatterE dateFromString:startTime];
        NSDate *endDate = [formatterE dateFromString:endTime];
        double timeDiff = [endDate timeIntervalSinceDate:startDate];
        if (timeDiff < 0) {
            startDate = [NSDate dateWithTimeInterval:-24 * 60 * 60 sinceDate:startDate];
            timeDiff = [endDate timeIntervalSinceDate:startDate];
        }

        int timeDif = timeDiff / 60;
        [[RCIMClient sharedRCIMClient] setNotificationQuietHours:startTime
            spanMins:timeDif
            success:^{
                [UserDefaults
                    setObject:startTime
                       forKey:[NSString stringWithFormat:@"startTime_%@", [RCIM sharedRCIM].currentUserInfo.userId]];
                [UserDefaults
                    setObject:endTime
                       forKey:[NSString stringWithFormat:@"endTime_%@", [RCIM sharedRCIM].currentUserInfo.userId]];
            }
            error:^(RCErrorCode status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:RCDLocalizedString(@"alert")
                                                                    message:RCDLocalizedString(@"set_fail")
                                                                   delegate:nil
                                                          cancelButtonTitle:RCDLocalizedString(@"cancel")

                                                          otherButtonTitles:nil, nil];
                    [alert show];
                });
            }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    else if (section == 1) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 70;
    }
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 1) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
        view.backgroundColor = self.tableView.backgroundColor;
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(20, -5, view.frame.size.width - 40, 70);
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor grayColor];
        label.text = RCDLocalizedString(@"mute_notifications_prompt");
        [view addSubview:label];
        return view;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 || indexPath.section == 1) {
        return 44;
    }
    return 200;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCellReuseIdentifier"];
    if (!cell) {
        cell =
            [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MyCellReuseIdentifier"];
    }
    if (indexPath.section == 0) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = RCDLocalizedString(@"Turn_on_message_do_not_disturb");
            [_swch setFrame:CGRectMake(self.view.frame.size.width - _swch.frame.size.width - 15, 6, 0, 0)];
            [_swch addTarget:self action:@selector(setSwitchState:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:_swch];
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = RCDLocalizedString(@"Start_time");
        } else {
            cell.textLabel.text = RCDLocalizedString(@"end_time");
        }
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView addSubview:self.datePicker];
    }
    if (self.displaySetting == NO) {
        cell.hidden = YES;
        if (indexPath.section == 0 && indexPath.row == 0) {
            cell.hidden = NO;
        }
        return cell;
    }
    cell.hidden = NO;
    return cell;
}

#pragma mark - Table view Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.section == 0 && indexPath.row == 0)) {
        if (_indexPath == nil) {
            if (self.displaySetting == YES) {
                [self.tableView selectRowAtIndexPath:self.startIndexPath
                                            animated:NO
                                      scrollPosition:UITableViewScrollPositionMiddle];
            }
            return;
        }
        [self.tableView selectRowAtIndexPath:_indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }

    if (indexPath.section == 1) {
        _indexPath = indexPath;
    }
}

#pragma mark - datePickerValueChanged
- (void)datePickerValueChanged:(UIDatePicker *)datePicker {
    if (_indexPath == nil) {
        _indexPath = self.startIndexPath;
    }
    [self.tableView selectRowAtIndexPath:_indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString *currentDateStr = [dateFormatter stringFromDate:datePicker.date];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_indexPath];
    cell.detailTextLabel.text = currentDateStr;
    UITableViewCell *startCell = [self.tableView cellForRowAtIndexPath:self.startIndexPath];
    UITableViewCell *endCell = [self.tableView cellForRowAtIndexPath:self.endIndexPath];
    NSDate *startTime = [dateFormatter dateFromString:startCell.detailTextLabel.text];
    NSDate *endTime = [dateFormatter dateFromString:endCell.detailTextLabel.text];
    if (startTime == nil || endTime == nil) {
        return;
    }
    //    NSDate *laterTime = [startTime laterDate:endTime];
    //    if ([laterTime isEqualToDate:startTime]) {
    //        startCell.detailTextLabel.text = @"00:00:00";
    //        [self.tableView selectRowAtIndexPath:startIndexPath animated:YES
    //        scrollPosition:UITableViewScrollPositionTop];
    //        [self tableView:self.tableView
    //        didSelectRowAtIndexPath:startIndexPath];
    //
    //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
    //        message:@"开始时间不能大于等于结束时间" delegate:nil
    //        cancelButtonTitle:RCDLocalizedString(@"confirm") otherButtonTitles:nil, nil];
    //        [alertView show];
    //        return;
    //    }
}

#pragma mark - setSwitchState
- (void)setSwitchState:(UISwitch *)swich {
    if (swich.on == YES) {
        self.displaySetting = YES;
    } else {
        self.displaySetting = NO;
    }
    [self.tableView reloadData];
    [self.tableView selectRowAtIndexPath:self.startIndexPath
                                animated:YES
                          scrollPosition:UITableViewScrollPositionMiddle];
    UITableViewCell *startCell = [self.tableView cellForRowAtIndexPath:self.startIndexPath];
    UITableViewCell *endCell = [self.tableView cellForRowAtIndexPath:self.endIndexPath];
    NSString *startTimeStr = startCell.detailTextLabel.text;
    NSString *endTimeStr = endCell.detailTextLabel.text;
    if (swich.on) {
        NSDateFormatter *formatterF = [[NSDateFormatter alloc] init];
        [formatterF setDateFormat:@"HH:mm:ss"];
        NSDate *startDate = [formatterF dateFromString:startTimeStr];
        NSDate *endDate = [formatterF dateFromString:endTimeStr];

        double timeDiff = [endDate timeIntervalSinceDate:startDate];
        NSDate *laterTime = [startDate laterDate:endDate];
        //开始时间大于结束时间，跨天设置
        if ([laterTime isEqualToDate:startDate]) {
            NSDate *dayEndTime = [formatterF dateFromString:@"23:59:59"];
            NSDate *dayBeginTime = [formatterF dateFromString:@"00:00:00"];
            double timeDiff1 = [dayEndTime timeIntervalSinceDate:startDate];
            double timeDiff2 = [endDate timeIntervalSinceDate:dayBeginTime];
            timeDiff = timeDiff1 + timeDiff2;
        }

        int timeDif = timeDiff / 60;

        __weak typeof(self) blockSelf = self;
        [[RCIMClient sharedRCIMClient] setNotificationQuietHours:startTimeStr
            spanMins:timeDif
            success:^{
            }
            error:^(RCErrorCode status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:RCDLocalizedString(@"alert")
                                                                    message:RCDLocalizedString(@"set_fail")
                                                                   delegate:nil
                                                          cancelButtonTitle:RCDLocalizedString(@"cancel")

                                                          otherButtonTitles:nil, nil];
                    [alert show];
                    blockSelf.swch.on = NO;
                });
            }];
    } else {
        __weak typeof(self) blockSelf = self;
        [[RCIMClient sharedRCIMClient] removeNotificationQuietHours:^{
        }
            error:^(RCErrorCode status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:RCDLocalizedString(@"alert")
                                                                    message:RCDLocalizedString(@"shut_down_failed")

                                                                   delegate:nil
                                                          cancelButtonTitle:RCDLocalizedString(@"cancel")

                                                          otherButtonTitles:nil, nil];
                    [alert show];
                    blockSelf.swch.on = YES;
                });
            }];
    }
}

@end
