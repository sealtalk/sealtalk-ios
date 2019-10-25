//
//  RCDChatViewController+RealTimeLocation.m
//  SealTalk
//
//  Created by Sin on 2019/5/31.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDChatViewController+RealTimeLocation.h"
#import <objc/runtime.h>
#import "RealTimeLocationEndCell.h"
#import "RealTimeLocationStartCell.h"
#import "RealTimeLocationStatusView.h"
#import "RealTimeLocationViewController.h"

static const char *kRealTimeLocationKey = "kRealTimeLocationKey";
static const char *kRealTimeLocationStatusViewKey = "kRealTimeLocationStatusViewKey";

@implementation RCDChatViewController (RCDChatViewController)
- (void)initRealTimeLocationStatusView {
    self.realTimeLocationStatusView =
        [[RealTimeLocationStatusView alloc] initWithFrame:CGRectMake(0, 62, self.view.frame.size.width, 0)];
    self.realTimeLocationStatusView.delegate = self;
    [self.view addSubview:self.realTimeLocationStatusView];
}
- (void)registerRealTimeLocationCell {
    [self initRealTimeLocationStatusView];
    [self registerClass:[RealTimeLocationStartCell class] forMessageClass:[RCRealTimeLocationStartMessage class]];
    [self registerClass:[RealTimeLocationEndCell class] forMessageClass:[RCRealTimeLocationEndMessage class]];
}
- (void)getRealTimeLocationProxy {
    __weak typeof(self) weakSelf = self;
    [[RCRealTimeLocationManager sharedManager] getRealTimeLocationProxy:self.conversationType
        targetId:self.targetId
        success:^(id<RCRealTimeLocationProxy> realTimeLocation) {
            weakSelf.realTimeLocation = realTimeLocation;
            [weakSelf.realTimeLocation addRealTimeLocationObserver:weakSelf];
            [weakSelf updateRealTimeLocationStatus];
        }
        error:^(RCRealTimeLocationErrorCode status) {
            NSLog(@"get location share failure with code %d", (int)status);
        }];
}

/******************消息多选功能:转发、删除**********************/
#pragma mark - *************实时位置共享*************
#pragma mark - RCRealTimeLocationObserver
- (void)onRealTimeLocationStatusChange:(RCRealTimeLocationStatus)status {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf updateRealTimeLocationStatus];
    });
}

- (void)onReceiveLocation:(CLLocation *)location type:(RCRealTimeLocationType)type fromUserId:(NSString *)userId {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf updateRealTimeLocationStatus];
    });
}

- (void)onParticipantsJoin:(NSString *)userId {
    __weak typeof(self) weakSelf = self;
    if ([userId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        [self notifyParticipantChange:RCDLocalizedString(@"you_join_location_share")];
    } else {
        [[RCIM sharedRCIM]
                .userInfoDataSource
            getUserInfoWithUserId:userId
                       completion:^(RCUserInfo *userInfo) {
                           if (userInfo.name.length) {
                               [weakSelf
                                   notifyParticipantChange:[NSString
                                                               stringWithFormat:RCDLocalizedString(
                                                                                    @"someone_join_share_location"),
                                                                                userInfo.name]];
                           } else {
                               [weakSelf
                                   notifyParticipantChange:[NSString stringWithFormat:RCDLocalizedString(
                                                                                          @"user_join_share_location"),
                                                                                      userId]];
                           }
                       }];
    }
}

- (void)onParticipantsQuit:(NSString *)userId {
    __weak typeof(self) weakSelf = self;
    if ([userId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        [self notifyParticipantChange:RCDLocalizedString(@"you_quit_location_share")];
    } else {
        [[RCIM sharedRCIM]
                .userInfoDataSource
            getUserInfoWithUserId:userId
                       completion:^(RCUserInfo *userInfo) {
                           if (userInfo.name.length) {
                               [weakSelf
                                   notifyParticipantChange:[NSString
                                                               stringWithFormat:RCDLocalizedString(
                                                                                    @"someone_quit_location_share"),
                                                                                userInfo.name]];
                           } else {
                               [weakSelf
                                   notifyParticipantChange:[NSString stringWithFormat:RCDLocalizedString(
                                                                                          @"user_quit_location_share"),
                                                                                      userId]];
                           }
                       }];
    }
}

- (void)onRealTimeLocationStartFailed:(long)messageId {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i < self.conversationDataRepository.count; i++) {
            RCMessageModel *model = [self.conversationDataRepository objectAtIndex:i];
            if (model.messageId == messageId) {
                model.sentStatus = SentStatus_FAILED;
            }
        }
        NSArray *visibleItem = [self.conversationMessageCollectionView indexPathsForVisibleItems];
        for (int i = 0; i < visibleItem.count; i++) {
            NSIndexPath *indexPath = visibleItem[i];
            RCMessageModel *model = [self.conversationDataRepository objectAtIndex:indexPath.row];
            if (model.messageId == messageId) {
                [self.conversationMessageCollectionView reloadItemsAtIndexPaths:@[ indexPath ]];
            }
        }
    });
}

