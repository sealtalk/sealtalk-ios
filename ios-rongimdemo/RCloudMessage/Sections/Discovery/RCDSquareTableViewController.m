//
//  RCDSquareTableViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/4/1.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDSquareTableViewController.h"
#import "RCDBaseSettingTableViewCell.h"
#import "RCDChatViewController.h"
#import "RCDSquareCell.h"
#import "RCDCommonString.h"
#import "RCDChatRoomManager.h"
@interface RCDSquareTableViewController ()
@property (nonatomic, strong) NSArray *chatRoomList;
@end

@implementation RCDSquareTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self getDefaultChatRoomInfo];

    [self reloadTableViewIfNeed];

    [self fetchRemoteChatRoomListAndRefresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.navigationItem.title = RCDLocalizedString(@"discover");
    self.tabBarController.navigationItem.rightBarButtonItems = nil;
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDChatRoom *room = self.chatRoomList[indexPath.row];
    RCDChatViewController *chatVC =
        [[RCDChatViewController alloc] initWithConversationType:ConversationType_CHATROOM targetId:room.targetId];
    chatVC.title = room.name;
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.chatRoomList.count == 0) {
        return 0;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chatRoomList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.chatRoomList.count == 0 || self.chatRoomList == nil) {
        return [UITableViewCell new];
    }
    NSArray *chatroomIcons =
        [[NSArray alloc] initWithObjects:@"chatroom_1", @"chatroom_2", @"chatroom_3", @"chatroom_4", nil];

    static NSString *reusableCellWithIdentifier = @"RCDSquareCell";
    RCDSquareCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    RCDChatRoom *room = self.chatRoomList[indexPath.row];
    if (cell == nil) {
        cell = [[RCDSquareCell alloc]
            initWithIconName:[NSString stringWithFormat:@"%@", chatroomIcons[indexPath.row % chatroomIcons.count]]
                   TitleName:room.name];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64.5;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *sectionHeaderView =
        [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 44)];
    sectionHeaderView.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
    UIView *line =
        [[UIView alloc] initWithFrame:CGRectMake(0, 44 - 0.5, [[UIScreen mainScreen] bounds].size.width, 0.5)];
    line.backgroundColor = RCDDYCOLOR(0xdfdfdf, 0x000000);
    [sectionHeaderView addSubview:line];

    UILabel *Title = [[UILabel alloc] initWithFrame:CGRectMake(9, (44 - 20) / 2.0, 200, 20)];
    [Title setTextColor:RCDDYCOLOR(0x000000, 0xA7a7a7)];
    [Title setFont:[UIFont systemFontOfSize:16.f]];

    [sectionHeaderView addSubview:Title];
    switch (section) {
    case 0:
        Title.text = RCDLocalizedString(@"chatroom");
        break;
    default:
        break;
    }
    return sectionHeaderView;
}

#pragma mark - private method
- (void)getDefaultChatRoomInfo {
    NSMutableArray *squareInfoList = [DEFAULTS mutableArrayValueForKey:RCDSquareInfoListKey];
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *info in squareInfoList) {
        RCDChatRoom *room = [RCDChatRoom new];
        room.targetId = info[@"id"];
        room.name = info[@"name"];
        [array addObject:room];
    }
    self.chatRoomList = array.copy;
}

- (void)reloadTableViewIfNeed {
    if (self.chatRoomList.count > 0) {
        [self.tableView reloadData];
    }
}

- (void)fetchRemoteChatRoomListAndRefresh {

    RCNetworkStatus status = [[RCIMClient sharedRCIMClient] getCurrentNetworkStatus];
    if (RC_NotReachable == status) {
        return;
    }
    [RCDChatRoomManager getChatRoomList:^(NSArray<RCDChatRoom *> *_Nonnull rooms) {
        if (rooms) {
            rcd_dispatch_main_async_safe(^{
                self.chatRoomList = rooms;
                [self reloadTableViewIfNeed];
            });
            [self saveChatRoomList:rooms];
        }
    }];
}

- (void)saveChatRoomList:(NSArray *)result {
    if (result.count > 0) {
        NSMutableArray *array = [NSMutableArray array];
        for (RCDChatRoom *room in result) {
            NSDictionary *dic = @{ @"id" : room.targetId, @"name" : room.name };
            [array addObject:dic];
        }
        //保存默认聊天室信息
        [DEFAULTS setObject:array forKey:RCDSquareInfoListKey];
        [DEFAULTS synchronize];
    }
}

@end
