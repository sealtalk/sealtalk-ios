//
//  RCDContactSelectedTableViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/3/17.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDContactSelectedTableViewController.h"
#import "DefaultPortraitView.h"
#import "MBProgressHUD.h"
#import "RCDChatViewController.h"
#import "RCDContactSelectedTableViewCell.h"
#import "RCDCreateGroupViewController.h"
#import "RCDHttpTool.h"
#import "RCDRCIMDataSource.h"
#import "RCDUserInfo.h"
#import "RCDataBaseManager.h"
#import "UIImageView+WebCache.h"
#import "pinyin.h"
#import "UIColor+RCColor.h"
#import "RCDUserInfoManager.h"
#import "RCDUtilities.h"
#import "RCDUIBarButtonItem.h"

@interface RCDContactSelectedTableViewController ()
@property(nonatomic, strong) NSMutableArray *friends;
@property(strong, nonatomic) NSMutableArray *friendsArr;
@property(nonatomic, strong) NSMutableArray *tempOtherArr;
@property (nonatomic, strong) RCDUIBarButtonItem *rightBtn;

@property(nonatomic, strong) NSIndexPath *selectIndexPath;

@property (nonatomic, strong) NSMutableArray *discussionGroupMemberIdList;
@end

@implementation RCDContactSelectedTableViewController
MBProgressHUD *hud;

- (void)viewDidLoad {
  [super viewDidLoad];
    
  _friendsArr = [[NSMutableArray alloc] init];

  self.navigationItem.title = _titleStr;
  self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

  //控制多选
  self.tableView.allowsMultipleSelection = YES;
  if (_isAllowsMultipleSelection == NO) {
    self.tableView.allowsMultipleSelection = NO;
  }

  self.tableView.tableFooterView = [UIView new];

  //自定义rightBarButtonItem
  self.rightBtn =
  [[RCDUIBarButtonItem alloc] initWithbuttonTitle:@"确定"
                                       titleColor:[UIColor colorWithHexString:@"000000" alpha:1.0]
                                      buttonFrame:CGRectMake(0, 0, 90, 30)
                                           target:self
                                           action:@selector(clickedDone:)];
  self.rightBtn.button.titleLabel.font = [UIFont systemFontOfSize:16];
  [self.rightBtn.button setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, -10)];
  [self.rightBtn buttonIsCanClick:NO
                      buttonColor:[UIColor colorWithHexString:@"9fcdfd" alpha:1.0]
                    barButtonItem:self.rightBtn];
  self.navigationItem.rightBarButtonItems = [self.rightBtn
                                             setTranslation:self.rightBtn
                                             translation:-11];
  //当是讨论组加人的情况，先生成讨论组用户的ID列表
  if (_addDiscussionGroupMembers.count > 0) {
    self.discussionGroupMemberIdList = [NSMutableArray new];
    for (RCUserInfo *memberInfo in _addDiscussionGroupMembers) {
      [self.discussionGroupMemberIdList addObject:memberInfo.userId];
    }
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  if ([_allFriends count] <= 0) {
    [self getAllData];
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self.rightBtn buttonIsCanClick:YES
                      buttonColor:[UIColor whiteColor]
                    barButtonItem:self.rightBtn];
  [hud hide:YES];
}

