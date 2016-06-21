//
//  RCDPublicServiceListViewController.m
//  RCloudMessage
//
//  Created by 张改红 on 16/4/13.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDPublicServiceListViewController.h"
#import "RCDChatViewController.h"
@interface RCDPublicServiceListViewController ()

@end

@implementation RCDPublicServiceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *key = [self.allKeys objectAtIndex:indexPath.section];
    NSArray *arrayForKey = [self.allFriends objectForKey:key];
    RCPublicServiceProfile *PublicServiceProfile = arrayForKey[indexPath.row];
    RCDChatViewController *_conversationVC = [[RCDChatViewController alloc] init];
    _conversationVC.conversationType = (RCConversationType)PublicServiceProfile.publicServiceType;
    _conversationVC.targetId = PublicServiceProfile.publicServiceId;
    //接口向后兼容 --]]
    _conversationVC.title = PublicServiceProfile.name;
    [self.navigationController pushViewController:_conversationVC animated:YES];
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
