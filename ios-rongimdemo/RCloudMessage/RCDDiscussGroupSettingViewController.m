//
//  RCDiscussGroupSettingViewController.m
//  RongIMToolkit
//
//  Created by Liv on 15/3/30.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDDiscussGroupSettingViewController.h"
#import "RCDAddFriendViewController.h"
#import "RCDChatViewController.h"
#import "RCDContactSelectedTableViewController.h"
#import "RCDDiscussSettingCell.h"
#import "RCDDiscussSettingSwitchCell.h"
#import "RCDHttpTool.h"
#import "RCDPersonDetailViewController.h"
#import "RCDRCIMDataSource.h"
#import "RCDUpdateNameViewController.h"
#import "RCDataBaseManager.h"

@interface RCDDiscussGroupSettingViewController () <UIActionSheetDelegate>

@property(nonatomic, copy) NSString *discussTitle;
@property(nonatomic, copy) NSString *creatorId;
@property(nonatomic, strong) NSMutableDictionary *members;
@property(nonatomic, strong) NSMutableArray *userList;
@property(nonatomic, strong) UIButton *button;
@property(nonatomic) BOOL isOwner;
@property(nonatomic, assign) BOOL isClick;
@end

@implementation RCDDiscussGroupSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //显示顶部视图
    self.headerHidden = NO;
    _members = [[NSMutableDictionary alloc] init];
    _userList = [[NSMutableArray alloc] init];

    //添加当前聊天用户
    if (self.conversationType == ConversationType_PRIVATE) {

        [RCDHTTPTOOL getUserInfoByUserID:self.targetId
                              completion:^(RCUserInfo *user) {
                                  [self addUsers:@[ user ]];
                                  [_members setObject:user forKey:user.userId];
                                  [_userList addObject:user];
                              }];
    }

    //添加讨论组成员
    if (self.conversationType == ConversationType_DISCUSSION) {

        __weak RCDSettingBaseViewController *weakSelf = self;
        [[RCIMClient sharedRCIMClient]
            getDiscussion:self.targetId
                  success:^(RCDiscussion *discussion) {
                      if (discussion) {
                          _creatorId = discussion.creatorId;
                          if ([[RCIMClient sharedRCIMClient].currentUserInfo.userId
                                  isEqualToString:discussion.creatorId]) {
                              [weakSelf disableDeleteMemberEvent:NO];
                              self.isOwner = YES;

                          } else {
                              [weakSelf disableDeleteMemberEvent:YES];
                              self.isOwner = NO;
                              if (discussion.inviteStatus == 1) {
                                  [self disableInviteMemberEvent:YES];
                              }
                          }

                          NSMutableArray *users = [NSMutableArray new];
                          for (NSString *targetId in discussion.memberIdList) {
                              [RCDHTTPTOOL getUserInfoByUserID:targetId
                                                    completion:^(RCUserInfo *user) {
                                                        if ([discussion.creatorId isEqualToString:user.userId]) {
                                                            [users insertObject:user atIndex:0];
                                                        } else {

                                                            [users addObject:user];
                                                        }
                                                        [_members setObject:user forKey:user.userId];
                                                        if (users.count == discussion.memberIdList.count) {
                                                            [weakSelf addUsers:users];
                                                            [_userList addObjectsFromArray:users];
                                                        }
                                                    }];
                          }
                      }
                  }
                    error:^(RCErrorCode status){

                    }];
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 45)];

    UIImage *image = [UIImage imageNamed:@"group_quit"];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 42, 90 / 2)];

    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setTitle:RCDLocalizedString(@"delete_and_exit")
 forState:UIControlStateNormal];
    [button setCenter:CGPointMake(view.bounds.size.width / 2, view.bounds.size.height / 2)];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    self.button = button;
    self.tableView.tableFooterView = view;
    self.tableView.cellLayoutMarginsFollowReadableWidth = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshHeaderView:)
                                                 name:@"addDiscussiongroupMember"
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _isClick = YES;
}

- (void)viewDidLayoutSubviews {
    self.button.frame = CGRectMake(0, 0, self.view.frame.size.width - 42, 90 / 2);
    [self.button setCenter:CGPointMake(self.view.bounds.size.width / 2, 45 / 2)];
}

- (void)buttonAction:(UIButton *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:RCDLocalizedString(@"delete_and_exit_discuss_group")

                                                             delegate:self
                                                    cancelButtonTitle:RCDLocalizedString(@"cancel")

                                               destructiveButtonTitle:RCDLocalizedString(@"confirm")

                                                    otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}
