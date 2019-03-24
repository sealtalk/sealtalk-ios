//
//  RCDDebugNoDisturbViewController.m
//  SealTalk
//
//  Created by LanFudong on 2017/10/27.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "RCDDebugNoDisturbViewController.h"
#import <RongIMKit/RongIMKit.h>

@interface RCDDebugNoDisturbViewController ()

@property (nonatomic, strong) UITextField *startTimeTextField;
@property (nonatomic, strong) UITextField *durationTimeTextField;

@end

@implementation RCDDebugNoDisturbViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    
    UILabel *startTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 130, 44)];
    startTimeLabel.text = RCDLocalizedString(@"Start_time1");
    [self.view addSubview:startTimeLabel];
    
    self.startTimeTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(startTimeLabel.frame), 100, 160, 44)];
    [self.startTimeTextField setBackgroundColor:[UIColor whiteColor]];
    [self.startTimeTextField setPlaceholder:@"HH:mm:ss"];
    [self.view addSubview:self.startTimeTextField];
    
    UILabel *endTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.startTimeTextField.frame)+20, 130, 44)];
    endTimeLabel.text = RCDLocalizedString(@"continue_times")
;
    [self.view addSubview:endTimeLabel];
    
    self.durationTimeTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(endTimeLabel.frame), endTimeLabel.frame.origin.y, 160, 44)];
    [self.durationTimeTextField setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.durationTimeTextField];
    
    UIButton *confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(self.durationTimeTextField.frame)+40, self.view.bounds.size.width-100, 44)];
    [confirmButton setTitle:RCDLocalizedString(@"confirm")
 forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(confirmButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [confirmButton setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:confirmButton];
    
    [[RCIMClient sharedRCIMClient] getNotificationQuietHours:^(NSString *startTime, int spansMin) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.startTimeTextField.text = startTime;
            self.durationTimeTextField.text = [NSString stringWithFormat:@"%ld", (long)spansMin];
        });
    } error:nil];
}

- (void)confirmButtonAction:(UIButton *)button {
    NSString *startTime = self.startTimeTextField.text;
    int spanMins = [self.durationTimeTextField.text intValue];
    
    [[RCIMClient sharedRCIMClient] setNotificationQuietHours:startTime spanMins:spanMins success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:RCDLocalizedString(@"setting_success") message:nil delegate:nil cancelButtonTitle:RCDLocalizedString(@"confirm")
 otherButtonTitles:nil, nil];
            [alert show];
        });
    } error:^(RCErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:RCDLocalizedString(@"set_fail") message:nil delegate:nil cancelButtonTitle:RCDLocalizedString(@"confirm")
 otherButtonTitles:nil, nil];
            [alert show];
        });
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.startTimeTextField resignFirstResponder];
    [self.durationTimeTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
