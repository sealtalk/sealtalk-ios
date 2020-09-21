//
//  RCDDebugSelectChatController.m
//  SealTalk
//
//  Created by 张改红 on 2020/8/5.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCDDebugSelectChatController.h"
#import "RCDTableView.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDGroupManager.h"
#import "RCDUserInfoManager.h"
#import "RCDDebugMessageExtensionLogController.h"
@interface RCDDebugSelectChatController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, assign) RCConversationType conversationType;
@property (nonatomic, strong) NSArray *chatList;
@property (nonatomic, strong) RCDTableView *tableView;
@end

@implementation RCDDebugSelectChatController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    self.chatList = [[RCIMClient sharedRCIMClient] getConversationList:@[@(ConversationType_PRIVATE),@(ConversationType_GROUP)]];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.chatList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //    根据indexPath准确地取出一行，而不是从cell重用队列中取出
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //    如果如果没有多余单元，则需要创建新的单元
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    }
    RCConversation *con = self.chatList[indexPath.row];
    if (con.conversationType == ConversationType_GROUP) {
        RCDGroupInfo *group = [RCDGroupManager getGroupInfo:con.targetId];
        cell.textLabel.text = [NSString stringWithFormat:@"[Group] %@(%@)",group.groupName,con.targetId];
    }else if (con.conversationType == ConversationType_PRIVATE){
        RCDUserInfo *friend = [RCDUserInfoManager getUserInfo:con.targetId];
        cell.textLabel.text = [NSString stringWithFormat:@"[Privite]%@(%@)",friend.name,con.targetId];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RCDDebugMessageExtensionLogController *vc = [[RCDDebugMessageExtensionLogController alloc] init];
    RCConversation *con = self.chatList[indexPath.row];
    vc.targetId = con.targetId;
    vc.conversationType = con.conversationType;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - getter
- (RCDTableView *)tableView {
    if (!_tableView) {
        _tableView = [[RCDTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}
@end
