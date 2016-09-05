//
//  RCWKUtility.m
//  RongIMWatchKit
//
//  Created by litao on 15/4/30.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCWKUtility.h"
#import "RCAppInfoModel.h"

@implementation RCWKUtility
+ (NSString *)formatDiscussionNotificationMessageContent:
    (RCDiscussionNotificationMessage *)discussionNotification {
  if (nil == discussionNotification) {
    return nil;
  }
  NSArray *operatedIds = nil;
  NSString *operationInfo = nil;

  //[RCKitUtility sharedInstance].discussionNotificationOperatorName =
  //userInfo.name;
  switch (discussionNotification.type) {
  case RCInviteDiscussionNotification:
  case RCRemoveDiscussionMemberNotification: {
    NSString *trimedExtension = [discussionNotification.extension
        stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *ids = [trimedExtension componentsSeparatedByString:@","];
    if (!ids || ids.count == 0) {
      ids = [NSArray arrayWithObject:trimedExtension];
    }
    operatedIds = ids;
  } break;
  case RCQuitDiscussionNotification:
    break;

  case RCRenameDiscussionTitleNotification:
  case RCSwichInvitationAccessNotification:
    operationInfo = discussionNotification.extension;
    break;

  default:
    break;
  }

  NSString *format = nil;
  NSString *message = nil;
  NSString *target = nil;
  if (operatedIds) {
    if (operatedIds.count == 1) {
      RCUserInfo *userInfo = [RCAppInfoModel getUserInfoById:operatedIds[0]];
      if ([userInfo.name length]) {
        target = userInfo.name;
      } else {
        target = [[NSString alloc] initWithFormat:@"user<%@>", operatedIds[0]];
      }

    } else {
      target = [NSString stringWithFormat:NSLocalizedString(@"%d位成员", nil),
                                          operatedIds.count, nil];
    }
  }

  NSString *operator;
  RCUserInfo *userInfo =
      [RCAppInfoModel getUserInfoById:discussionNotification.operatorId];
  if ([userInfo.name length]) {
    operator= userInfo.name;
  } else {
    operator= [[NSString alloc]
        initWithFormat:@"user<%@>", discussionNotification.operatorId];
  }

  switch (discussionNotification.type) {
  case RCInviteDiscussionNotification: {
    format = NSLocalizedString(@"%@邀请%@加入了讨论组", nil);
            message = [NSString stringWithFormat:format, operator, target, nil];
  } break;
  case RCQuitDiscussionNotification: {
    format = NSLocalizedString(@"%@退出了讨论组", nil);
            message = [NSString stringWithFormat:format, operator, nil];
  } break;

  case RCRemoveDiscussionMemberNotification: {
    format = NSLocalizedString(@"%@被%@移出了讨论组", nil);
            message = [NSString stringWithFormat:format, target, operator,nil];
  } break;
  case RCRenameDiscussionTitleNotification: {
    format = NSLocalizedString(@"%@修改讨论组为\"%@\"", nil);
    target = operationInfo;
            message = [NSString stringWithFormat:format, operator, target, nil];
  } break;
  case RCSwichInvitationAccessNotification: {
    // 1 for off, 0 for on
    BOOL canInvite = [operationInfo isEqualToString:@"1"] ? NO : YES;
    target = canInvite ? NSLocalizedString(@"开启", nil)
                       : NSLocalizedString(@"关闭", nil);
    format = NSLocalizedString(@"%@%@了成员邀请", nil);
    message =
        [NSString stringWithFormat:format, discussionNotification.operatorId,
                                   target, nil];
  }
  default:
    break;
  }
  return message;
}
@end
