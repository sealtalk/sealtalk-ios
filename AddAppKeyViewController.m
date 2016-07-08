//
//  AddAppKeyViewController.m
//  RCloudMessage
//
//  Created by litao on 15/5/28.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

//本文件为了切换appkey测试用的，请应用开发者忽略关于本文件的信息。
#import "AddAppKeyViewController.h"

@interface AddAppKeyViewController ()
@property(nonatomic, strong) UITextField *keyField;
@property(nonatomic, strong) UITextField *devField;
@end

@implementation AddAppKeyViewController
- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationItem.rightBarButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(onSave:)];

  self.keyField =
      [[UITextField alloc] initWithFrame:CGRectMake(5, 80, 220, 40)];
  self.devField =
      [[UITextField alloc] initWithFrame:CGRectMake(5, 140, 220, 40)];

  [self.keyField setBorderStyle:UITextBorderStyleRoundedRect];
  [self.devField setBorderStyle:UITextBorderStyleRoundedRect];

  self.keyField.placeholder = @"appkey";
  self.devField.placeholder = @"dev";

  [self.view addSubview:self.keyField];
  [self.view addSubview:self.devField];
  [self.view setBackgroundColor:[UIColor whiteColor]];
}
- (void)onSave:(id)sender {
  NSString *appKey = self.keyField.text;
  int env = [self.devField.text intValue];
  if (env != 1 && env != 2) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                    message:@"dev值必须是1或者2"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:nil, nil];
    [alert show];
    return;
  }
  AppkeyModel *model = [[AppkeyModel alloc] initWithKey:appKey env:env];
  self.result(model);
  [self.navigationController popViewControllerAnimated:YES];
}

@end