// clicked done
- (void)clickedDone:(id)sender {
  [self.rightBtn buttonIsCanClick:NO
                      buttonColor:[UIColor colorWithHexString:@"9fcdfd" alpha:1.0]
                    barButtonItem:self.rightBtn];
  hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  hud.color = [UIColor colorWithHexString:@"343637" alpha:0.5];
  //    hud.labelText = @"";
  [hud show:YES];

  NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];

  // get seleted users
  NSMutableArray *seletedUsers = [NSMutableArray new];
  NSMutableArray *seletedUsersId = [NSMutableArray new];
  for (NSIndexPath *indexPath in indexPaths) {
    NSString *key = [self.allKeys objectAtIndex:indexPath.section];
    NSArray *arrayForKey = [self.allFriends objectForKey:key];
    RCDUserInfo *user = arrayForKey[indexPath.row];
    //转成RCDUserInfo
    RCUserInfo *userInfo = [RCUserInfo new];
    userInfo.userId = user.userId;
    userInfo.name = user.name;
    userInfo.portraitUri = user.portraitUri;
    [[RCIM sharedRCIM] refreshUserInfoCache:userInfo
                                 withUserId:userInfo.userId];
    [seletedUsersId addObject:user.userId];
    [seletedUsers addObject:userInfo];
  }
  if (_selectUserList) {
    NSArray<RCUserInfo *> *userList = [NSArray arrayWithArray:seletedUsers];
    _selectUserList(userList);
    return;
  }

  if (_addGroupMembers.count > 0) {
    [RCDHTTPTOOL
        addUsersIntoGroup:_groupId
                  usersId:seletedUsersId
                 complete:^(BOOL result) {
                   if (result == YES) {
                     [self.navigationController popViewControllerAnimated:YES];
                   } else {
                     [hud hide:YES];
                     UIAlertView *alert = [[UIAlertView alloc]
                             initWithTitle:@"添加成员失败"
                                   message:nil
                                  delegate:self
                         cancelButtonTitle:@"确定"
                         otherButtonTitles:nil, nil];
                     [alert show];
                     [self.rightBtn buttonIsCanClick:YES
                                         buttonColor:[UIColor whiteColor]
                                       barButtonItem:self.rightBtn];
                   }
                 }];
    return;
  }
  if (_delGroupMembers.count > 0) {
    [RCDHTTPTOOL
        kickUsersOutOfGroup:_groupId
                    usersId:seletedUsersId
                   complete:^(BOOL result) {
                     if (result == YES) {
                       [self.navigationController
                           popViewControllerAnimated:YES];
                     } else {
                       [hud hide:YES];
                       UIAlertView *alert = [[UIAlertView alloc]
                               initWithTitle:@"删除成员失败"
                                     message:nil
                                    delegate:self
                           cancelButtonTitle:@"确定"
                           otherButtonTitles:nil, nil];
                       [alert show];
                       [self.rightBtn buttonIsCanClick:YES
                                           buttonColor:[UIColor whiteColor]
                                         barButtonItem:self.rightBtn];
                     }
                   }];
    return;
  }
  if (_addDiscussionGroupMembers.count > 0) {
    if (_discussiongroupId.length > 0) {
      [[RCIMClient sharedRCIMClient] addMemberToDiscussion:_discussiongroupId
          userIdList:seletedUsersId
          success:^(RCDiscussion *discussion) {
            NSLog(@"成功");
            [[NSNotificationCenter defaultCenter]
                postNotificationName:@"addDiscussiongroupMember"
                              object:seletedUsers];
            dispatch_async(dispatch_get_main_queue(), ^{
              [self.navigationController popViewControllerAnimated:YES];
            });
          }
          error:^(RCErrorCode status){
          }];
      return;
    } else {
      NSMutableString *discussionTitle = [NSMutableString string];
      NSMutableArray *userIdList = [NSMutableArray new];
      RCUserInfo *member = _addDiscussionGroupMembers[0];
      [seletedUsers addObject:member];
      for (RCUserInfo *user in seletedUsers) {
        [discussionTitle
            appendString:[NSString stringWithFormat:@"%@%@", user.name, @","]];
        [userIdList addObject:user.userId];
      }
      [discussionTitle
          deleteCharactersInRange:NSMakeRange(discussionTitle.length - 1, 1)];

      [[RCIMClient sharedRCIMClient] createDiscussion:discussionTitle
          userIdList:userIdList
          success:^(RCDiscussion *discussion) {
            NSLog(@"create discussion ssucceed!");
            dispatch_async(dispatch_get_main_queue(), ^{
              RCDChatViewController *chat =
                  [[RCDChatViewController alloc] init];
              chat.targetId = discussion.discussionId;
              chat.userName = discussion.discussionName;
              chat.conversationType = ConversationType_DISCUSSION;
              chat.title = @"讨论组";
              chat.needPopToRootView = YES;
              [self.navigationController pushViewController:chat animated:YES];
            });
          }
          error:^(RCErrorCode status) {
            NSLog(@"create discussion Failed > %ld!", (long)status);
          }];
      return;
    }
  }
  if (self.forCreatingGroup) {
      RCDCreateGroupViewController *createGroupVC = [RCDCreateGroupViewController createGroupViewController];
    createGroupVC.GroupMemberIdList = seletedUsersId;
    [self.navigationController pushViewController:createGroupVC animated:YES];
    return;
  }
  //    if (self.forCreatingDiscussionGroup) {
  if (seletedUsers.count == 1) {
    RCUserInfo *user = seletedUsers[0];
    RCDChatViewController *chat = [[RCDChatViewController alloc] init];
    chat.targetId = user.userId;
    chat.userName = user.name;
    chat.conversationType = ConversationType_PRIVATE;
    chat.title = user.name;
    chat.needPopToRootView = YES;
    chat.displayUserNameInCell = NO;

    //跳转到会话页面
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.navigationController pushViewController:chat animated:YES];
    });
    return;
  }
  if (self.forCreatingDiscussionGroup) {
    NSMutableString *discussionTitle = [NSMutableString string];
    NSMutableArray *userIdList = [NSMutableArray new];
    for (RCUserInfo *user in seletedUsers) {
      [discussionTitle appendString:[NSString stringWithFormat:@"%@%@", user.name,@","]];
      [userIdList addObject:user.userId];
    }
    [discussionTitle deleteCharactersInRange:NSMakeRange(discussionTitle.length - 1, 1)];
    
    [[RCIMClient sharedRCIMClient] createDiscussion:discussionTitle userIdList:userIdList success:^(RCDiscussion *discussion) {
      NSLog(@"create discussion ssucceed!");
      dispatch_async(dispatch_get_main_queue(), ^{
        RCDChatViewController *chat =[[RCDChatViewController alloc]init];
        chat.targetId                      = discussion.discussionId;
        chat.userName                    = discussion.discussionName;
        chat.conversationType              = ConversationType_DISCUSSION;
        chat.title                         = @"讨论组";
        chat.needPopToRootView = YES;
        [self.navigationController pushViewController:chat animated:YES];
      });
    } error:^(RCErrorCode status) {
      NSLog(@"create discussion Failed > %ld!", (long)status);
    }];
    return;
  }
  
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [_allKeys count];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  NSString *key = [_allKeys objectAtIndex:section];
  NSArray *arr = [_allFriends objectForKey:key];
  return [arr count];
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [RCDContactSelectedTableViewCell cellHeight];
}

