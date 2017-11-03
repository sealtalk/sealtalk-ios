//
//  RCDSquareTableViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/4/1.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDSquareTableViewController.h"
#import "DefaultPortraitView.h"
#import "RCDBaseSettingTableViewCell.h"
#import "RCDChatViewController.h"
#import "RCDCommonDefine.h"
#import "RCDGroupInfo.h"
#import "RCDHttpTool.h"
#import "RCDSquareCell.h"
#import "RCDataBaseManager.h"
#import "UIColor+RCColor.h"

@interface RCDSquareTableViewController ()

@end

@implementation RCDSquareTableViewController {
    NSMutableArray *chatRoomIdList;
    NSMutableArray *chatRoomNames;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.translucent = NO;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    chatRoomNames = [NSMutableArray new];
    chatRoomIdList = [NSMutableArray new];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *squareInfoList = [userDefaults mutableArrayValueForKey:@"SquareInfoList"];
    for (NSDictionary *info in squareInfoList) {
        NSString *type = info[@"type"];
        if ([type isEqualToString:@"chatroom"]) {
            [chatRoomIdList addObject:info[@"id"]];
            [chatRoomNames addObject:info[@"name"]];
        }
    }
    if (chatRoomIdList.count > 0) {
        [self.tableView reloadData];
    }
    [RCDHTTPTOOL getSquareInfoCompletion:^(NSMutableArray *result) {
        NSMutableArray *tempChatRoomIdList = [NSMutableArray new];
        NSMutableArray *tempChatRoomNames = [NSMutableArray new];
        for (NSDictionary *info in result) {
            NSString *type = info[@"type"];
            if ([type isEqualToString:@"chatroom"]) {
                [tempChatRoomIdList addObject:info[@"id"]];
                [tempChatRoomNames addObject:info[@"name"]];
            }
            if (tempChatRoomIdList.count > 0 && tempChatRoomNames.count > 0) {
                chatRoomIdList = tempChatRoomIdList;
                chatRoomNames = tempChatRoomNames;
                [self.tableView reloadData];
            }
        }
        //保存默认聊天室id
        [DEFAULTS setObject:chatRoomIdList forKey:@"defaultChatRoomIdList"];
        [DEFAULTS synchronize];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.navigationItem.title = @"发现";
    self.tabBarController.navigationItem.rightBarButtonItems = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (chatRoomNames.count == 0) {
        return 0;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows;
    if (chatRoomNames.count == 0) {
        rows = 0;
    } else {
        switch (section) {
        case 0:
            rows = chatRoomNames.count;
            break;

        default:
            break;
        }
    }

    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (chatRoomNames.count == 0 || chatRoomNames == nil) {
        return nil;
    }
    NSArray *chatroomIcons = [[NSArray alloc] initWithObjects:@"icon_1-1", @"icon_2-1", @"icon_3-1", @"icon_4-1", nil];

    static NSString *reusableCellWithIdentifier = @"RCDSquareCell";
    RCDSquareCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];

    if (cell == nil) {
        cell = [[RCDSquareCell alloc] initWithIconName:[NSString stringWithFormat:@"%@", chatroomIcons[indexPath.row]]
                                             TitleName:chatRoomNames[indexPath.row]];
    }
    return cell;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *sectionHeaderView =
        [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 35.5)];
    sectionHeaderView.backgroundColor = HEXCOLOR(0xf0f0f6);
    UIView *line =
        [[UIView alloc] initWithFrame:CGRectMake(0, 35.5 - 0.5, [[UIScreen mainScreen] bounds].size.width, 0.5)];
    line.backgroundColor = HEXCOLOR(0xdfdfdf);
    [sectionHeaderView addSubview:line];

    UILabel *Title = [[UILabel alloc] initWithFrame:CGRectMake(9, (35.5 - 20) / 2.0, 200, 20)];
    [Title setTextColor:HEXCOLOR(0x000000)];
    [Title setFont:[UIFont systemFontOfSize:16.f]];

    [sectionHeaderView addSubview:Title];
    switch (section) {
    case 0:
        Title.text = @"聊天室";
        break;
    default:
        break;
    }
    return sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height;
    switch (indexPath.section) {
    case 0:
        height = 68.5;
        break;

    default:
        break;
    }

    return height;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *chatroomId;
    chatroomId = chatRoomIdList[indexPath.row];
    RCDChatViewController *chatVC =
        [[RCDChatViewController alloc] initWithConversationType:ConversationType_CHATROOM targetId:chatroomId];
    chatVC.title = chatRoomNames[indexPath.row];
    [self.navigationController pushViewController:chatVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - 本类私有方法

- (void)gotoChatRoomConversation:(UITapGestureRecognizer *)recognizer {
    NSArray *chatRoomNameArr = [[NSArray alloc] initWithObjects:@"聊天室1", @"聊天室2", @"聊天室3", @"聊天室4", nil];
    if (chatRoomIdList.count == 0) {
        return;
    }
    NSString *chatroomId;
    NSInteger tag = recognizer.view.tag;
    chatroomId = chatRoomIdList[tag - 10];
    RCDChatViewController *chatVC =
        [[RCDChatViewController alloc] initWithConversationType:ConversationType_CHATROOM targetId:chatroomId];
    chatVC.title = chatRoomNameArr[tag - 10];
    [self.navigationController pushViewController:chatVC animated:YES];
}

@end
