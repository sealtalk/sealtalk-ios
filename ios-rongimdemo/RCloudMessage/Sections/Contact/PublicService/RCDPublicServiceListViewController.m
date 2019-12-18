//
//  RCDPublicServiceListViewController.m
//  RCloudMessage
//
//  Created by 张改红 on 16/4/13.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDPublicServiceListViewController.h"
#import "RCDChatViewController.h"
#import "RCDForwardManager.h"

@implementation RCDPublicServiceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupNavi];

    if ([self.tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
}

- (void)setupNavi {
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 17, 17)];
    [rightBtn setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(pushAddPublicService:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightButton;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *key = [self.allKeys objectAtIndex:indexPath.section];
    NSArray *arrayForKey = [self.allFriends objectForKey:key];
    RCPublicServiceProfile *PublicServiceProfile = arrayForKey[indexPath.row];
    if ([RCDForwardManager sharedInstance].isForward) {
        RCConversation *conver = [[RCConversation alloc] init];
        conver.targetId = PublicServiceProfile.publicServiceId;
        conver.conversationType = (RCConversationType)PublicServiceProfile.publicServiceType;
        [RCDForwardManager sharedInstance].toConversation = conver;
        [[RCDForwardManager sharedInstance] showForwardAlertViewInViewController:self];
    } else {
        RCDChatViewController *chatVC = [[RCDChatViewController alloc] init];
        chatVC.conversationType = (RCConversationType)PublicServiceProfile.publicServiceType;
        chatVC.targetId = PublicServiceProfile.publicServiceId;
        //接口向后兼容 --]]
        chatVC.title = PublicServiceProfile.name;
        [self.navigationController pushViewController:chatVC animated:YES];
    }
}

/**
 *  添加公众号
 *
 *  @param sender sender description
 */
- (void)pushAddPublicService:(id)sender {
    RCPublicServiceSearchViewController *searchPublicServiceVC = [[RCPublicServiceSearchViewController alloc] init];
    [self.navigationController pushViewController:searchPublicServiceVC animated:YES];
}

@end
