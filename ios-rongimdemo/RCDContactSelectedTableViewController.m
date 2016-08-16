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

@interface RCDContactSelectedTableViewController ()
@property(nonatomic, strong) NSMutableArray *friends;
@property(strong, nonatomic) NSMutableArray *friendsArr;
@property(nonatomic, strong) NSMutableArray *tempOtherArr;
//@property (nonatomic,strong) UILabel *noFriend;

@property(nonatomic, strong) NSIndexPath *selectIndexPath;

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

  // rightBarButtonItem click event
  self.navigationItem.rightBarButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:@"确定"
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(clickedDone:)];
  self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  if ([_allFriends count] > 0) {

  } else {
    [self getAllData];
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  self.navigationItem.rightBarButtonItem.enabled = YES;
  [hud hide:YES];
}

// clicked done
- (void)clickedDone:(id)sender {
  
  self.navigationItem.rightBarButtonItem.enabled = NO;
  hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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
                     [[NSNotificationCenter defaultCenter]
                         postNotification:
                             [NSNotification
                                 notificationWithName:@"addGroupMemberList"
                                               object:seletedUsers]];
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
                     self.navigationItem.rightBarButtonItem.enabled = YES;
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
                       [[NSNotificationCenter defaultCenter]
                           postNotification:
                               [NSNotification
                                   notificationWithName:@"deleteGroupMemberList"
                                                 object:seletedUsers]];
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
                       self.navigationItem.rightBarButtonItem.enabled = YES;
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
    UIStoryboard *mainStoryboard =
        [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RCDCreateGroupViewController *createGroupVC =
        [mainStoryboard instantiateViewControllerWithIdentifier:
                            @"RCDCreateGroupViewController"];
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
  return 70.f;
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

  [cell setUserInteractionEnabled:YES];
  [cell.nicknameLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
  NSString *key = [self.allKeys objectAtIndex:indexPath.section];
  NSArray *arrayForKey = [self.allFriends objectForKey:key];

  RCDUserInfo *user = arrayForKey[indexPath.row];
  if (user) {
    cell.nicknameLabel.text = user.name;
    if ([user.portraitUri isEqualToString:@""]) {
      DefaultPortraitView *defaultPortrait = [[DefaultPortraitView alloc]
          initWithFrame:CGRectMake(0, 0, 100, 100)];
      [defaultPortrait setColorAndLabel:user.userId Nickname:user.name];
      UIImage *portrait = [defaultPortrait imageFromView];
      cell.portraitImageView.image = portrait;
    } else {
      [cell.portraitImageView
          sd_setImageWithURL:[NSURL URLWithString:user.portraitUri]
            placeholderImage:[UIImage imageNamed:@"icon_person"]];
    }
  }

  //设置选中状态
  for (RCUserInfo *userInfo in self.seletedUsers) {
    if ([user.userId isEqualToString:userInfo.userId]) {
      [tableView selectRowAtIndexPath:indexPath
                             animated:NO
                       scrollPosition:UITableViewScrollPositionBottom];
      [cell setUserInteractionEnabled:NO];
    }
  }
  if ([RCIM sharedRCIM].globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
      [RCIM sharedRCIM].globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
    cell.portraitImageView.layer.masksToBounds = YES;
    cell.portraitImageView.layer.cornerRadius = 20.f;
  } else {
    cell.portraitImageView.layer.masksToBounds = YES;
    cell.portraitImageView.layer.cornerRadius = 5.f;
  }
  cell.portraitImageView.contentMode = UIViewContentModeScaleAspectFill;
    if(_isHideSelectedIcon){
        cell.selectedImageView .hidden = YES;
    }
  return cell;
}

// override delegate
- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  self.navigationItem.rightBarButtonItem.enabled = YES;
  RCDContactSelectedTableViewCell *cell =
      (RCDContactSelectedTableViewCell *)[tableView
          cellForRowAtIndexPath:indexPath];
  [cell setSelected:YES];
  if (self.selectIndexPath && self.selectIndexPath.row == indexPath.row) {
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

}

- (void)tableView:(UITableView *)tableView
    didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
  RCDContactSelectedTableViewCell *cell =
      (RCDContactSelectedTableViewCell *)[tableView
          cellForRowAtIndexPath:indexPath];
  [cell setSelected:NO];
  if ([tableView.indexPathsForSelectedRows count] == 0) {
    self.navigationItem.rightBarButtonItem.enabled = NO;
  }
  self.selectIndexPath = nil;
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
    [RCDDataSource syncFriendList:[RCIM sharedRCIM].currentUserInfo.userId
                         complete:^(NSMutableArray *result) {
                           _friends = result;
                           for (RCDUserInfo *user in _friends) {
                             if ([user.status isEqualToString:@"20"]) {
                               [_friendsArr addObject:user];
                             }
                           }
                           dispatch_async(dispatch_get_global_queue(0, 0), ^{
                             [self addOrDelGroupMembers];
                             _allFriends =
                                 [self sortedArrayWithPinYinDic:_friendsArr];
                             dispatch_async(dispatch_get_main_queue(), ^{
                               [self.tableView reloadData];

                             });
                           });

                         }];
  } else {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
      for (RCDUserInfo *user in _friends) {
        if ([user.status isEqualToString:@"20"]) {
          [_friendsArr addObject:user];
        }
      }
      [self addOrDelGroupMembers];
      _allFriends = [self sortedArrayWithPinYinDic:_friendsArr];
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];

      });
    });
  }
}

