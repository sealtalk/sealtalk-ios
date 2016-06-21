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
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,copy) NSString *start;
@property (nonatomic,copy) NSString *end;
@end

@implementation RCDMessageNoDisturbSettingController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getNoDisturbStaus];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] animated:YES scrollPosition:UITableViewScrollPositionTop];
    _indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
}

- (void)getNoDisturbStaus{
    __weak typeof(self) weakSelf = self;
    [[RCIMClient sharedRCIMClient] getNotificationQuietHours:^(NSString *startTime, int spansMin) {
        NSDateFormatter *formatterE = [[NSDateFormatter alloc] init];
        [formatterE setDateFormat:@"HH:mm:ss"];
        NSDate *startDate = [formatterE dateFromString:startTime];
        NSDate *endDate = [startDate dateByAddingTimeInterval:60 * spansMin];
        NSString *endTime = [formatterE stringFromDate:endDate];
        if(spansMin > 0){
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *startIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
                NSIndexPath *endIndexPath = [NSIndexPath indexPathForRow:1 inSection:1];
                UITableViewCell *startCell = [self.tableView cellForRowAtIndexPath:startIndexPath];
                UITableViewCell *endCell = [self.tableView cellForRowAtIndexPath:endIndexPath];
                weakSelf.swch.on = YES;
                startCell.detailTextLabel.text = startTime;
                endCell.detailTextLabel.text = endTime;
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *startT = [UserDefaults objectForKey:@"startTime"];
                NSString *endT = [UserDefaults objectForKey:@"endTime"];
                NSIndexPath *startIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
                NSIndexPath *endIndexPath = [NSIndexPath indexPathForRow:1 inSection:1];
                UITableViewCell *startCell = [self.tableView cellForRowAtIndexPath:startIndexPath];
                UITableViewCell *endCell = [self.tableView cellForRowAtIndexPath:endIndexPath];
                if (startT && endT) {
                    startCell.detailTextLabel.text = startT;
                    endCell.detailTextLabel.text = endT;
                }else{
                    startCell.detailTextLabel.text = @"00:00:00";
                    endCell.detailTextLabel.text = @"23:59:59";
                }
                weakSelf.swch.on = NO;
            });
        }
    } error:^(RCErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *startT = [UserDefaults objectForKey:@"startTime"];
            NSString *endT = [UserDefaults objectForKey:@"endTime"];
            NSIndexPath *startIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
            NSIndexPath *endIndexPath = [NSIndexPath indexPathForRow:1 inSection:1];
            UITableViewCell *startCell = [self.tableView cellForRowAtIndexPath:startIndexPath];
            UITableViewCell *endCell = [self.tableView cellForRowAtIndexPath:endIndexPath];
            if (startT && endT) {
                startCell.detailTextLabel.text = startT;
                endCell.detailTextLabel.text = endT;
            }else{
                startCell.detailTextLabel.text = @"00:00:00";
                endCell.detailTextLabel.text = @"23:59:59";
            }
            weakSelf.swch.on = NO;
        });
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _swch = [[UISwitch alloc] init];
    self.title = @"免打扰设置";
    self.tableView.tableFooterView = [UIView new];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSIndexPath *startIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    NSIndexPath *endIndexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    UITableViewCell *startCell = [self.tableView cellForRowAtIndexPath:startIndexPath];
    UITableViewCell *endCell = [self.tableView cellForRowAtIndexPath:endIndexPath];
    NSString *startTime = startCell.detailTextLabel.text;
    NSString *endTime = endCell.detailTextLabel.text;
    if (_swch.on) {
        if (startTime.length == 0 || endTime.length == 0  || (startTime == _start && endTime == _end)) {
            return;
        }
        NSDateFormatter *formatterE = [[NSDateFormatter alloc] init];
        [formatterE setDateFormat:@"HH:mm:ss"];
        NSDate *startDate = [formatterE dateFromString:startTime];
        NSDate *endDate = [formatterE dateFromString:endTime];
        double timeDiff = [endDate timeIntervalSinceDate:startDate];
        NSDate *laterTime = [startDate laterDate:endDate];
        //开始时间大于结束时间，跨天设置
        if ([laterTime isEqualToDate:startDate]) {
            NSDate *dayEndTime = [formatterE dateFromString:@"23:59:59"];
            NSDate *dayBeginTime = [formatterE dateFromString:@"00:00:00"];
            double timeDiff1 = [dayEndTime timeIntervalSinceDate:startDate];
            double timeDiff2 = [endDate timeIntervalSinceDate:dayBeginTime];
            timeDiff = timeDiff1 + timeDiff2;
        }

        int timeDif = timeDiff/60;
        [[RCIMClient sharedRCIMClient] setNotificationQuietHours:startTime spanMins:timeDif success:^{
            [RCIM sharedRCIM].disableMessageNotificaiton = YES;
            [UserDefaults setObject:startTime forKey:@"startTime"];
            [UserDefaults setObject:endTime forKey:@"endTime"];
        } error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"设置失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
                [alert show];
            });
        } ];
        }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0)
        return 1;
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 200;
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCellReuseIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MyCellReuseIdentifier"];
    }
    if (indexPath.section == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIDatePicker *datePicker = [[UIDatePicker alloc] init];
        datePicker.datePickerMode = UIDatePickerModeCountDownTimer;
        [datePicker setDate:[NSDate date]];
        [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:datePicker];
    }else{
        switch (indexPath.row) {
            case 0:
            {
                cell.textLabel.text = @"开始时间";
            }
                break;
            case 1:
            {
                cell.textLabel.text = @"结束时间";
            }
                break;
            default:
            {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.text = @"屏蔽所有消息";
                [_swch setFrame:CGRectMake(self.view.frame.size.width - _swch.frame.size.width -15, 6, 0, 0)];
                [_swch addTarget:self action:@selector(setSwitchState:) forControlEvents:UIControlEventValueChanged];
                [cell.contentView addSubview:_swch];
            }
                break;
        }
    }
    return cell;
}