#pragma mark -UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([actionSheet isEqual:self.clearMsgHistoryActionSheet] && buttonIndex == 0) {
        [self clearHistoryMessage];
    } else {
        if (0 == buttonIndex) {
            __weak typeof(self) weakSelf = self;
            [[RCIM sharedRCIM] quitDiscussion:self.targetId
                success:^(RCDiscussion *discussion) {
                    NSLog(@"退出讨论组成功");
                    UIViewController *temp = nil;
                    NSArray *viewControllers = weakSelf.navigationController.viewControllers;
                    temp = viewControllers[viewControllers.count - 1 - 2];
                    if (temp) {
                        //切换主线程
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.navigationController popToViewController:temp animated:YES];
                        });
                    }
                }
                error:^(RCErrorCode status) {
                    NSLog(@"quit discussion status is %ld", (long)status);

                }];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isOwner) {
        return self.defaultCells.count + 2;
    } else {
        return self.defaultCells.count + 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    int offset = 2;
    if (!self.isOwner) {
        offset = 1;
    }
    switch (indexPath.row) {
    case 0: {
        RCDDiscussSettingCell *discussCell = [[RCDDiscussSettingCell alloc] initWithFrame:CGRectZero];
        discussCell.lblDiscussName.text = self.conversationTitle;
        discussCell.lblTitle.text = RCDLocalizedString(@"discussion_group_name");
        cell = discussCell;
        _discussTitle = discussCell.lblDiscussName.text;
    } break;
    case 1: {
        if (self.isOwner) {
            RCDDiscussSettingSwitchCell *switchCell = [[RCDDiscussSettingSwitchCell alloc] initWithFrame:CGRectZero];
            switchCell.label.text = RCDLocalizedString(@"open_member_invite");
            [[RCIMClient sharedRCIMClient] getDiscussion:self.targetId
                                                 success:^(RCDiscussion *discussion) {
                                                     if (discussion.inviteStatus == 0) {
                                                         switchCell.swich.on = YES;
                                                     }
                                                 }
                                                   error:^(RCErrorCode status){

                                                   }];
            [switchCell.swich addTarget:self
                                 action:@selector(openMemberInv:)
                       forControlEvents:UIControlEventTouchUpInside];
            cell = switchCell;
        } else {
            cell = self.defaultCells[0];
        }

    } break;
    case 2: {
        cell = self.defaultCells[indexPath.row - offset];
    } break;
    case 3: {
        cell = self.defaultCells[indexPath.row - offset];

    } break;
    case 4: {
        cell = self.defaultCells[indexPath.row - offset];

    } break;
    }

    return cell;
}

#pragma mark - RCConversationSettingTableViewHeader Delegate
//点击最后一个+号事件
- (void)settingTableViewHeader:(RCConversationSettingTableViewHeader *)settingTableViewHeader
       indexPathOfSelectedItem:(NSIndexPath *)indexPathOfSelectedItem
            allTheSeletedUsers:(NSArray *)users {

    //点击最后一个+号,调出选择联系人UI
    if (indexPathOfSelectedItem.row == settingTableViewHeader.users.count) {
        RCDContactSelectedTableViewController *contactSelectedVC = [[RCDContactSelectedTableViewController alloc] init];
        contactSelectedVC.addDiscussionGroupMembers = _userList;
        if (self.conversationType == ConversationType_DISCUSSION) {
            contactSelectedVC.discussiongroupId = self.targetId;
            contactSelectedVC.isAllowsMultipleSelection = YES;
        }

        [self.navigationController pushViewController:contactSelectedVC animated:YES];
    }
}

#pragma mark - private method
- (void)refreshHeaderView:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray *members = notification.object;
        [_userList addObjectsFromArray:members];
        [self addUsers:_userList];
    });
}

- (void)createDiscussionOrInvokeMemberWithSelectedUsers:(NSArray *)selectedUsers {
    //    __weak RCDSettingViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (ConversationType_DISCUSSION == self.conversationType) {
            // invoke new member to current discussion

            NSMutableArray *addIdList = [NSMutableArray new];
            for (RCUserInfo *user in selectedUsers) {
                [addIdList addObject:user.userId];
            }

            //加入讨论组
            if (addIdList.count != 0) {

                [[RCIM sharedRCIM] addMemberToDiscussion:self.targetId
                                              userIdList:addIdList
                                                 success:^(RCDiscussion *discussion) {
                                                     NSLog(@"成功");
                                                 }
                                                   error:^(RCErrorCode status){
                                                   }];
            }

        } else if (ConversationType_PRIVATE == self.conversationType) {
            // create new discussion with the new invoked member.
            NSUInteger _count = [_members.allKeys count];
            if (_count > 1) {

                NSMutableString *discussionTitle = [NSMutableString string];
                NSMutableArray *userIdList = [NSMutableArray new];
                for (int i = 0; i < _count; i++) {
                    RCUserInfo *_userInfo = (RCUserInfo *)_members.allValues[i];
                    [discussionTitle appendString:[NSString stringWithFormat:@"%@%@", _userInfo.name, @","]];

                    [userIdList addObject:_userInfo.userId];
                }
                [discussionTitle deleteCharactersInRange:NSMakeRange(discussionTitle.length - 1, 1)];
                self.conversationTitle = discussionTitle;

                __weak typeof(self) weakSelf = self;
                [[RCIM sharedRCIM]
                    createDiscussion:discussionTitle
                          userIdList:userIdList
                             success:^(RCDiscussion *discussion) {

                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     RCDChatViewController *chat = [[RCDChatViewController alloc] init];
                                     chat.targetId = discussion.discussionId;
                                     chat.userName = discussion.discussionName;
                                     chat.conversationType = ConversationType_DISCUSSION;
                                     chat.title = discussionTitle; //[NSString
                                                                   // stringWithFormat:@"讨论组(%lu)",
                                                                   //(unsigned long)_count];

                                     UITabBarController *tabbarVC = weakSelf.navigationController.viewControllers[0];
                                     [weakSelf.navigationController popToViewController:tabbarVC animated:NO];
                                     [tabbarVC.navigationController pushViewController:chat animated:YES];
                                 });
                             }
                               error:^(RCErrorCode status){
                                   //            DebugLog(@"create discussion Failed > %ld!",
                                   //            (long)status);
                               }];
            }
        }
    });
}

