//
//  RCDSettingViewController.m
//  RCloudMessage
//
//  Created by Liv on 15/3/31.
//  Copyright (c) 2015年 胡利武. All rights reserved.
//

#import "RCDSettingViewController.h"
#import "RCDChatViewController.h"
#import "RCDHttpTool.h"
#import "RCDSelectPersonViewController.h"
#import <RongIMLib/RongIMLib.h>
#import <RongIMToolkit/RongIMToolkit.h>

@interface RCDSettingViewController () <UIActionSheetDelegate>

@property(nonatomic, strong) NSArray *members;

- (void)createDiscussionOrInvokeMemberWithSelectedUsers:(NSArray *)selectedUsers;

@end

@implementation RCDSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //设置switch状态
    [self setSwitchState];

    //添加当前聊天用户
    if (self.conversationType == ConversationType_PRIVATE) {

        [RCDHTTPTOOL getUserInfoByUserID:self.targetId
                              completion:^(RCUserInfo *user) {
                                  [self addUsers:@[ user ]];
                                  _members = @[ user ];

                              }];
    }

    //添加讨论组成员
    if (self.conversationType == ConversationType_DISCUSSION) {

        __weak RCDSettingViewController *weakSelf = self;
        [[RCIMClient sharedClient]
            getDiscussion:self.targetId
               completion:^(RCDiscussion *discussion) {
                   if (discussion) {

                       if ([[RCIMClient sharedClient].currentUserInfo.userId isEqualToString:discussion.creatorId]) {
                           [self disableDeleteMemberEvent:NO];

                       } else {
                           [self disableDeleteMemberEvent:YES];
                       }

                       NSMutableArray *users = [NSMutableArray new];

                       for (NSString *targetId in discussion.memberIdList) {
                           [RCDHTTPTOOL getUserInfoByUserID:targetId
                                                 completion:^(RCUserInfo *user) {
                                                     [users addObject:user];
                                                     _members = users;
                                                     [weakSelf addUsers:users];
                                                 }];
                       }
                   }
               }
                    error:^(RCErrorCode status){

                    }];
    }

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"设置";
    self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(backBarButtonItemClicked:)];
}

- (void)backBarButtonItemClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - RCConversationSettingTableViewHeader Delegate
//点击最后一个+号事件
- (void)settingTableViewHeader:(RCConversationSettingTableViewHeader *)settingTableViewHeader
       indexPathOfSelectedItem:(NSIndexPath *)indexPathOfSelectedItem
            allTheSeletedUsers:(NSArray *)users {
    //点击最后一个+号,调出选择联系人UI
    if (indexPathOfSelectedItem.row == settingTableViewHeader.users.count) {

        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RCDSelectPersonViewController *selectPersonVC =
            [mainStoryboard instantiateViewControllerWithIdentifier:@"RCDSelectPersonViewController"];
        [selectPersonVC setSeletedUsers:users];
        //设置回调
        selectPersonVC.clickDoneCompletion =
            ^(RCDSelectPersonViewController *selectPersonViewController, NSArray *selectedUsers) {

                if (selectedUsers && selectedUsers.count) {

                    NSString *_currentTargetId = [RCIMClient sharedClient].currentUserInfo.userId;

                    [RCDHTTPTOOL getUserInfoByUserID:_currentTargetId
                                          completion:^(RCUserInfo *user) {
                                              RCUserInfo *userInfo = user;
                                              NSMutableArray *_allUsers = [NSMutableArray new];
                                              [_allUsers addObject:userInfo]; // add current user info object
                                              [_allUsers addObjectsFromArray:selectedUsers]; // add the
                                                                                             // selected users
                                              [self addUsers:(NSArray *)_allUsers];

                                              [self createDiscussionOrInvokeMemberWithSelectedUsers:selectedUsers];

                                          }];
                }

                [selectPersonViewController.navigationController popViewControllerAnimated:YES];
            };
        [self.navigationController pushViewController:selectPersonVC animated:YES];
    }
}

