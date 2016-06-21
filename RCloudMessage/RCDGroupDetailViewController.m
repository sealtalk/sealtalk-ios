//
//  RCDGroupDetailViewController.m
//  RCloudMessage
//
//  Created by 杜立召 on 15/3/21.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDGroupDetailViewController.h"
#import "RCDGroupInfo.h"
#import "RCDHttpTool.h"
#import "RCDRCIMDataSource.h"
#import "RCDChatViewController.h"

@interface RCDGroupDetailViewController () <UIActionSheetDelegate>

@end

@implementation RCDGroupDetailViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  _lbGroupName.text = _groupInfo.groupName;
  _lbGroupIntru.text = _groupInfo.introduce;

  _lbNumberInGroup.text = [NSString
      stringWithFormat:@"%@/%@", _groupInfo.number, _groupInfo.maxNumber];
  UIImage *imageChat = [UIImage imageNamed:@"group_add"];
  imageChat = [imageChat
      stretchableImageWithLeftCapWidth:floorf(imageChat.size.width / 2)
                          topCapHeight:floorf(imageChat.size.height / 2)];
  [_btChat setTitle:@"发起会话" forState:UIControlStateNormal];
  [_btChat setBackgroundImage:imageChat forState:UIControlStateNormal];
  if (_groupInfo.isJoin) {
    [_btChat setHidden:NO];
    [self.messageDisTrubleCell setHidden:NO];
    [self.clearMessageCell setHidden:NO];
    [self.messageTopCell setHidden:NO];
    UIImage *image = [UIImage imageNamed:@"group_quit"];
    image =
        [image stretchableImageWithLeftCapWidth:floorf(image.size.width / 2)
                                   topCapHeight:floorf(image.size.height / 2)];
    [_btJoinOrQuitGroup setTitle:@"删除并退出" forState:UIControlStateNormal];
    [_btJoinOrQuitGroup setBackgroundImage:image forState:UIControlStateNormal];
  } else {
    [self.messageDisTrubleCell setHidden:YES];
    [self.clearMessageCell setHidden:YES];
    [self.messageTopCell setHidden:YES];
    [_btChat setHidden:YES];
    UIImage *image = [UIImage imageNamed:@"group_add"];
    image =
        [image stretchableImageWithLeftCapWidth:floorf(image.size.width / 2)
                                   topCapHeight:floorf(image.size.height / 2)];
    [_btJoinOrQuitGroup setTitle:@"加入" forState:UIControlStateNormal];
    [_btJoinOrQuitGroup setBackgroundImage:image forState:UIControlStateNormal];
  }
  [self.swConversationTop setOn:NO];
  RCConversation *conversation =
      [[RCIMClient sharedRCIMClient] getConversation:ConversationType_GROUP
                                            targetId:_groupInfo.groupId];
  if (conversation) {
    if (conversation.isTop) {
      [self.swConversationTop setOn:YES];
    }
  }
  //消息免打扰状态
  [[RCIMClient sharedRCIMClient]
      getConversationNotificationStatus:ConversationType_GROUP
      targetId:_groupInfo.groupId
      success:^(RCConversationNotificationStatus nStatus) {

        BOOL enableNotification = NO;
        if (nStatus == NOTIFY) {
          enableNotification = YES;
        }
        [self.swMessageNotDistrub setOn:enableNotification];

      }
      error:^(RCErrorCode status){

      }];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)joinOrQuitGroup:(id)sender {
  int groupId = [_groupInfo.groupId intValue];
    NSString *groupName = self.lbGroupName.text;
  if (!_groupInfo.isJoin) {

    [RCDHTTPTOOL
        joinGroup:groupId
     withGroupName:groupName
         complete:^(BOOL isOk) {
           dispatch_async(dispatch_get_main_queue(), ^{
             if (isOk) {
               _groupInfo.isJoin = YES;
               [RCDDataSource syncGroups];
               UIImage *image = [UIImage imageNamed:@"group_quit"];
               image = [image
                   stretchableImageWithLeftCapWidth:floorf(image.size.width / 2)
                                       topCapHeight:floorf(image.size.height /
                                                           2)];
               [_btJoinOrQuitGroup setTitle:@"删除并退出"
                                   forState:UIControlStateNormal];
                 
               [_btChat setHidden:NO];
               [self.messageDisTrubleCell setHidden:NO];
               [self.clearMessageCell setHidden:NO];
               [self.messageTopCell setHidden:NO];

               [_btJoinOrQuitGroup setBackgroundImage:image
                                             forState:UIControlStateNormal];
             } else {
               NSString *msg = @"加入失败";
               if (_groupInfo.number == _groupInfo.maxNumber)
                 msg = @"群组人数已满";

               UIAlertView *alertView =
                   [[UIAlertView alloc] initWithTitle:nil
                                              message:msg
                                             delegate:nil
                                    cancelButtonTitle:@"确定"
                                    otherButtonTitles:nil, nil];
               [alertView show];

               [RCDDataSource syncGroups];
             }
           });

         }];
  } else {
    UIActionSheet *actionSheet =
        [[UIActionSheet alloc] initWithTitle:@"确定退出群组？"
                                    delegate:self
                           cancelButtonTitle:@"取消"
                      destructiveButtonTitle:@"确定"
                           otherButtonTitles:nil];
    [actionSheet showInView:self.view];
  }
}