- (void)openMemberInv:(UISwitch *)swch {
    //设置成员邀请权限

    [[RCIM sharedRCIM] setDiscussionInviteStatus:self.targetId
                                          isOpen:swch.on
                                         success:^{
                                             //        DebugLog(RCDLocalizedString(@"setting_success"));
                                         }
                                           error:^(RCErrorCode status){

                                           }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if (self.setDiscussTitleCompletion) {
        self.setDiscussTitleCompletion(_discussTitle);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        RCDDiscussSettingCell *discussCell = (RCDDiscussSettingCell *)[tableView cellForRowAtIndexPath:indexPath];
        discussCell.lblTitle.text = RCDLocalizedString(@"discussion_group_name");
        RCDUpdateNameViewController *updateNameViewController = [RCDUpdateNameViewController updateNameViewController];
        updateNameViewController.targetId = self.targetId;
        updateNameViewController.displayText = discussCell.lblDiscussName.text;
        updateNameViewController.setDisplayTextCompletion = ^(NSString *text) {
            discussCell.lblDiscussName.text = text;
            _discussTitle = text;

        };
        UINavigationController *navi =
            [[UINavigationController alloc] initWithRootViewController:updateNameViewController];
        [self.navigationController presentViewController:navi animated:YES completion:nil];
    }
}

/**
 *  override
 *
 *  @param 添加顶部视图显示的user,必须继承以调用父类添加user
 */
- (void)addUsers:(NSArray *)users {
    [super addUsers:users];
}

/**
 *  override 左上角删除按钮回调
 *
 *  @param indexPath indexPath description
 */
- (void)deleteTipButtonClicked:(NSIndexPath *)indexPath {
    RCUserInfo *user = self.users[indexPath.row];
    if ([user.userId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        return;
    }
    [[RCIM sharedRCIM] removeMemberFromDiscussion:self.targetId
        userId:user.userId
        success:^(RCDiscussion *discussion) {
            NSLog(@"踢人成功");
            [_userList removeObject:user];
            [self.users removeObject:user];
            [self.members removeObjectForKey:user.userId];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addUsers:self.users];
            });
        }
        error:^(RCErrorCode status) {
            NSLog(@"踢人失败");
        }];
}

- (void)didTipHeaderClicked:(NSString *)userId {
    if (_isClick) {
        _isClick = NO;
        [[RCDRCIMDataSource shareInstance]
            getUserInfoWithUserId:userId
                       completion:^(RCUserInfo *userInfo) {
                           [[RCDHttpTool shareInstance] updateUserInfo:userId
                               success:^(RCUserInfo *user) {
                                   if (![userInfo.name isEqualToString:user.name]) {
                                       [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:user.userId];
                                   }
                                   NSArray *friendList = [[RCDataBaseManager shareInstance] getAllFriends];
                                   for (RCUserInfo *USER in friendList) {
                                       if ([userId isEqualToString:USER.userId] ||
                                           [userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
                                           RCDPersonDetailViewController *temp =
                                               [[RCDPersonDetailViewController alloc] init];
                                           temp.userId = user.userId;
                                           [self.navigationController pushViewController:temp animated:YES];
                                           return;
                                       }
                                   }
                                   RCDAddFriendViewController *addViewController =

                                       [[RCDAddFriendViewController alloc] init];

                                   addViewController.targetUserInfo = userInfo;

                                   [self.navigationController

                                       pushViewController:addViewController

                                                 animated:YES];

                               }
                               failure:^(NSError *err) {
                                   _isClick = NO;
                               }];
                       }];
    }
}

@end
