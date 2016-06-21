//
//  RCDSettingsTableViewController.m
//  RCloudMessage
//
//  Created by Liv on 14/11/20.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCDSettingsTableViewController.h"
#import "RCDLoginViewController.h"
#import <RongIMLib/RongIMLib.h>
#import "DBHelper.h"

@interface RCDSettingsTableViewController ()<UIAlertViewDelegate>

@end

@implementation RCDSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //self.automaticallyAdjustsScrollViewInsets = false;
    self.tableView.contentInset=UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.tableFooterView=[UIView new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (1 == indexPath.section && 0 == indexPath.row) {
        //清除缓存
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"是否清理缓存？"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定", nil];
        alertView.tag = 1011;
        [alertView show];
    }else if (2 == indexPath.section && 0 == indexPath.row)
    {
        //退出登陆
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"是否退出登录？"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定", nil];
        alertView.tag = 1010;
        [alertView show];
    }
}

#pragma mark - UIAlertView Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && alertView.tag == 1010) {
        [self logout];
    }
    
    if (buttonIndex == 1 && alertView.tag == 1011) {
        [self clearCache];

    }
}

//清理缓存
-(void) clearCache
{
    dispatch_async(
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                   , ^{
                       
                       NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                       NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];

                       for (NSString *p in files) {
                           NSError *error;
                           NSString *path = [cachPath stringByAppendingPathComponent:p];
                           if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                               [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                           }
                       }
                       [self performSelectorOnMainThread:@selector(clearCacheSuccess)
                                              withObject:nil waitUntilDone:YES];});
}

-(void)clearCacheSuccess
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"缓存清理成功！"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}


//退出登陆
-(void)logout
{
#define DEFAULTS [NSUserDefaults standardUserDefaults]
//    [DEFAULTS removeObjectForKey:@"userName"];
//    [DEFAULTS removeObjectForKey:@"userPwd"];
    [DEFAULTS removeObjectForKey:@"userToken"];
    [DEFAULTS removeObjectForKey:@"userCookie"];
    [DEFAULTS removeObjectForKey:@"isLogin"];
    [DEFAULTS synchronize];
    
    [DBHelper closeDataBase];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RCDLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"loginVC"];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:loginVC];
    self.view.window.rootViewController = navi;
    [[RCIMClient sharedRCIMClient]logout];
    //[[RCIMClient sharedRCIMClient]disconnect:NO];
}

@end
