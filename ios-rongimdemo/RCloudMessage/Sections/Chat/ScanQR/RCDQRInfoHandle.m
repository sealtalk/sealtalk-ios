//
//  RCDQRInfoHandle.m
//  SealTalk
//
//  Created by 张改红 on 2019/7/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDQRInfoHandle.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDGroupJoinController.h"
#import "RCDGroupManager.h"
#import "RCDChatViewController.h"
#import "RCDUserInfoManager.h"
#import "RCDPersonDetailViewController.h"
#import "RCDAddFriendViewController.h"
@interface RCDQRInfoHandle ()
@property (nonatomic, strong) UIViewController *baseController;
@end
@implementation RCDQRInfoHandle
- (void)identifyQRCode:(NSString *)info base:(UIViewController *)viewController {
    self.baseController = viewController;
    if (info) {
        if ([info containsString:@"key=sealtalk://group/join?"]) {
            NSArray *array = [info componentsSeparatedByString:@"key=sealtalk://group/join?"];
            if (array.count >= 2) {
                NSArray *arr = [array[1] componentsSeparatedByString:@"&"];
                if (arr.count >= 2) {
                    NSString *gIdStr = arr[0];
                    NSString *uIdStr = arr[1];
                    if ([gIdStr hasPrefix:@"g="] && gIdStr.length > 2) {
                        gIdStr = [gIdStr substringWithRange:NSMakeRange(2, gIdStr.length - 2)];
                    }
                    if ([uIdStr hasPrefix:@"u="] && uIdStr.length > 2) {
                        uIdStr = [uIdStr substringWithRange:NSMakeRange(2, uIdStr.length - 2)];
                    }
                    if (gIdStr.length > 0) {
                        [self handleGroupInfo:gIdStr];
                    }
                }
            }
        } else if ([info containsString:@"key=sealtalk://user/info?"]) {
            NSArray *array = [info componentsSeparatedByString:@"key=sealtalk://user/info?"];
            if (array.count >= 2) {
                NSString *uIdStr = array[1];
                if ([uIdStr hasPrefix:@"u="] && uIdStr.length > 2) {
                    uIdStr = [uIdStr substringWithRange:NSMakeRange(2, uIdStr.length - 2)];
                }
                if (uIdStr.length > 0) {
                    [self handleUserInfo:uIdStr];
                }
            }
        } else if ([info hasPrefix:@"http"]) {
            [RCKitUtility openURLInSafariViewOrWebView:info base:viewController];
        } else {
            [self showAlert:RCDLocalizedString(@"QRIdentifyError")];
        }
    } else {
        [self showAlert:RCDLocalizedString(@"QRIdentifyError")];
    }
}

#pragma mark - helper
- (void)handleUserInfo:(NSString *)userId {
    UIViewController *vc = [RCDPersonDetailViewController configVC:userId groupId:nil];
    [self.baseController.navigationController pushViewController:vc animated:YES];
}

- (void)handleGroupInfo:(NSString *)groupId {
    [RCDGroupManager
        getGroupInfoFromServer:groupId
                      complete:^(RCDGroupInfo *_Nonnull groupInfo) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              if (groupInfo) {
                                  if (!groupInfo.isDismiss) {
                                      [RCDGroupManager
                                          getGroupMembersFromServer:groupId
                                                           complete:^(NSArray<NSString *> *_Nonnull memberIdList) {
                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                   if ([memberIdList containsObject:[RCIM sharedRCIM]
                                                                                                        .currentUserInfo
                                                                                                        .userId]) {
                                                                       [self pushChatVC:groupId];
                                                                   } else {
                                                                       [self pushGroupJoinVC:groupId];
                                                                   }
                                                               });
                                                           }];
                                  } else {
                                      [self pushGroupJoinVC:groupId];
                                  }
                              } else {
                                  [self showAlert:RCDLocalizedString(@"GroupNoExist")];
                              }
                          });
                      }];
}

- (void)showAlert:(NSString *)alertContent {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:alertContent
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:RCDLocalizedString(@"confirm")
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    [self.baseController presentViewController:alertController animated:YES completion:nil];
}

- (void)pushChatVC:(NSString *)groupId {
    RCDChatViewController *chatVC = [[RCDChatViewController alloc] init];
    chatVC.targetId = groupId;
    chatVC.conversationType = ConversationType_GROUP;
    [self.baseController.navigationController pushViewController:chatVC animated:YES];
}

- (void)pushGroupJoinVC:(NSString *)groupId {
    RCDGroupJoinController *groupJoinVC = [[RCDGroupJoinController alloc] init];
    groupJoinVC.groupId = groupId;
    [self.baseController.navigationController pushViewController:groupJoinVC animated:YES];
}

@end