// pinyin index
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
  return _allKeys;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
  NSString *key = [_allKeys objectAtIndex:section];
  return key;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellReuseIdentifier = @"RCDContactSelectedTableViewCell";
    
  RCDContactSelectedTableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if(!cell){
        cell = [[RCDContactSelectedTableViewCell alloc]init];
    }

  [cell setUserInteractionEnabled:YES];
  [cell.nicknameLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
  NSString *key = [self.allKeys objectAtIndex:indexPath.section];
  NSArray *arrayForKey = [self.allFriends objectForKey:key];

  RCDUserInfo *user = arrayForKey[indexPath.row];
  //给控件填充数据
  [cell setModel:user];
  
  //设置选中状态
  for (RCUserInfo *userInfo in self.seletedUsers) {
    if ([user.userId isEqualToString:userInfo.userId]) {
      [tableView selectRowAtIndexPath:indexPath
                             animated:NO
                       scrollPosition:UITableViewScrollPositionBottom];
      [cell setUserInteractionEnabled:NO];
    }
  }
  
    if(_isHideSelectedIcon){
        cell.selectedImageView .hidden = YES;
    }
    if ([self isContain:user.userId] == YES) {
      dispatch_async(dispatch_get_main_queue(), ^{
        cell.selectedImageView.image = [UIImage imageNamed:@"disable_select"];
      });
      cell.userInteractionEnabled = NO;
    }
  return cell;
}

// override delegate
- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self.rightBtn buttonIsCanClick:YES
                      buttonColor:[UIColor whiteColor]
                    barButtonItem:self.rightBtn];
  RCDContactSelectedTableViewCell *cell =
      (RCDContactSelectedTableViewCell *)[tableView
          cellForRowAtIndexPath:indexPath];
  [cell setSelected:YES];