#pragma mark - Table view Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if((indexPath.section == 1 && indexPath.row == 0) || (indexPath.section == 1 && indexPath.row == 1)){
        _indexPath = indexPath;
    }
}

#pragma mark - datePickerValueChanged
-(void) datePickerValueChanged:(UIDatePicker *) datePicker{
    [self.tableView selectRowAtIndexPath:_indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString *currentDateStr = [dateFormatter stringFromDate:datePicker.date];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_indexPath];
    cell.detailTextLabel.text = currentDateStr;
    NSIndexPath *startIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    NSIndexPath *endIndexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    UITableViewCell *startCell = [self.tableView cellForRowAtIndexPath:startIndexPath];
    UITableViewCell *endCell = [self.tableView cellForRowAtIndexPath:endIndexPath];
    NSDate *startTime = [dateFormatter dateFromString:startCell.detailTextLabel.text];
    NSDate *endTime = [dateFormatter dateFromString:endCell.detailTextLabel.text];
    if (startTime == nil || endTime == nil) {
        return;
    }
//    NSDate *laterTime = [startTime laterDate:endTime];
//    if ([laterTime isEqualToDate:startTime]) {
//        startCell.detailTextLabel.text = @"00:00:00";
//        [self.tableView selectRowAtIndexPath:startIndexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
//        [self tableView:self.tableView didSelectRowAtIndexPath:startIndexPath];
//        
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"开始时间不能大于等于结束时间" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alertView show];
//        return;
//    }
}

#pragma mark - setSwitchState
- (void)setSwitchState:(UISwitch *) swich{
        NSIndexPath *startIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        NSIndexPath *endIndexPath = [NSIndexPath indexPathForRow:1 inSection:1];
        UITableViewCell *startCell = [self.tableView cellForRowAtIndexPath:startIndexPath];
        UITableViewCell *endCell = [self.tableView cellForRowAtIndexPath:endIndexPath];
        NSString *startTimeStr = startCell.detailTextLabel.text;
        NSString *endTimeStr = endCell.detailTextLabel.text;
    if (swich.on){
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
        
        int timeDif = timeDiff/60;
        
        
        
        __weak typeof(&*self) blockSelf = self;
        [[RCIMClient sharedRCIMClient] setNotificationQuietHours:startTimeStr spanMins:timeDif success:^{
            [RCIM sharedRCIM].disableMessageNotificaiton = YES;
        } error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"设置失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
                [alert show];
                blockSelf.swch.on = NO;
            });
        }];
    }else{
        __weak typeof(&*self) blockSelf = self;
        [[RCIMClient sharedRCIMClient] removeNotificationQuietHours:^{
            [RCIM sharedRCIM].disableMessageNotificaiton = NO;
        } error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"关闭失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
                [alert show];
                blockSelf.swch.on = YES;
            });
        }];
    }
}



@end