#pragma mark - private method
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

                [[RCIMClient sharedClient] addMemberToDiscussion:self.targetId
                                                      userIdList:addIdList
                                                      completion:^(RCDiscussion *discussion) {
                                                      }
                                                           error:^(RCErrorCode status){

                                                           }];
            }

        } else if (ConversationType_PRIVATE == self.conversationType) {
            // create new discussion with the new invoked member.
            NSUInteger _count = [selectedUsers count];
            if (_count > 1) {
                NSMutableString *discussionTitle = [NSMutableString string];

                NSMutableArray *userIdList = [NSMutableArray new];

                for (int i = 0; i < _count; i++) {
                    RCUserInfo *_userInfo = (RCUserInfo *)selectedUsers[i];

                    if (i == (_count - 1)) {
                        [discussionTitle appendString:_userInfo.name];
                    } else {
                        [discussionTitle appendString:[NSString stringWithFormat:@"%@%@", _userInfo.name, @","]];
                    }

                    [userIdList addObject:_userInfo.userId];
                }

                self.conversationTitle = discussionTitle;
                __weak typeof(&*self) weakSelf = self;
                [[RCIMClient sharedClient]
                    createDiscussion:discussionTitle
                          userIdList:userIdList
                          completion:^(RCDiscussion *discussion) {

                              dispatch_async(dispatch_get_main_queue(), ^{
                                  RCDChatViewController *chat = [[RCDChatViewController alloc] init];
                                  chat.targetId = discussion.discussionId;
                                  chat.targetName = discussion.discussionName;
                                  chat.conversationType = ConversationType_DISCUSSION;
                                  chat.title = discussionTitle; //[NSString
                                                                // stringWithFormat:@"讨论组(%lu)",
                                                                //(unsigned long)_count];

                                  UITabBarController *tabbarVC = weakSelf.navigationController.viewControllers[0];
                                  [weakSelf.navigationController popToViewController:tabbarVC animated:YES];
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

/**
 *  override
 *
 *  @param indexPath indexPath description
 */
- (void)deleteTipButtonClicked:(NSIndexPath *)indexPath {
    RCUserInfo *user = self.users[indexPath.row];
    [[RCIMClient sharedClient] removeMemberFromDiscussion:self.targetId
                                                   userId:user.userId
                                               completion:^(RCDiscussion *discussion) {

                                               }
                                                    error:^(RCErrorCode status){

                                                    }];
}

- (void)setSwitchState {

    //设置新消息通知状态
    [[RCIMClient sharedClient] getConversationNotificationStatus:self.conversationType
                                                        targetId:self.targetId
                                                      completion:^(RCConversationNotificationStatus nStatus) {

                                                          BOOL isNotify = NO;
                                                          if (nStatus == NOTIFY) {
                                                              isNotify = YES;
                                                          }
                                                          self.switch_newMessageNotify = isNotify;

                                                      }
                                                           error:^(RCErrorCode status){

                                                           }];

    //设置置顶聊天状态
    RCConversation *conversation =
        [[RCIMClient sharedClient] getConversation:self.conversationType targetId:self.targetId];
    self.switch_isTop = conversation.isTop;
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
 *  override
 *
 *  @param sender sender description
 */
- (void)onClickNewMessageNotificationSwitch:(id)sender {
    UISwitch *swch = sender;
    __weak RCDSettingViewController *weakSelf = self;
    [[RCIMClient sharedClient] setConversationNotificationStatus:self.conversationType
                                                        targetId:self.targetId
                                                       isBlocked:!swch.on
                                                      completion:^(RCConversationNotificationStatus nStatus) {
                                                          BOOL isNotify = NO;
                                                          if (nStatus == NOTIFY) {
                                                              isNotify = YES;
                                                          }
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              weakSelf.switch_newMessageNotify = isNotify;
                                                          });

                                                      }
                                                           error:^(RCErrorCode status){

                                                           }];
}

/**
 *  override
 *
 *  @param sender sender description
 */
- (void)onClickClearMessageHistory:(id)sender {

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"是否删除历史消息？"
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:@"确定"
                                                    otherButtonTitles:nil, nil];
    [actionSheet showInView:self.view];
}

/**
 *  override
 *
 *  @param sender sender description
 */
- (void)onClickIsTopSwitch:(id)sender {
    UISwitch *swch = sender;
    [[RCIMClient sharedClient] setConversationToTop:self.conversationType targetId:self.targetId isTop:swch.on];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        BOOL isClear = [[RCIMClient sharedClient] clearMessages:self.conversationType targetId:self.targetId];

        //清除消息之后回调操作，例如reload 会话列表
        if (self.clearHistoryCompletion) {
            self.clearHistoryCompletion(isClear);
        }
    }
}

@end