//  if (self.selectIndexPath && self.selectIndexPath.row == indexPath.row) {
  if(self.selectIndexPath && [self.selectIndexPath compare:indexPath]==NSOrderedSame){
    [cell setSelected:NO];
    self.selectIndexPath = nil;
  } else {
    self.selectIndexPath = indexPath;
  }
    if (_selectUserList && self.isHideSelectedIcon) {
        NSMutableArray *seletedUsers = [NSMutableArray new];
        NSString *key = [self.allKeys objectAtIndex:indexPath.section];
        NSArray *arrayForKey = [self.allFriends objectForKey:key];
        RCDUserInfo *user = arrayForKey[indexPath.row];
        //转成RCDUserInfo
        RCUserInfo *userInfo = [RCUserInfo new];
        userInfo.userId = user.userId;
        userInfo.name = user.name;
        userInfo.portraitUri = user.portraitUri;
        [[RCIM sharedRCIM] refreshUserInfoCache:userInfo
                                     withUserId:userInfo.userId];
        [seletedUsers addObject:userInfo];

        NSArray<RCUserInfo *> *userList = [NSArray arrayWithArray:seletedUsers];
        _selectUserList(userList);
        return;
    }
    
    if(self.isAllowsMultipleSelection){
        NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
        NSString *titleStr = [NSString stringWithFormat:@"确定(%zd)",[indexPaths count]];
        [self.rightBtn.button setTitle:titleStr forState:UIControlStateNormal];
    }

}

- (void)tableView:(UITableView *)tableView
    didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
  RCDContactSelectedTableViewCell *cell =
      (RCDContactSelectedTableViewCell *)[tableView
          cellForRowAtIndexPath:indexPath];
  [cell setSelected:NO];
  if ([tableView.indexPathsForSelectedRows count] == 0) {
    [self.rightBtn buttonIsCanClick:NO
                        buttonColor:[UIColor colorWithHexString:@"9fcdfd" alpha:1.0]
                      barButtonItem:self.rightBtn];
  }
  self.selectIndexPath = nil;
    if(self.isAllowsMultipleSelection){
        NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
        NSString *titleStr = [NSString stringWithFormat:@"确定(%zd)",[indexPaths count]];
        [self.rightBtn.button setTitle:titleStr forState:UIControlStateNormal];
    }
}

#pragma mark - 获取好友并且排序
/**
 *  initial data
 */
- (void)getAllData {
 
  _allFriends = [NSMutableDictionary new];
  _allKeys = [NSMutableArray new];
  _friends = [NSMutableArray arrayWithArray:[[RCDataBaseManager shareInstance] getAllFriends]];
  if (_friends == nil || _friends.count < 1) {
    
    //        _noFriend.hidden = YES;
    [RCDDataSource
     syncFriendList:[RCIM sharedRCIM].currentUserInfo.userId
     complete:^(NSMutableArray *result) {
       _friends = result;
       [self dealWithFriendList];
     }];
  } else {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
      [self dealWithFriendList];
    });
  }
}

-(void)dealWithFriendList{
  
  for (int i = 0; i < _friends.count; i++) {
    RCDUserInfo *user = _friends[i];
    if ([user.status isEqualToString:@"20"]) {
      RCUserInfo *friend = [[RCDUserInfoManager shareInstance] getFriendInfoFromDB:user.userId];
      if (friend == nil) {
        friend = [[RCDUserInfoManager shareInstance] generateDefaultUserInfo:user.userId];
      }
      [_friendsArr addObject:friend];
    }
  }
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    [self deleteGroupMembers];
    NSMutableDictionary *resultDic = [RCDUtilities sortedArrayWithPinYinDic:_friendsArr];
    dispatch_async(dispatch_get_main_queue(), ^{
      _allFriends = resultDic[@"infoDic"];
      _allKeys = resultDic[@"allKeys"];
      [self.tableView reloadData];
    });
  });
}

- (void)deleteGroupMembers {
  if (_delGroupMembers.count > 0) {
    _friendsArr = _delGroupMembers;
  }
}

- (BOOL)isContain:(NSString*)userId {
  BOOL contain = NO;
  NSArray *userList;
  if (_addGroupMembers.count > 0) {
    userList = _addGroupMembers;
  }
  if (_addDiscussionGroupMembers.count > 0) {
    userList = self.discussionGroupMemberIdList;
  }
  for (NSString *memberId in userList) {
    if ([userId isEqualToString:memberId]) {
      contain = YES;
      break;
    }
  }
  return contain;
}


@end
