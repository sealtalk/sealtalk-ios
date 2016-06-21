//
//  RCDAddFriendTableViewController.m
//  RCloudMessage
//
//  Created by Liv on 15/4/15.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDAddFriendTableViewController.h"
#import "AFHttpTool.h"
#import "UIImageView+WebCache.h"
#import "RCDHttpTool.h"
#import "RCDataBaseManager.h"

@interface RCDAddFriendTableViewController ()

@end

@implementation RCDAddFriendTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //设置默认隐藏
    [_lblAgreeTip setHidden:YES];
    _lblUserName.text = _userInfo.name;

    [_ivAva sd_setImageWithURL:[NSURL URLWithString:_userInfo.portraitUri] placeholderImage:[UIImage imageNamed:@"icon_person"]];
    //根据userId获取是否好友
//    [AFHttpTool requestFriend:self.userInfo.userId success:^(id response) {
//        if (response) {
//            _lblAgreeTip.hidden = NO;
//            _btnAgree.hidden = YES;
//            _btnDisagree.hidden = YES;
//            _btnChat.hidden = NO;
//        }
//    } failure:^(NSError *err) {
//        
//    }];
    
    [RCDHTTPTOOL isMyFriendWithUserInfo:_userInfo completion:^(BOOL isFriend) {
        if (isFriend) {
            _lblAgreeTip.hidden = NO;
            _btnAgree.hidden = YES;
            _btnDisagree.hidden = YES;

        }
    }];



    
}
- (IBAction)actionAgree:(id)sender {
    if (self.userInfo.userId==nil) {
        return;
    }
    __weak __typeof(self)weakSelf = self;
    [AFHttpTool processRequestFriend:weakSelf.userInfo.userId withIsAccess:YES success:^(id response) {
//[[RCDataBaseManager shareInstance]insertFriendToDB:weakSelf.userInfo];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"已添加好友！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];;
        
        [alertView show];
    } failure:^(NSError *err) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"添加失败！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];;
        [alertView show];
    }];

}
- (IBAction)actionDisagree:(id)sender {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"已拒绝对方好友申请！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];;
    [alertView show];
//    [AFHttpTool processRequestFriend:self.userInfo.userId withIsAccess:NO success:^(id response) {
//        
//    } failure:^(NSError *err) {
//        
//    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
