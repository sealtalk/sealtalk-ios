//
//  RCDDebugViewController.m
//  RCloudMessage
//
//  Created by HuangJiaxin on 2017/8/24.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "RCDDebugViewController.h"
#import <RongIMLib/RongIMLib.h>

@interface RCDDebugViewController () <UIAlertViewDelegate>

@property(nonatomic, strong) UILabel *offLineMessageTimeLabel;
@property(nonatomic, strong) UITextField *setTimeTextField;
@property(nonatomic, strong) UIButton *confirmBtn;

@end

@implementation RCDDebugViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor lightGrayColor]];

    self.offLineMessageTimeLabel =
        [[UILabel alloc] initWithFrame:CGRectMake(50, 50, self.view.bounds.size.width - 100, 50)];
    self.offLineMessageTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.offLineMessageTimeLabel.textColor = [UIColor blackColor];
    [self.offLineMessageTimeLabel
        setText:[NSString stringWithFormat:@"%d 天", [[RCIMClient sharedRCIMClient] getOfflineMessageDuration]]];
    [self.view addSubview:self.offLineMessageTimeLabel];

    self.setTimeTextField =
        [[UITextField alloc] initWithFrame:CGRectMake(50, 150, self.view.bounds.size.width - 100, 50)];
    self.setTimeTextField.placeholder = @"离线消息补偿时间，范围【1~7天】";
    [self.setTimeTextField setFont:[UIFont systemFontOfSize:13]];
    self.setTimeTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.setTimeTextField];

    self.confirmBtn =
        [[UIButton alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 100) / 2, 250, 100, 50)];
    [self.confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    self.confirmBtn.backgroundColor = [UIColor blueColor];
    [self.confirmBtn addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.confirmBtn];
}

- (void)confirm {

    long time = [self.setTimeTextField.text integerValue];
    int time1 = (int)time;
    [[RCIMClient sharedRCIMClient] setOfflineMessageDuration:time1
        success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"设置成功"
                                                               delegate:self
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
                [alert show];
            });
        }
        failure:^(RCErrorCode nErrorCode) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"设置失败"
                                                               delegate:self
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
                [alert show];
            });
        }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