- (void)notifyParticipantChange:(NSString *)text {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.realTimeLocationStatusView updateText:text];
        [weakSelf performSelector:@selector(updateRealTimeLocationStatus) withObject:nil afterDelay:0.5];
    });
}

- (void)onFailUpdateLocation:(NSString *)description {
}

#pragma mark - RealTimeLocationStatusViewDelegate
- (void)onJoin {
    [self showRealTimeLocationViewController];
}
- (RCRealTimeLocationStatus)getStatus {
    return [self.realTimeLocation getStatus];
}

- (void)onShowRealTimeLocationView {
    [self showRealTimeLocationViewController];
}

#pragma mark - RealTimeLocation helper
- (void)showRealTimeLocationViewController {
    RealTimeLocationViewController *lsvc = [[RealTimeLocationViewController alloc] init];
    lsvc.realTimeLocationProxy = self.realTimeLocation;
    if ([self.realTimeLocation getStatus] == RC_REAL_TIME_LOCATION_STATUS_INCOMING) {
        [self.realTimeLocation joinRealTimeLocation];
    } else if ([self.realTimeLocation getStatus] == RC_REAL_TIME_LOCATION_STATUS_IDLE) {
        [self.realTimeLocation startRealTimeLocation];
    }
    lsvc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:lsvc
                                            animated:YES
                                          completion:^{

                                          }];
}

- (void)updateRealTimeLocationStatus {
    if (self.realTimeLocation) {
        [self.realTimeLocationStatusView updateRealTimeLocationStatus];
        __weak typeof(self) weakSelf = self;
        NSArray *participants = nil;
        switch ([self.realTimeLocation getStatus]) {
        case RC_REAL_TIME_LOCATION_STATUS_OUTGOING:
            [self.realTimeLocationStatusView updateText:RCDLocalizedString(@"you_location_sharing")];
            break;
        case RC_REAL_TIME_LOCATION_STATUS_CONNECTED:
        case RC_REAL_TIME_LOCATION_STATUS_INCOMING:
            participants = [self.realTimeLocation getParticipants];
            if (participants.count == 1) {
                NSString *userId = participants[0];
                [weakSelf.realTimeLocationStatusView
                    updateText:[NSString stringWithFormat:RCDLocalizedString(@"user_location_sharing"), userId]];
                [[RCIM sharedRCIM]
                        .userInfoDataSource
                    getUserInfoWithUserId:userId
                               completion:^(RCUserInfo *userInfo) {
                                   if (userInfo.name.length) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [weakSelf.realTimeLocationStatusView
                                               updateText:[NSString stringWithFormat:RCDLocalizedString(
                                                                                         @"someone_location_sharing"),
                                                                                     userInfo.name]];
                                       });
                                   }
                               }];
            } else {
                if (participants.count < 1)
                    [self.realTimeLocationStatusView removeFromSuperview];
                else
                    [self.realTimeLocationStatusView
                        updateText:[NSString stringWithFormat:@"%d人正在共享地理位置", (int)participants.count]];
            }
            break;
        default:
            break;
        }
    }
}

#pragma mark - getter
- (void)setRealTimeLocation:(id<RCRealTimeLocationProxy>)realTimeLocation {
    objc_setAssociatedObject(self, kRealTimeLocationKey, realTimeLocation, OBJC_ASSOCIATION_ASSIGN);
}

- (id<RCRealTimeLocationProxy>)realTimeLocation {
    return objc_getAssociatedObject(self, kRealTimeLocationKey);
}

- (void)setRealTimeLocationStatusView:(RealTimeLocationStatusView *)realTimeLocationStatusView {
    objc_setAssociatedObject(self, kRealTimeLocationStatusViewKey, realTimeLocationStatusView,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (RealTimeLocationStatusView *)realTimeLocationStatusView {
    return objc_getAssociatedObject(self, kRealTimeLocationStatusViewKey);
}
@end
