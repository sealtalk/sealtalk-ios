//
//  RCDPublicServiceListViewController.m
//  RCloudMessage
//
//  Created by 张改红 on 16/4/13.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDPublicServiceListViewController.h"
#import "RCDChatViewController.h"
#import "RCDForwardAlertView.h"
@interface RCDPublicServiceListViewController ()

@end

@implementation RCDPublicServiceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //自定义rightBarButtonItem
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 17, 17)];
    [rightBtn setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(pushAddPublicService:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    [rightBtn setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
}

- (void)viewDidLayoutSubviews {
    self.tableView.frame = self.view.frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *key = [self.allKeys objectAtIndex:indexPath.section];
    NSArray *arrayForKey = [self.allFriends objectForKey:key];
    RCPublicServiceProfile *PublicServiceProfile = arrayForKey[indexPath.row];
    if ([RCDForwardMananer shareInstance].isForward) {
        RCConversation *conver = [[RCConversation alloc] init];
        conver.targetId = PublicServiceProfile.publicServiceId;
        conver.conversationType = (RCConversationType)PublicServiceProfile.publicServiceType;
        [RCDForwardMananer shareInstance].toConversation = conver;
        [[RCDForwardMananer shareInstance] showForwardAlertViewInViewController:self];
        return;
    }
    RCDChatViewController *_conversationVC = [[RCDChatViewController alloc] init];
    _conversationVC.conversationType = (RCConversationType)PublicServiceProfile.publicServiceType;
    _conversationVC.targetId = PublicServiceProfile.publicServiceId;
    //接口向后兼容 --]]
    _conversationVC.title = PublicServiceProfile.name;
    [self.navigationController pushViewController:_conversationVC animated:YES];
}

/**
 *  添加公众号
 *
 *  @param sender sender description
 */
- (void)pushAddPublicService:(id)sender {
    RCPublicServiceSearchViewController *searchFirendVC = [[RCPublicServiceSearchViewController alloc] init];
    [self.navigationController pushViewController:searchFirendVC animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
