//
//  ChatRoomViewController.m
//  RongCloud
//
//  Created by Liv on 14/10/31.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCDChatRoomViewController.h"
#import "RCDChatRoomInfo.h"
#import "RCDChatRoomTableViewCell.h"
#import "RCDChatViewController.h"
#import "UIColor+RCColor.h"
#import <RongIMKit/RongIMKit.h>

@interface RCDChatRoomViewController ()
@property(nonatomic, strong) NSMutableArray *chatRoomList;
@end

@implementation RCDChatRoomViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    //设置为不用默认渲染方式
    self.tabBarItem.image = [[UIImage imageNamed:@"icon_room"]
        imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.tabBarItem.selectedImage = [[UIImage imageNamed:@"icon_room_hover"]
        imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.

  //设置tableView样式
  self.tableView.separatorColor =
      [UIColor colorWithHexString:@"dfdfdf" alpha:1.0f];
  self.tableView.tableFooterView = [UIView new];
  // self.tableView.tableHeaderView = [[UIView alloc]
  // initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,
  // 12)];

  _chatRoomList = [[NSMutableArray alloc] init];
  RCDChatRoomInfo *chatRoom1 = [[RCDChatRoomInfo alloc] init];
  chatRoom1.chatRoomId = @"chatroom001";
  chatRoom1.introduce = @"多年专注于移动互联网即时通";
  chatRoom1.chatRoomName = @"Chatroom A";
  chatRoom1.category = @"# 在线服务 #";
  chatRoom1.maxNumber = @"500";
  chatRoom1.portrait = @"icon_1";
  [_chatRoomList addObject:chatRoom1];

  RCDChatRoomInfo *chatRoom2 = [[RCDChatRoomInfo alloc] init];
  chatRoom2.chatRoomId = @"chatroom002";
  chatRoom2.introduce = @"单聊群聊多种使用场景";
  chatRoom2.chatRoomName = @"Chatroom B";
  chatRoom2.category = @"# 云服务 #";
  chatRoom2.maxNumber = @"500";
  chatRoom2.portrait = @"icon_2";
  [_chatRoomList addObject:chatRoom2];

  RCDChatRoomInfo *chatRoom3 = [[RCDChatRoomInfo alloc] init];
  chatRoom3.chatRoomId = @"chatroom003";
  chatRoom3.introduce = @"提供文字表情防语音片段等...";
  chatRoom3.chatRoomName = @"Chatroom C";
  chatRoom3.category = @"# 设计 #";
  chatRoom3.maxNumber = @"500";
  chatRoom3.portrait = @"icon_3";
  [_chatRoomList addObject:chatRoom3];

  //    RCDChatRoomInfo *chatRoom4=[[RCDChatRoomInfo alloc]init];
  //    chatRoom4.chatRoomId=@"chatroom004";
  //    chatRoom4.introduce=@"各类时尚资讯";
  //    chatRoom4.chatRoomName=@"DaveDing";
  //    chatRoom4.category=@"# 时尚 #";
  //    chatRoom4.maxNumber=@"500";
  //    chatRoom4.portrait=@"icon_3";
  //    [_chatRoomList addObject:chatRoom4];
  //
  //    RCDChatRoomInfo *chatRoom5=[[RCDChatRoomInfo alloc]init];
  //    chatRoom5.chatRoomId=@"chatroom005";
  //    chatRoom5.introduce=@"多年专注于移动互联网即时通";
  //    chatRoom5.chatRoomName=@"lovry";
  //    chatRoom5.category=@"# 文艺 #";
  //    chatRoom5.maxNumber=@"500";
  //    chatRoom5.portrait=@"icon_3";
  //    [_chatRoomList addObject:chatRoom5];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  UILabel *titleView = [[UILabel alloc]
      initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
  titleView.backgroundColor = [UIColor clearColor];
  titleView.font = [UIFont boldSystemFontOfSize:19];
  titleView.textColor = [UIColor whiteColor];
  titleView.textAlignment = NSTextAlignmentCenter;
  titleView.text = @"聊天室";
  self.tabBarController.navigationItem.titleView = titleView;
  // self.tabBarController.navigationItem.title = @"聊天室";
  self.tabBarController.navigationItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark--UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  return _chatRoomList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"RCDChatRoomTableViewCell";
  RCDChatRoomTableViewCell *cell = (RCDChatRoomTableViewCell *)[tableView
      dequeueReusableCellWithIdentifier:CellIdentifier];

  RCDChatRoomInfo *chatRoom = _chatRoomList[indexPath.row];
  cell.lbChatroom.text = chatRoom.chatRoomName;
  cell.lbNumber.text = chatRoom.category;
  cell.lbDescription.text = chatRoom.introduce;
  UIImage *img = [UIImage imageNamed:chatRoom.portrait];
  cell.ivChatRoomPortrait.image = img;
  cell.ivChatRoomPortrait.layer.cornerRadius = 5.f;
  cell.ivChatRoomPortrait.layer.masksToBounds = YES;
  return cell;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  RCDChatRoomInfo *chatRoom = _chatRoomList[indexPath.row];
  RCDChatViewController *temp = [[RCDChatViewController alloc] init];
  temp.targetId = chatRoom.chatRoomId;
  temp.conversationType = ConversationType_CHATROOM;
  temp.userName = chatRoom.chatRoomName;
  temp.title = chatRoom.chatRoomName;
  [self.navigationController pushViewController:temp animated:YES];
}

@end
