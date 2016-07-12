//
//  RCDMessageNotifyTableViewController.m
//  RCloudMessage
//
//  Created by Liv on 14/11/20.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCDMessageNotifySettingTableViewController.h"
#import "MBProgressHUD.h"
#import "RCDMessageNoDisturbSettingController.h"
#import <RongIMKit/RongIMKit.h>
#import "UIColor+RCColor.h"
@interface RCDMessageNotifySettingTableViewController ()
@property(weak, nonatomic) IBOutlet UISwitch *notifySwitch;

@property(weak, nonatomic) IBOutlet UILabel *noDisturbLabel;

@end

@implementation RCDMessageNotifySettingTableViewController
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  UITableViewCell *cell = [self.tableView
      cellForRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  [[RCIMClient sharedRCIMClient]
      getNotificationQuietHours:^(NSString *startTime, int spansMin) {
        dispatch_async(dispatch_get_main_queue(), ^{
          if (spansMin >= 1439) {
            self.notifySwitch.on = NO;
            cell.backgroundColor =
                [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
            _noDisturbLabel.alpha = 0.5;
          } else {
            self.notifySwitch.on = YES;
            cell.backgroundColor = [UIColor whiteColor];
            _noDisturbLabel.alpha = 1;
          }
        });
      }
      error:^(RCErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
          self.notifySwitch.on = YES;
        });
      }];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  //通知开启状态
  //    UIUserNotificationType userNotiType = [[UIApplication sharedApplication]
  //    currentUserNotificationSettings].types;
  //    if (userNotiType != UIUserNotificationTypeNone) {
  //        [self.notifySwitch setEnabled:YES];
  //    }else{
  //        [self.notifySwitch setEnabled:NO];
  //    }
  self.navigationItem.title = @"新消息通知";
    //设置分割线颜色
    self.tableView.separatorColor =
    [UIColor colorWithHexString:@"dfdfdf" alpha:1.0f];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 0)];
    }
}

- (IBAction)onSwitch:(id)sender {
  UITableViewCell *cell = [self.tableView
      cellForRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  hud.labelText = @"设置中...";
  if (!self.notifySwitch.on) {
    [[RCIMClient sharedRCIMClient] setNotificationQuietHours:@"00:00:00"
        spanMins:1439
        success:^{
          NSLog(@"setNotificationQuietHours succeed");

          dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
            cell.backgroundColor =
                [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
            _noDisturbLabel.alpha = 0.5;
          });
        }
        error:^(RCErrorCode status) {
          dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert =
                [[UIAlertView alloc] initWithTitle:@"提示"
                                           message:@"设置失败"
                                          delegate:nil
                                 cancelButtonTitle:@"取消"
                                 otherButtonTitles:nil, nil];
            [alert show];
            self.notifySwitch.on = YES;
            [hud hide:YES];
          });
        }];
  } else {
    [[RCIMClient sharedRCIMClient] removeNotificationQuietHours:^{
      dispatch_async(dispatch_get_main_queue(), ^{
        [hud hide:YES];
        cell.backgroundColor = [UIColor whiteColor];
        _noDisturbLabel.alpha = 1;
      });
    }
        error:^(RCErrorCode status) {

          dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert =
                [[UIAlertView alloc] initWithTitle:@"提示"
                                           message:@"取消失败"
                                          delegate:nil
                                 cancelButtonTitle:@"取消"
                                 otherButtonTitles:nil, nil];
            [alert show];
            self.notifySwitch.on = NO;
            [hud hide:YES];
          });
        }];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Table view Delegate
- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  if (indexPath.row == 1 && indexPath.section == 0) {

    if (_notifySwitch.on) {
      RCDMessageNoDisturbSettingController *noMessage =
          [[RCDMessageNoDisturbSettingController alloc] init];
      [self.navigationController pushViewController:noMessage animated:YES];
    }
  }
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    return 15.f;
  }
  return 5.f;
}

@end
