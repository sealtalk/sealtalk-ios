//
//  RCDChangePasswordViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/2/29.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDChangePasswordViewController.h"
#import "RCDCommonDefine.h"
#import "AFHttpTool.h"

@interface RCDChangePasswordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *oldPwd;
@property (weak, nonatomic) IBOutlet UITextField *newsPwd;
@property (weak, nonatomic) IBOutlet UITextField *confirmPwd;

@end

@implementation RCDChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 34)];
    [rightBtn setTitle:@"保存" forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(saveNewPassword:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    [rightBtn setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveNewPassword:(id)sender {
    __weak __typeof(&*self)weakSelf = self;
    NSString *userPwd = [DEFAULTS objectForKey:@"userPwd"];
    if ([userPwd isEqualToString:self.oldPwd.text]) {
//        if (self.newsPwd.text.length < 6) {
//            [self AlertShow:@"密码不能小于6位!"];
//            return;
//        }
        if (self.newsPwd.text.length > 20) {
            [self AlertShow:@"密码不能大于20位!"];
            return;
        }
        if (self.newsPwd.text.length == 0) {
            [self AlertShow:@"密码不能为空!"];
            return;
        }else{
            if ([self.newsPwd.text isEqualToString:self.confirmPwd.text]) {
                [AFHttpTool changePassword:self.oldPwd.text
                                    newPwd:self.newsPwd.text success:^(id response) {
                                        if ([response[@"code"] intValue] == 200) {
                                            [DEFAULTS setObject:self.newsPwd.text forKey:@"userPwd"];
                                            [DEFAULTS synchronize];
                                            [weakSelf.navigationController popViewControllerAnimated:YES];
                                        }
                                    } failure:^(NSError *err) {
                                        
                                    }];
                
            }else{
                [self AlertShow:@"确认密码填写有误"];
            }
            
        }
        
    }else{
        [self AlertShow:@"原密码填写有误"];
    }
}

-(void)AlertShow:(NSString *)content
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:content
                                                   delegate:self
                                          cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
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