#pragma mark - 拼音排序

/**
 *  汉字转拼音
 *
 *  @param hanZi 汉字
 *
 *  @return 转换后的拼音
 */
- (NSString *)hanZiToPinYinWithString:(NSString *)hanZi {
  if (!hanZi)
    return nil;
  NSString *pinYinResult = [NSString string];
  for (int j = 0; j < hanZi.length; j++) {
    NSString *singlePinyinLetter = [[NSString
        stringWithFormat:@"%c", pinyinFirstLetter([hanZi characterAtIndex:j])]
        uppercaseString];
    pinYinResult = [pinYinResult stringByAppendingString:singlePinyinLetter];
  }

  return pinYinResult;
}

/**
 *  根据转换拼音后的字典排序
 *
 *  @param pinyinDic 转换后的字典
 *
 *  @return 对应排序的字典
 */
- (NSMutableDictionary *)sortedArrayWithPinYinDic:(NSArray *)friends {
  if (!friends)
    return nil;
    _keys = @[
              @"A",
              @"B",
              @"C",
              @"D",
              @"E",
              @"F",
              @"G",
              @"H",
              @"I",
              @"J",
              @"K",
              @"L",
              @"M",
              @"N",
              @"O",
              @"P",
              @"Q",
              @"R",
              @"S",
              @"T",
              @"U",
              @"V",
              @"W",
              @"X",
              @"Y",
              @"Z",
              @"#"
              ];

  NSMutableDictionary *returnDic = [NSMutableDictionary new];
  _tempOtherArr = [NSMutableArray new];
  BOOL isReturn = NO;

  for (NSString *key in _keys) {

    if ([_tempOtherArr count]) {
      isReturn = YES;
    }

    NSMutableArray *tempArr = [NSMutableArray new];
    for (RCDUserInfo *user in friends) {

      NSString *pyResult = [self hanZiToPinYinWithString:user.name];
      NSString *firstLetter = [pyResult substringToIndex:1];
      if ([firstLetter isEqualToString:key]) {
        [tempArr addObject:user];
      }

      if (isReturn)
        continue;
      char c = [pyResult characterAtIndex:0];
      if (isalpha(c) == 0) {
        [_tempOtherArr addObject:user];
      }
    }
    if (![tempArr count])
      continue;
    [returnDic setObject:tempArr forKey:key];
  }
  if ([_tempOtherArr count])
    [returnDic setObject:_tempOtherArr forKey:@"#"];

  _allKeys = [[returnDic allKeys]
      sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {

        return [obj1 compare:obj2 options:NSNumericSearch];
      }];

  return returnDic;
}

- (void)addOrDelGroupMembers {
  if (_addGroupMembers.count > 0) {
    NSMutableIndexSet *indexSets = [NSMutableIndexSet new];
    for (NSString *userId in _addGroupMembers) {
      for (int i = 0; i < _friendsArr.count; i++) {
        RCDUserInfo *user = [_friendsArr objectAtIndex:i];
        if ([userId isEqualToString:user.userId]) {
          [indexSets addIndex:i];
        }
      }
    }
    [_friendsArr removeObjectsAtIndexes:indexSets];
  }
  if (_delGroupMembers.count > 0) {
    _friendsArr = _delGroupMembers;
  }
  if (_addDiscussionGroupMembers.count > 0) {
    NSMutableIndexSet *indexSets = [NSMutableIndexSet new];
    for (RCUserInfo *member in _addDiscussionGroupMembers) {
      for (int i = 0; i < _friendsArr.count; i++) {
        RCDUserInfo *user = [_friendsArr objectAtIndex:i];
        if ([member.userId isEqualToString:user.userId]) {
          [indexSets addIndex:i];
        }
      }
    }
    [_friendsArr removeObjectsAtIndexes:indexSets];
  }
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
