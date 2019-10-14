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
@property(nonatomic, strong) UITextField *updateTimeTextField;
@property(nonatomic, strong) UIButton *confirmBtn;

@end

@implementation RCDDebugViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor lightGrayColor]];

    [self.view addSubview:self.offLineMessageTimeLabel];
    [self.view addSubview:self.updateTimeTextField];
    [self.view addSubview:self.confirmBtn];
}

- (void)confirm {
    long time = [self.updateTimeTextField.text integerValue];
    int time1 = (int)time;
    __weak typeof(self) ws = self;
    [[RCIMClient sharedRCIMClient] setOfflineMessageDuration:time1
        success:^{
            [ws showAlert:YES];
        }
        failure:^(RCErrorCode nErrorCode) {
            [ws showAlert:NO];
        }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showAlert:(BOOL)success {
    NSString *title = RCDLocalizedString(@"alert");
    NSString *content = RCDLocalizedString(@"setting_success");
    if(!success) {
        content = RCDLocalizedString(@"set_fail");
    }
    NSString *confirm = RCDLocalizedString(@"confirm");
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:content
                                                       delegate:self
                                              cancelButtonTitle:confirm
                                              otherButtonTitles:nil];
        [alert show];
    });
}

#pragma mark - getter
- (UILabel *)offLineMessageTimeLabel {
    if(!_offLineMessageTimeLabel) {
        _offLineMessageTimeLabel =
        [[UILabel alloc] initWithFrame:CGRectMake(50, 50, self.view.bounds.size.width - 100, 50)];
        _offLineMessageTimeLabel.textAlignment = NSTextAlignmentCenter;
        _offLineMessageTimeLabel.textColor = [UIColor blackColor];
        [_offLineMessageTimeLabel setText:[NSString stringWithFormat:RCDLocalizedString(@"xday")
                                               , [[RCIMClient sharedRCIMClient] getOfflineMessageDuration]]];
    }
    return _offLineMessageTimeLabel;
}

- (UITextField *)updateTimeTextField {
    if(!_updateTimeTextField) {
        _updateTimeTextField =
        [[UITextField alloc] initWithFrame:CGRectMake(50, 150, self.view.bounds.size.width - 100, 50)];
        _updateTimeTextField.placeholder =RCDLocalizedString(@"Set_offline_message_compensation_hint")
        ;
        [_updateTimeTextField setFont:[UIFont systemFontOfSize:13]];
        _updateTimeTextField.borderStyle = UITextBorderStyleRoundedRect;
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:_updateTimeTextField.placeholder attributes:
        @{NSForegroundColorAttributeName:HEXCOLOR(0x999999),
                     NSFontAttributeName:_updateTimeTextField.font
             }];
        _updateTimeTextField.attributedPlaceholder = attrString;
    }
    return _updateTimeTextField;
}

- (UIButton *)confirmBtn {
    if(!_confirmBtn) {
        _confirmBtn =
        [[UIButton alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 100) / 2, 250, 100, 50)];
        [_confirmBtn setTitle:RCDLocalizedString(@"confirm")
                         forState:UIControlStateNormal];
        _confirmBtn.backgroundColor = [UIColor blueColor];
        [_confirmBtn addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmBtn;
}
@end