- (IBAction)beginGroupChat:(id)sender {

  NSUInteger count = self.navigationController.viewControllers.count;
  if (count > 1) {
    UIViewController *preVC =
        self.navigationController.viewControllers[count - 2];
    if ([preVC isKindOfClass:[RCConversationViewController class]]) {
      [self.navigationController popViewControllerAnimated:YES];
      return;
    } else {
      RCDChatViewController *temp = [[RCDChatViewController alloc] init];
      temp.targetId = _groupInfo.groupId;
      temp.conversationType = ConversationType_GROUP;
      temp.userName = _groupInfo.groupName;
      temp.title = _groupInfo.groupName;
      [self.navigationController pushViewController:temp animated:YES];
    }
  } else {

    RCDChatViewController *temp = [[RCDChatViewController alloc] init];
    temp.targetId = _groupInfo.groupId;
    temp.conversationType = ConversationType_GROUP;
    temp.userName = _groupInfo.groupName;
    temp.title = _groupInfo.groupName;
    [self.navigationController pushViewController:temp animated:YES];
  }
}

- (IBAction)setIsMessageDistruble:(id)sender {
  UISwitch *isDistruble = (UISwitch *)sender;
  [[RCIMClient sharedRCIMClient]
      setConversationNotificationStatus:ConversationType_GROUP
      targetId:_groupInfo.groupId
      isBlocked:!isDistruble.isOn
      success:^(RCConversationNotificationStatus nStatus) {

      }
      error:^(RCErrorCode status){

      }];
}

- (IBAction)setConversationTop:(id)sender {
  UISwitch *isTop = (UISwitch *)sender;
  RCConversation *conversation =
      [[RCIMClient sharedRCIMClient] getConversation:ConversationType_GROUP
                                            targetId:_groupInfo.groupId];
  if (conversation) {
    [[RCIMClient sharedRCIMClient] setConversationToTop:ConversationType_GROUP
                                               targetId:_groupInfo.groupId
                                                  isTop:isTop.isOn];
  }
}

- (IBAction)clearMessage:(id)sender {
  UIActionSheet *actionSheet =
      [[UIActionSheet alloc] initWithTitle:@"确定删除聊天记录？"
                                  delegate:self
                         cancelButtonTitle:@"取消"
                    destructiveButtonTitle:@"确定"
                         otherButtonTitles:nil];
  actionSheet.tag = 100;
  [actionSheet showInView:self.view];
}

#pragma mark -UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  int groupId = [_groupInfo.groupId intValue];
  if (actionSheet.tag == 100) {
    if (buttonIndex == 0) {
      BOOL isClear =
          [[RCIMClient sharedRCIMClient] clearMessages:ConversationType_GROUP
                                              targetId:_groupInfo.groupId];
      //清除消息之后回调操作，例如reload 会话列表
      if (self.clearHistoryCompletion) {
        self.clearHistoryCompletion(isClear);
      }
    }
  } else {
    if (buttonIndex == 0) {
      [RCDHTTPTOOL
          quitGroup:groupId
           complete:^(BOOL isOk) {
             dispatch_async(dispatch_get_main_queue(), ^{
               if (isOk) {
                 _groupInfo.isJoin = NO;
                 UIImage *image = [UIImage imageNamed:@"group_add"];
                 image = [image
                     stretchableImageWithLeftCapWidth:floorf(image.size.width /
                                                             2)
                                         topCapHeight:floorf(image.size.height /
                                                             2)];
                 [_btJoinOrQuitGroup setTitle:@"加入"
                                     forState:UIControlStateNormal];
                 [_btJoinOrQuitGroup setBackgroundImage:image
                                               forState:UIControlStateNormal];
                 [RCDDataSource syncGroups];
                 [self.messageDisTrubleCell setHidden:YES];
                 [self.clearMessageCell setHidden:YES];
                 [self.messageTopCell setHidden:YES];

                 [_btChat setHidden:YES];
               } else {
                 UIAlertView *alertView =
                     [[UIAlertView alloc] initWithTitle:nil
                                                message:@"退出失败！"
                                               delegate:nil
                                      cancelButtonTitle:@"确定"
                                      otherButtonTitles:nil, nil];
                 [alertView show];
               }
             });
           }];
    }
  }
}

@end
