//
//  RCDEditGroupNameViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/3/28.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDEditGroupNameViewController.h"
#import "RCDHttpTool.h"
#import <RongIMKit/RongIMKit.h>

@interface RCDEditGroupNameViewController ()

@end

@implementation RCDEditGroupNameViewController
{
    UIButton *rightBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _GroupNameLabel.text = _Group.groupName;
    _GroupNameLabel.delegate = self;
    
    //自定义rightBarButtonItem
    rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 50, 30)];
    [rightBtn setTitle:@"完成" forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(clickDone:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    self.navigationItem.rightBarButtonItem = rightButton;
    rightBtn.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)clickDone:(id)sender
{
    NSString *nameStr = [_GroupNameLabel.text copy];
    nameStr = [nameStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //群组名称需要大于2位
    if ([nameStr length] == 0) {
        [self Alert:@"群组名称不能为空"];
        return;
    }
    //群组名称需要大于2个字
    if ([nameStr length] < 2) {
        [self Alert:@"群组名称过短"];
        return;
    }
    //群组名称需要小于10个字
    if ([nameStr length] > 10) {
        [self Alert:@"群组名称不能超过10个字"];
        return;
    }
//    //群组名称不能包含空格
//    NSRange range = [_GroupNameLabel.text rangeOfString:@" "];
//    if ([_GroupNameLabel.text length] <= 2) {
//        if (range.location != NSNotFound) {
//            [self Alert:@"群组名称过短"];
//            return;
//        }
//    }

    [RCDHTTPTOOL renameGroupWithGoupId:_Group.groupId
                             groupName:nameStr
                              complete:^(BOOL result) {
                                  if (result == YES) {
                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"renameGroupName" object:_GroupNameLabel.text];
                                      RCGroup *groupInfo = [RCGroup new];
                                      groupInfo.groupId = _Group.groupId;
                                      groupInfo.groupName = nameStr;
                                      groupInfo.portraitUri = _Group.portraitUri;
                                      [[RCIM sharedRCIM] refreshGroupInfoCache:groupInfo
                                                                   withGroupId:_Group.groupId];
                                      [self.navigationController popViewControllerAnimated:YES];
                                  }
                                  if (result == NO) {
                                      [self Alert:@"群组名称修改失败"];
                                  }
                              }];
    
}

-(void)Alert:(NSString *)alertContent
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:alertContent
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - UITextField Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    rightBtn.enabled = YES;
    return YES;
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
