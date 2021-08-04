//
//  RCDChatViewController.m
//  RCloudMessage
//
//  Created by Liv on 15/3/13.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDChatViewController.h"
#import "RCDAddFriendViewController.h"
#import "RCDGroupSettingsTableViewController.h"
#import "RCDPersonDetailViewController.h"
#import "RCDPrivateSettingsTableViewController.h"
#import "RCDReceiptDetailsTableViewController.h"
#import "RCDTestMessage.h"
#import "RCDTestMessageCell.h"
#import "RCDUIBarButtonItem.h"
#import "RCDUserInfoManager.h"
#import "RCDUtilities.h"
#import "RCDForwardManager.h"

#import "RCDCommonString.h"
#import "RCDIMService.h"
#import "RCDCustomerEmoticonTab.h"
#import <RongContactCard/RongContactCard.h>
#import "RCDGroupManager.h"
#import "RCDImageSlideController.h"
#import "RCDForwardSelectedViewController.h"
#import "RCDGroupNotificationMessage.h"
#import "RCDChatNotificationMessage.h"
#import "RCDTipMessageCell.h"
#import "RCDChooseUserController.h"
#import "RCDChatManager.h"
#import "RCDPokeAlertView.h"
#import "RCDQuicklySendManager.h"
#import "RCDPokeMessage.h"
#import "RCDPokeMessageCell.h"
#import "RCDRecentPictureViewController.h"
#import "RCDPokeManager.h"
#import "NormalAlertView.h"
#import <Masonry/Masonry.h>
#import "UIView+MBProgressHUD.h"

/*******************实时位置共享***************/
#import <objc/runtime.h>
#import "RealTimeLocationEndCell.h"
#import "RealTimeLocationStartCell.h"
#import "RealTimeLocationStatusView.h"
#import "RealTimeLocationViewController.h"
#import "RealTimeLocationDefine.h"
static const char *kRealTimeLocationKey = "kRealTimeLocationKey";
static const char *kRealTimeLocationStatusViewKey = "kRealTimeLocationStatusViewKey";

#define PLUGIN_BOARD_ITEM_POKE_TAG 20000

@interface RCChatSessionInputBarControl ()
@property (nonatomic, assign) BOOL burnMessageMode;
@end
;

@interface RCDChatViewController () <RCMessageCellDelegate, RCDQuicklySendManagerDelegate, UIGestureRecognizerDelegate,
                                     RealTimeLocationStatusViewDelegate, RCRealTimeLocationObserver>
@property (nonatomic, strong) RCDGroupInfo *groupInfo;
@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, assign) BOOL loading;

/*******************实时位置共享***************/
@property (nonatomic, weak) id<RCRealTimeLocationProxy> realTimeLocation;
@property (nonatomic, strong) RealTimeLocationStatusView *realTimeLocationStatusView;
@end

@implementation RCDChatViewController

#pragma mark - life cycle
- (instancetype)init {
    self = [super init];
    int defalutHistoryMessageCount = (int)[DEFAULTS integerForKey:RCDChatroomDefalutHistoryMessageCountKey];
    if (defalutHistoryMessageCount >= -1 && defalutHistoryMessageCount <= 50) {
        self.defaultHistoryMessageCountOfChatRoom = defalutHistoryMessageCount;
    }
    return self;
}

- (id)initWithConversationType:(RCConversationType)conversationType targetId:(NSString *)targetId {
    self = [super initWithConversationType:conversationType targetId:targetId];
    int defalutHistoryMessageCount = (int)[DEFAULTS integerForKey:RCDChatroomDefalutHistoryMessageCountKey];
    if (defalutHistoryMessageCount >= -1 && defalutHistoryMessageCount <= 50) {
        self.defaultHistoryMessageCountOfChatRoom = defalutHistoryMessageCount;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    self.loading = NO;

    ///注册自定义测试消息Cell
    [self registerClass:[RCDTestMessageCell class] forMessageClass:[RCDTestMessage class]];
    [self registerClass:RCDTipMessageCell.class forMessageClass:RCDGroupNotificationMessage.class];
    [self registerClass:RCDTipMessageCell.class forMessageClass:RCDChatNotificationMessage.class];
    [self registerClass:RCDPokeMessageCell.class forMessageClass:RCDPokeMessage.class];
    self.enableSaveNewPhotoToLocalSystem = YES;
    [self notifyUpdateUnreadMessageCount];
    [self addOtherPluginBoard];

    [self refreshUserInfoOrGroupInfo];
    [self addNotifications];
    //    [self addToolbarItems];
    /*******************实时位置共享***************/
    [self registerRealTimeLocationCell];
    [self getRealTimeLocationProxy];
    /******************实时位置共享**************/

    //    self.enableContinuousReadUnreadVoice = YES;//开启语音连读功能

    [self handleChatSessionInputBarControlDemo];
    [self insertMessageDemo];
    [self addEmoticonTabDemo];
    [self addQuicklySendImage];
    [self setupChatBackground];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.defaultInputType = [[RCDIMService sharedService] getInputStatus:self.conversationType targetId:self.targetId];
    [self refreshTitle];
    self.isShow = YES;
    RCConversation *conver = [[RCConversation alloc] init];
    conver.conversationType = self.conversationType;
    conver.targetId = self.targetId;
    [RCDPokeManager sharedInstance].currentConversation = conver;
    //    [self.chatSessionInputBarControl updateStatus:self.chatSessionInputBarControl.currentBottomBarStatus
    //    animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self resetQucilySendView];
    self.isShow = NO;
    [RCDPokeManager sharedInstance].currentConversation = nil;
    NSArray *viewControllers = self.navigationController.viewControllers; //获取当前的视图控制其
    if ([viewControllers indexOfObject:self] == NSNotFound) {
        //当前视图控制器不在栈中，故为pop操作
        [self.realTimeLocation removeRealTimeLocationObserver:self];
        self.realTimeLocation = nil;
    }

    KBottomBarStatus inputType = self.chatSessionInputBarControl.currentBottomBarStatus;
    if (self.chatSessionInputBarControl.burnMessageMode) {
        inputType = KBottomBarBurnStatus;
    }
    [[RCDIMService sharedService] saveInputStatus:self.conversationType targetId:self.targetId inputType:inputType];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {

    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    }
        completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            [self updateSubviews:size];
        }];
}

- (void)updateSubviews:(CGSize)size {
    CGRect frame = self.realTimeLocationStatusView.frame;
    frame.size.width = self.view.bounds.size.width;
    self.realTimeLocationStatusView.frame = frame;
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    [super willMoveToParentViewController:parent];
    if (!parent) {
        [self.realTimeLocation quitRealTimeLocation];
    }
}

- (void)dealloc {
    NSLog(@"%s", __func__);
    [self.conversationMessageCollectionView removeObserver:self forKeyPath:@"frame"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - RCMessageCellDelegate
- (void)didTapReceiptCountView:(RCMessageModel *)model {
    if ([model.content isKindOfClass:[RCTextMessage class]]) {
        RCDReceiptDetailsTableViewController *vc = [[RCDReceiptDetailsTableViewController alloc] init];
        vc.message = model;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)inputTextView:(UITextView *)inputTextView
    shouldChangeTextInRange:(NSRange)range
            replacementText:(NSString *)text {
    [super inputTextView:inputTextView shouldChangeTextInRange:range replacementText:text];
    [self resetQucilySendView];
}

#pragma mark - RCDQuicklySendManagerDelegate
- (void)quicklySendViewDidTapImage:(UIImage *)image {
    RCDRecentPictureViewController *vc = [[RCDRecentPictureViewController alloc] init];
    vc.image = image;
    __weak typeof(self) weakSelf = self;
    vc.sendBlock = ^(BOOL isFull) {
        RCImageMessage *imageMsg = [RCImageMessage messageWithImage:image];
        imageMsg.full = isFull;
        [weakSelf sendMessage:imageMsg pushContent:nil];
    };
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    [self resetQucilySendView];
    return YES;
}

#pragma mark - over methods
- (void)didTapMessageCell:(RCMessageModel *)model {
    [super didTapMessageCell:model];
    //点击实时位置共享消息 cell 处理
    if ([model.content isKindOfClass:[RCRealTimeLocationStartMessage class]]) {
        [self showRealTimeLocationViewController];
    }

    if ([model.content isKindOfClass:[RCContactCardMessage class]]) {
        RCContactCardMessage *cardMSg = (RCContactCardMessage *)model.content;
        RCDUserInfo *user =
            [[RCDUserInfo alloc] initWithUserId:cardMSg.userId name:cardMSg.name portrait:cardMSg.portraitUri];
        [self pushPersonDetailVC:user];
    }
}

- (NSArray<UIMenuItem *> *)getLongTouchMessageCellMenuList:(RCMessageModel *)model {
    NSArray<UIMenuItem *> *menuList = [[super getLongTouchMessageCellMenuList:model] mutableCopy];
    /*
     在这里添加删除菜单。
     [menuList enumerateObjectsUsingBlock:^(UIMenuItem * _Nonnull obj, NSUInteger
     idx, BOOL * _Nonnull stop) {
     if ([obj.title isEqualToString:@"删除"] || [obj.title
     isEqualToString:@"delete"]) {
     [menuList removeObjectAtIndex:idx];
     *stop = YES;
     }
     }];

     UIMenuItem *forwardItem = [[UIMenuItem alloc] initWithTitle:@"转发"
     action:@selector(onForwardMessage:)];
     [menuList addObject:forwardItem];

     如果您不需要修改，不用重写此方法，或者直接return［super
     getLongTouchMessageCellMenuList:model]。
     */
    NSMutableArray *list = menuList.mutableCopy;
    //戳一下消息不能撤回
    if ([[[model.content class] getObjectName] isEqualToString:RCDPokeMessageTypeIdentifier]) {
        for (UIMenuItem *item in menuList) {
            if ([item.title isEqualToString:NSLocalizedStringFromTable(@"Recall", @"RongCloudKit", nil)]) {
                if ([list containsObject:item]) {
                    [list removeObject:item];
                }
            }
        }
    }
    return list.copy;
}

- (void)didTapCellPortrait:(NSString *)userId {
    if (self.conversationType == ConversationType_GROUP || self.conversationType == ConversationType_PRIVATE ||
        self.conversationType == ConversationType_CHATROOM) {
        __weak typeof(self) weakSelf = self;
        [RCDUserInfoManager getUserInfoFromServer:userId
                                         complete:^(RCDUserInfo *userInfo) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [weakSelf pushPersonDetailVC:userInfo];
                                             });
                                         }];
    }
}

- (void)resendMessage:(RCMessageContent *)messageContent {
    if ([messageContent isKindOfClass:[RCRealTimeLocationStartMessage class]]) {
        [self showRealTimeLocationViewController];
    } else {
        [super resendMessage:messageContent];
    }
}

- (RCMessageContent *)willSendMessage:(RCMessageContent *)messageContent {
    //可以在这里修改将要发送的消息
    if ([messageContent isMemberOfClass:[RCTextMessage class]]) {
        // RCTextMessage *textMsg = (RCTextMessage *)messageContent;
        // textMsg.extra = @"";
    }
    if (messageContent.mentionedInfo && messageContent.mentionedInfo.userIdList) {
        for (int i = 0; i < messageContent.mentionedInfo.userIdList.count; i++) {
            NSString *userId = messageContent.mentionedInfo.userIdList[i];
            if ([userId isEqualToString:RCDMetionAllUsetId]) {
                messageContent.mentionedInfo.type = RC_Mentioned_All;
                messageContent.mentionedInfo.userIdList = nil;
                break;
            }
        }
    }
    return messageContent;
}

/**
 *  打开大图。开发者可以重写，自己下载并且展示图片。默认使用内置controller
 *
 *  @param imageMessageContent 图片消息内容
 */
- (void)presentImagePreviewController:(RCMessageModel *)model {
    RCDImageSlideController *previewController = [[RCDImageSlideController alloc] init];
    previewController.messageModel = model;

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:previewController];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)didLongTouchMessageCell:(RCMessageModel *)model inView:(UIView *)view {
    [super didLongTouchMessageCell:model inView:view];
    NSLog(@"%s", __FUNCTION__);
}

- (void)didLongPressCellPortrait:(NSString *)userId {
    if (self.conversationType != ConversationType_GROUP ||
        [userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
        return;
    }
    RCUserInfo *userInfo = [RCDUserInfoManager getUserInfo:userId];
    RCDGroupMember *memberDetail = [RCDGroupManager getGroupMember:userId groupId:self.targetId];
    if (memberDetail.groupNickname.length > 0) {
        userInfo.name = memberDetail.groupNickname;
    }
    [self.chatSessionInputBarControl addMentionedUser:userInfo];
    [self.chatSessionInputBarControl.inputTextView becomeFirstResponder];
}

- (RCMessage *)willAppendAndDisplayMessage:(RCMessage *)message {
    if ([message.content isKindOfClass:[RCDGroupNotificationMessage class]]) {
        RCDGroupNotificationMessage *groupNotif = (RCDGroupNotificationMessage *)message.content;
        if ([groupNotif.operation isEqualToString:RCDGroupMemberManagerRemove]) {
            return nil;
        }
    }
    return message;
}

- (void)pluginBoardView:(RCPluginBoardView *)pluginBoardView clickedItemWithTag:(NSInteger)tag {
    [self resetQucilySendView];
    switch (tag) {
    case PLUGIN_BOARD_ITEM_LOCATION_TAG: {
        if (self.realTimeLocation) {
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:RTLLocalizedString(@"cancel")
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:nil];
            UIAlertAction *sendLocationAction =
                [UIAlertAction actionWithTitle:RTLLocalizedString(@"send_location")
                                         style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *_Nonnull action) {
                                           [super pluginBoardView:self.chatSessionInputBarControl.pluginBoardView
                                               clickedItemWithTag:PLUGIN_BOARD_ITEM_LOCATION_TAG];
                                       }];
            UIAlertAction *locationShareAction = [UIAlertAction actionWithTitle:RTLLocalizedString(@"location_share")
                                                                          style:UIAlertActionStyleDefault
                                                                        handler:^(UIAlertAction *_Nonnull action) {
                                                                            [self showRealTimeLocationViewController];
                                                                        }];

            [RCKitUtility showAlertController:nil
                                      message:nil
                               preferredStyle:UIAlertControllerStyleActionSheet
                                      actions:@[ cancelAction, sendLocationAction, locationShareAction ]
                             inViewController:self];
        } else {
            [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
        }
    } break;
    case PLUGIN_BOARD_ITEM_POKE_TAG: {
        if (self.conversationType == ConversationType_GROUP) {
            RCDGroupMember *member =
                [RCDGroupManager getGroupMember:[RCIM sharedRCIM].currentUserInfo.userId groupId:self.targetId];
            if (member) {
                if (member.role == RCDGroupMemberRoleMember) {
                    [NormalAlertView showAlertWithTitle:nil
                                                message:RCDLocalizedString(@"Only_group_owner_and_manager_can_manage")
                                          describeTitle:nil
                                           confirmTitle:RCDLocalizedString(@"confirm")
                                                confirm:^{
                                                }];
                } else {
                    [RCDPokeAlertView showPokeAlertView:self.conversationType
                                               targetId:self.targetId
                                       inViewController:self];
                }
            } else {
                [RCDGroupManager
                    getGroupMembersFromServer:self.targetId
                                     complete:^(NSArray<NSString *> *memberIdList) {
                                         if (memberIdList) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 RCDGroupMember *member = [RCDGroupManager
                                                     getGroupMember:[RCIM sharedRCIM].currentUserInfo.userId
                                                            groupId:self.targetId];
                                                 if (member.role == RCDGroupMemberRoleMember) {
                                                     [NormalAlertView
                                                         showAlertWithTitle:nil
                                                                    message:
                                                                        RCDLocalizedString(
                                                                            @"Only_group_owner_and_manager_can_manage")
                                                              describeTitle:nil
                                                               confirmTitle:RCDLocalizedString(@"confirm")
                                                                    confirm:^{
                                                                    }];
                                                 } else {
                                                     [RCDPokeAlertView showPokeAlertView:self.conversationType
                                                                                targetId:self.targetId
                                                                        inViewController:self];
                                                 }
                                             });
                                         }
                                     }];
            }
        } else if (self.conversationType == ConversationType_PRIVATE) {
            [RCDPokeAlertView showPokeAlertView:self.conversationType targetId:self.targetId inViewController:self];
        }
    } break;
    default:
        [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
        break;
    }
}

/**
 *  更新左上角未读消息数
 */
- (void)notifyUpdateUnreadMessageCount {
    if (self.allowsMessageCellSelection) {
        [super notifyUpdateUnreadMessageCount];
        return;
    }
    rcd_dispatch_main_async_safe(^{
        [self setLeftNavigationItem];
        [self setRightNavigationItems];
    });
}

- (void)saveNewPhotoToLocalSystemAfterSendingSuccess:(UIImage *)newImage {
    //保存图片
    UIImage *image = newImage;
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)showChooseUserViewController:(void (^)(RCUserInfo *selectedUserInfo))selectedBlock
                              cancel:(void (^)(void))cancelBlock {
    RCDChooseUserController *userListVC = [[RCDChooseUserController alloc] initWithGroupId:self.targetId];
    userListVC.selectedBlock = selectedBlock;
    userListVC.cancelBlock = cancelBlock;
    UINavigationController *rootVC = [[UINavigationController alloc] initWithRootViewController:userListVC];
    rootVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:rootVC animated:YES completion:nil];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCMessageModel *model = [self.conversationDataRepository objectAtIndex:indexPath.row];
    if ([model.content isKindOfClass:[RCDGroupNotificationMessage class]]) {
        RCDGroupNotificationMessage *groupNotif = (RCDGroupNotificationMessage *)model.content;
        if ([groupNotif.operation isEqualToString:RCDGroupMemberManagerRemove]) {
            [[RCIMClient sharedRCIMClient] deleteMessages:@[ @(model.messageId) ]];
            return CGSizeZero;
        }
    }
    return [super collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
}
#pragma mark - target action
/**
 *  此处使用自定义设置，开发者可以根据需求自己实现
 *  不添加rightBarButtonItemClicked事件，则使用默认实现。
 */
- (void)rightBarButtonItemClicked:(id)sender {
    if (self.conversationType == ConversationType_PRIVATE) {
        RCDFriendInfo *friendInfo = [RCDUserInfoManager getFriendInfo:self.targetId];
        if (friendInfo && friendInfo.status != RCDFriendStatusAgree && friendInfo.status != RCDFriendStatusBlock) {
            [self pushFriendVC:friendInfo];
        } else {
            RCDPrivateSettingsTableViewController *settingsVC = [[RCDPrivateSettingsTableViewController alloc] init];
            settingsVC.userId = self.targetId;
            __weak typeof(self) weakSelf = self;
            [settingsVC setClearMessageHistory:^{
                
                [weakSelf clearHistoryMSG];
            }];
            [self.navigationController pushViewController:settingsVC animated:YES];
        }
    }
    //群组设置
    else if (self.conversationType == ConversationType_GROUP) {
        RCDGroupSettingsTableViewController *settingsVC = [[RCDGroupSettingsTableViewController alloc] init];
        if (_groupInfo == nil) {
            settingsVC.group = [RCDGroupManager getGroupInfo:self.targetId];
        } else {
            settingsVC.group = self.groupInfo;
        }
        __weak typeof(self) weakSelf = self;
        [settingsVC setClearMessageHistory:^{
            [weakSelf clearHistoryMSG];
        }];
        [self.navigationController pushViewController:settingsVC animated:YES];
    }
    //客服设置
    else if (self.conversationType == ConversationType_CUSTOMERSERVICE ||
             self.conversationType == ConversationType_SYSTEM) {
        RCSettingViewController *settingVC = [[RCSettingViewController alloc] init];
        settingVC.conversationType = self.conversationType;
        settingVC.targetId = self.targetId;
        //清除聊天记录之后reload data
        __weak RCDChatViewController *weakSelf = self;
        settingVC.clearHistoryCompletion = ^(BOOL isSuccess) {
            if (isSuccess) {
                [weakSelf.conversationDataRepository removeAllObjects];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.conversationMessageCollectionView reloadData];
                });
            }
        };
        [self.navigationController pushViewController:settingVC animated:YES];
    } else if (ConversationType_APPSERVICE == self.conversationType ||
               ConversationType_PUBLICSERVICE == self.conversationType) {
        RCPublicServiceProfile *serviceProfile =
            [[RCIMClient sharedRCIMClient] getPublicServiceProfile:(RCPublicServiceType)self.conversationType
                                                   publicServiceId:self.targetId];

        RCPublicServiceProfileViewController *infoVC = [[RCPublicServiceProfileViewController alloc] init];
        infoVC.serviceProfile = serviceProfile;
        infoVC.fromConversation = YES;
        [self.navigationController pushViewController:infoVC animated:YES];
    }
}

/*点击系统键盘的语音按钮，导致输入工具栏被遮挡*/
- (void)keyboardWillShowNotification:(NSNotification *)notification {
    // PokeAlertView 输入内容时，内容直接被输到了输入栏里，所以需要判断PokeAlertView是否展示
    if (!self.chatSessionInputBarControl.inputTextView.isFirstResponder &&
        ![RCDPokeManager sharedInstance].isShowPokeAlert) {
        [self.chatSessionInputBarControl.inputTextView becomeFirstResponder];
    }
}

//和上面的方法相对应，在别的页面弹出键盘导致聊天页面输入状态改变需要及时改变回来
- (void)keyboardWillHideNotification:(NSNotification *)notification {
    if (!self.chatSessionInputBarControl.inputTextView.isFirstResponder) {
        [self.chatSessionInputBarControl.inputTextView resignFirstResponder];
    }
}

- (void)updateForSharedMessageInsertSuccess:(NSNotification *)notification {
    RCMessage *message = notification.object;
    if (message.conversationType == self.conversationType && [message.targetId isEqualToString:self.targetId]) {
        [self appendAndDisplayMessage:message];
    }
}

- (void)updateTitleForGroup:(NSNotification *)notification {
    NSString *groupId = notification.object;
    if ([groupId isEqualToString:self.targetId]) {
        [self refreshTitle];
    }
}

- (void)didGroupMemberUpdateNotification:(NSNotification *)notification {
    NSDictionary *dic = notification.object;
    if ([dic[@"targetId"] isEqualToString:self.targetId]) {
        [self setRightNavigationItems];
    }
}

- (void)leftBarButtonItemPressed:(id)sender {
    if ([self.realTimeLocation getStatus] == RC_REAL_TIME_LOCATION_STATUS_OUTGOING ||
        [self.realTimeLocation getStatus] == RC_REAL_TIME_LOCATION_STATUS_CONNECTED) {
        [self.chatSessionInputBarControl resetToDefaultStatus];
        UIAlertController *alertController =
            [UIAlertController alertControllerWithTitle:nil
                                                message:RTLLocalizedString(@"leave_location_share_when_leave_chat")
                                         preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:RTLLocalizedString(@"cancel")
                                                            style:UIAlertActionStyleDefault
                                                          handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:RTLLocalizedString(@"confirm")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *_Nonnull action) {
                                                              [self.realTimeLocation quitRealTimeLocation];
                                                              [self popupChatViewController];
                                                          }]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [self popupChatViewController];
    }
}

- (void)quicklySendImage:(UIButton *)button {
    CGRect targetFrame =
        CGRectMake(RCDScreenWidth - 108, self.chatSessionInputBarControl.frame.origin.y - 143 - 5, 100, 143);
    [[RCDQuicklySendManager sharedManager] showQuicklySendViewWithframe:targetFrame];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context {
    [self resetQucilySendView];
}

#pragma mark - Demo
- (void)handleChatSessionInputBarControlDemo {
    //    self.chatSessionInputBarControl.hidden = YES;
    //    CGRect intputTextRect = self.conversationMessageCollectionView.frame;
    //    intputTextRect.size.height = intputTextRect.size.height+50;
    //    [self.conversationMessageCollectionView setFrame:intputTextRect];
    //    [self scrollToBottomAnimated:YES];
    /***********如何自定义面板功能***********************
     //     自定义面板功能首先要继承RCConversationViewController，如现在所在的这个文件。
     //     然后在viewDidLoad函数的super函数之后去编辑按钮：
     //     插入到指定位置的方法如下：
     [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:imagePic
     title:title
     atIndex:0
     tag:101];
     删除指定位置的方法：
     [self.chatSessionInputBarControl.pluginBoardView removeItemAtIndex:0];
     删除指定标签的方法：
     [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:101];
     删除所有：
     [self.chatSessionInputBarControl.pluginBoardView removeAllItems];
     更换现有扩展项的图标和标题:
     [self.chatSessionInputBarControl.pluginBoardView updateItemAtIndex:0 image:newImage title:newTitle];
     或者根据tag来更换
     [self.chatSessionInputBarControl.pluginBoardView updateItemWithTag:101 image:newImage title:newTitle];
     以上所有的接口都在RCPluginBoardView.h可以查到。

     当编辑完扩展功能后，下一步就是要实现对扩展功能事件的处理，放开被注掉的函数
     pluginBoardView:clickedItemWithTag:
     在super之后加上自己的处理。

     */

    //默认输入类型为语音
    // self.defaultInputType = RCChatSessionInputBarInputExtention;
    if ([self.targetId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:PLUGIN_BOARD_ITEM_VOIP_TAG];
        [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:PLUGIN_BOARD_ITEM_VIDEO_VOIP_TAG];
    }
}

- (void)insertMessageDemo {
    /***********如何在会话页面插入提醒消息***********************

     RCInformationNotificationMessage *warningMsg =
     [RCInformationNotificationMessage
     notificationWithMessage:@"请不要轻易给陌生人汇钱！" extra:nil];
     BOOL saveToDB = NO;  //是否保存到数据库中
     RCMessage *savedMsg ;
     if (saveToDB) {
     savedMsg = [[RCIMClient sharedRCIMClient]
     insertOutgoingMessage:self.conversationType targetId:self.targetId
     sentStatus:SentStatus_SENT content:warningMsg];
     } else {
     savedMsg =[[RCMessage alloc] initWithType:self.conversationType
     targetId:self.targetId direction:MessageDirection_SEND messageId:-1
     content:warningMsg];//注意messageId要设置为－1
     }
     [self appendAndDisplayMessage:savedMsg];
     */
}

- (void)addEmoticonTabDemo {
    //  //表情面板添加自定义表情包
    //  UIImage *icon = [RCKitUtility imageNamed:@"emoji_btn_normal"
    //                                  ofBundle:@"RongCloud.bundle"];
    //  RCDCustomerEmoticonTab *emoticonTab1 = [RCDCustomerEmoticonTab new];
    //  emoticonTab1.identify = @"1";
    //  emoticonTab1.image = icon;
    //  emoticonTab1.pageCount = 2;
    //  [self.emojiBoardView addEmojiTab:emoticonTab1];
    //
    //  RCDCustomerEmoticonTab *emoticonTab2 = [RCDCustomerEmoticonTab new];
    //  emoticonTab2.identify = @"2";
    //  emoticonTab2.image = icon;
    //  emoticonTab2.pageCount = 4;
    //  [self.emojiBoardView addEmojiTab:emoticonTab2];
}

#pragma mark - helper
- (void)addOtherPluginBoard {
    if (self.conversationType != ConversationType_APPSERVICE &&
        self.conversationType != ConversationType_PUBLICSERVICE) {
        //加号区域增加发送文件功能，Kit中已经默认实现了该功能，但是为了SDK向后兼容性，目前SDK默认不开启该入口，可以参考以下代码在加号区域中增加发送文件功能。
        UIImage *imageFile = [RCKitUtility imageNamed:@"actionbar_file_icon" ofBundle:@"RongCloud.bundle"];
        RCPluginBoardView *pluginBoardView = self.chatSessionInputBarControl.pluginBoardView;
        [pluginBoardView insertItemWithImage:imageFile
                                       title:NSLocalizedStringFromTable(@"File", @"RongCloudKit", nil)
                                     atIndex:3
                                         tag:PLUGIN_BOARD_ITEM_FILE_TAG];
    }
    if (self.conversationType == ConversationType_PRIVATE || self.conversationType == ConversationType_GROUP) {
        [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"poke_plugin_item"]
                                                                       title:RCDLocalizedString(@"Poke")
                                                                         tag:PLUGIN_BOARD_ITEM_POKE_TAG];
    }
}

- (void)pushPersonDetailVC:(RCDUserInfo *)user {
    if (self.conversationType == ConversationType_GROUP) {
        UIViewController *vc = [RCDPersonDetailViewController configVC:user.userId groupId:self.targetId];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        UIViewController *vc = [RCDPersonDetailViewController configVC:user.userId groupId:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)pushFriendVC:(RCDUserInfo *)user {
    RCDAddFriendViewController *vc = [[RCDAddFriendViewController alloc] init];
    vc.targetUserId = user.userId;
    if (self.conversationType == ConversationType_GROUP) {
        vc.groupId = self.targetId;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:vc animated:YES];
    });
}

- (void)setLeftNavigationItem {
    int count = [RCDUtilities getTotalUnreadCount];
    NSString *backString = nil;
    if (count > 0 && count < 1000) {
        backString = [NSString stringWithFormat:@"%@(%d)", RCDLocalizedString(@"back"), count];
    } else if (count >= 1000) {
        backString = [NSString stringWithFormat:@"%@(...)", RCDLocalizedString(@"back")];
    } else {
        backString = RCDLocalizedString(@"back");
    }
    RCDUIBarButtonItem *leftButton =
        [[RCDUIBarButtonItem alloc] initWithLeftBarButton:backString
                                                   target:self
                                                   action:@selector(leftBarButtonItemPressed:)];
    [self.navigationItem setLeftBarButtonItem:leftButton];
}

- (void)setRightNavigationItem:(UIImage *)image withFrame:(CGRect)frame {
    RCDUIBarButtonItem *rightBtn = [[RCDUIBarButtonItem alloc] initContainImage:image
                                                                 imageViewFrame:frame
                                                                    buttonTitle:nil
                                                                     titleColor:nil
                                                                     titleFrame:CGRectZero
                                                                    buttonFrame:frame
                                                                         target:self
                                                                         action:@selector(rightBarButtonItemClicked:)];
    self.navigationItem.rightBarButtonItem = rightBtn;
}

- (void)clearHistoryMSG {
    [self.conversationDataRepository removeAllObjects];
    [self.conversationMessageCollectionView reloadData];
}

- (void)popupChatViewController {
    [self.realTimeLocation removeRealTimeLocationObserver:self];
    if (self.needPopToRootView == YES) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [super leftBarButtonItemPressed:nil];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
}

- (void)refreshUserInfoOrGroupInfo {
    if ([[RCIMClient sharedRCIMClient] getCurrentNetworkStatus] == RC_NotReachable ) {
        return;
    }
    //打开单聊强制从demo server 获取用户信息更新本地数据库
    if (self.conversationType == ConversationType_PRIVATE) {
        if (![self.targetId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
            __weak typeof(self) weakSelf = self;
            [RCDUserInfoManager
                getUserInfoFromServer:self.targetId
                             complete:^(RCUserInfo *userInfo) {
                                 [RCDUserInfoManager
                                     getFriendInfoFromServer:userInfo.userId
                                                    complete:^(RCDFriendInfo *friendInfo) {
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            if (friendInfo.displayName.length > 0) {
                                                                weakSelf.navigationItem.title = friendInfo.displayName;
                                                            } else {
                                                                weakSelf.navigationItem.title = userInfo.name;
                                                            }
                                                        });
                                                    }];
                             }];
        }
    }

    //打开群聊强制从demo server 获取群组信息更新本地数据库
    if (self.conversationType == ConversationType_GROUP) {
        __weak typeof(self) weakSelf = self;
        [RCDGroupManager getGroupInfoFromServer:self.targetId
                                       complete:^(RCDGroupInfo *_Nonnull groupInfo) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               if (groupInfo) {
                                                   weakSelf.groupInfo = groupInfo;
                                                   [weakSelf refreshTitle];
                                                   [RCDGroupManager
                                                       getGroupMembersFromServer:self.targetId
                                                                        complete:^(NSArray<NSString *> *memberIdList) {
                                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                                [weakSelf setRightNavigationItems];
                                                                            });
                                                                        }];
                                               }
                                           });
                                       }];
    }
}

- (void)refreshTitle {
    if (self.conversationType == ConversationType_GROUP) {
        RCDGroupInfo *groupInfo = [RCDGroupManager getGroupInfo:self.targetId];
        if (groupInfo.groupName) {
            self.userName = groupInfo.groupName;
        }
        if ([groupInfo.number intValue] > 0) {
            self.title = [NSString stringWithFormat:@"%@(%d)", self.userName, [groupInfo.number intValue]];
        } else {
            self.title = [NSString stringWithFormat:@"%@", self.userName];
        }
    } else if(self.conversationType == ConversationType_PRIVATE){
        RCUserInfo *userInfo = [[RCIM sharedRCIM] getUserInfoCache:self.targetId];
        if (userInfo) {
            self.title = userInfo.name;
        }
    }
}

- (BOOL)stayAfterJoinChatRoomFailed {
    //加入聊天室失败之后，是否还停留在会话界面
    return [DEFAULTS boolForKey:RCDStayAfterJoinChatRoomFailedKey];
}

- (void)alertErrorAndLeft:(NSString *)errorInfo {
    if (![self stayAfterJoinChatRoomFailed]) {
        [super alertErrorAndLeft:errorInfo];
    }
}

- (void)setRightNavigationItems {
    if (self.conversationType == ConversationType_GROUP) {
        if (self.groupInfo.isDismiss ||
            ![[RCDGroupManager getGroupMembers:self.targetId]
                containsObject:[RCIM sharedRCIM].currentUserInfo.userId]) {
            self.navigationItem.rightBarButtonItem = nil;
            return;
        }
        [self setRightNavigationItem:[UIImage imageNamed:@"Group_Setting"] withFrame:CGRectMake(0, 0, 21, 19.5)];
    } else if (self.conversationType == ConversationType_CHATROOM) {
        [self setRightNavigationItem:nil withFrame:CGRectZero];
    } else {
        [self setRightNavigationItem:[UIImage imageNamed:@"Private_Setting"] withFrame:CGRectMake(0, 0, 16, 18.5)];
    }
}
- (void)addNotifications {
    if (self.conversationType == ConversationType_GROUP) {
        //群组改名之后，更新当前页面的Title
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateTitleForGroup:)
                                                     name:RCDGroupInfoUpdateKey
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didGroupMemberUpdateNotification:)
                                                     name:RCDGroupMemberUpdateKey
                                                   object:nil];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateForSharedMessageInsertSuccess:)
                                                 name:@"RCDSharedMessageInsertSuccess"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHideNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onEndForwardMessage:)
                                                 name:@"RCDForwardMessageEnd"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidTakeScreenshot:)
                                                 name:UIApplicationUserDidTakeScreenshotNotification
                                               object:nil];
    [self.conversationMessageCollectionView addObserver:self
                                             forKeyPath:@"frame"
                                                options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                                context:nil];
}

- (void)addQuicklySendImage {
    [(UIButton *)self.chatSessionInputBarControl.additionalButton addTarget:self
                                                                     action:@selector(quicklySendImage:)
                                                           forControlEvents:UIControlEventTouchUpInside];
    [RCDQuicklySendManager sharedManager].delegate = self;
}

- (void)setupChatBackground {
    NSString *imageName = [DEFAULTS objectForKey:RCDChatBackgroundKey];
    UIImage *image = [UIImage imageNamed:imageName];
    if ([imageName isEqualToString:RCDChatBackgroundFromAlbum]) {
        NSData *imageData = [DEFAULTS objectForKey:RCDChatBackgroundImageDataKey];
        image = [UIImage imageWithData:imageData];
    }
    if (image) {
        self.conversationMessageCollectionView.backgroundColor = [UIColor clearColor];
        image = [RCKitUtility fixOrientation:image];
        self.view.layer.contents = (id)image.CGImage;
    }
}

- (void)resetQucilySendView {
    [[RCDQuicklySendManager sharedManager] hideQuicklySendView];
}

#pragma mark - *************消息多选功能:转发、删除*************
/******************消息多选功能:转发、删除**********************/
- (void)addToolbarItems {
    //转发按钮
    UIButton *forwardBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    [forwardBtn setImage:[UIImage imageNamed:@"forward_message"] forState:UIControlStateNormal];
    [forwardBtn addTarget:self action:@selector(forwardMessage) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *forwardBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:forwardBtn];
    //删除按钮
    UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    [deleteBtn setImage:[RCKitUtility imageNamed:@"delete_message" ofBundle:@"RongCloud.bundle"]
               forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteMessages) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *deleteBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:deleteBtn];
    //按钮间 space
    UIBarButtonItem *spaceItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self.messageSelectionToolbar
        setItems:@[ spaceItem, forwardBarButtonItem, spaceItem, deleteBarButtonItem, spaceItem ]
        animated:YES];
}

- (void)forwardMessage {
    [RCDForwardManager sharedInstance].selectedMessages = self.selectedMessages;
    if ([[RCDForwardManager sharedInstance] allSelectedMessagesAreLegal]) {
        [RCDForwardManager sharedInstance].isForward = YES;
        RCDForwardSelectedViewController *forwardSelectedVC = [[RCDForwardSelectedViewController alloc] init];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:forwardSelectedVC];
        navi.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController presentViewController:navi animated:YES completion:nil];
    } else {
        UIAlertController *alertController =
            [UIAlertController alertControllerWithTitle:nil
                                                message:RCDLocalizedString(@"Forwarding_is_not_supported")
                                         preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:RCDLocalizedString(@"confirm")
                                                            style:UIAlertActionStyleDefault
                                                          handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)onEndForwardMessage:(NSNotification *)notification {
    //置为 NO,将消息 cell 重置为初始状态
    self.allowsMessageCellSelection = NO;
    [self.view showHUDMessage:RCDLocalizedString(@"send_success")];
    [self scrollToBottomAnimated:YES];
}

- (void)deleteMessages {
    for (int i = 0; i < self.selectedMessages.count; i++) {
        [self deleteMessage:self.selectedMessages[i]];
    }
    //置为 NO,将消息 cell 重置为初始状态
    self.allowsMessageCellSelection = NO;
}

- (void)forwardMessage:(NSInteger)index completed:(void (^)(NSArray<RCConversation *> *))completedBlock {
    [RCDForwardManager sharedInstance].selectedMessages = self.selectedMessages;
    [RCDForwardManager sharedInstance].isForward = YES;
    [RCDForwardManager sharedInstance].selectConversationCompleted =
        ^(NSArray<RCConversation *> *_Nonnull conversationList) {
            completedBlock(conversationList);
        };
    RCDForwardSelectedViewController *forwardSelectedVC = [[RCDForwardSelectedViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:forwardSelectedVC];
    navi.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:navi animated:YES completion:nil];
}

- (void)userDidTakeScreenshot:(NSNotification *)notification {
    if (self.isShow && [self.navigationController.topViewController isKindOfClass:[self class]]) {
        [RCDChatManager getScreenCaptureNotification:self.conversationType
            targetId:self.targetId
            complete:^(BOOL screenCaptureNotification) {
                if (screenCaptureNotification) {
                    [RCDChatManager sendScreenCaptureNotification:self.conversationType
                                                         targetId:self.targetId
                                                         complete:^(BOOL success){

                                                         }];
                }
            }
            error:^{

            }];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self setupChatBackground];
}

#pragma mark - *************实时位置共享*************
- (void)initRealTimeLocationStatusView {
    self.realTimeLocationStatusView =
        [[RealTimeLocationStatusView alloc] initWithFrame:CGRectMake(0, 62, self.view.frame.size.width, 0)];
    self.realTimeLocationStatusView.delegate = self;
    [self.view addSubview:self.realTimeLocationStatusView];
}

//注册实时位置共享相关消息
- (void)registerRealTimeLocationCell {
    [self initRealTimeLocationStatusView];
    [self registerClass:[RealTimeLocationStartCell class] forMessageClass:[RCRealTimeLocationStartMessage class]];
    [self registerClass:[RealTimeLocationEndCell class] forMessageClass:[RCRealTimeLocationEndMessage class]];
}

//获取实时位置共享代理
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

//弹出实时位置共享页面
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

//更新实时位置共享状态
- (void)updateRealTimeLocationStatus {
    if (self.realTimeLocation) {
        [self.realTimeLocationStatusView updateRealTimeLocationStatus];
        __weak typeof(self) weakSelf = self;
        NSArray *participants = nil;
        switch ([self.realTimeLocation getStatus]) {
        case RC_REAL_TIME_LOCATION_STATUS_OUTGOING:
            [self.realTimeLocationStatusView updateText:RTLLocalizedString(@"you_location_sharing")];
            break;
        case RC_REAL_TIME_LOCATION_STATUS_CONNECTED:
        case RC_REAL_TIME_LOCATION_STATUS_INCOMING:
            participants = [self.realTimeLocation getParticipants];
            if (participants.count == 1) {
                NSString *userId = participants[0];
                [[RCIM sharedRCIM]
                        .userInfoDataSource
                    getUserInfoWithUserId:userId
                               completion:^(RCUserInfo *userInfo) {
                                   if (userInfo.name.length) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [weakSelf.realTimeLocationStatusView
                                               updateText:[NSString stringWithFormat:RTLLocalizedString(
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
                        updateText:[NSString stringWithFormat:RTLLocalizedString(@"share_location_people_count"),
                                                              (int)participants.count]];
            }
            break;
        default:
            break;
        }
    }
}

#pragma mark 实时位置共享监听代理方法
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
        [self notifyParticipantChange:RTLLocalizedString(@"you_join_location_share")];
    } else {
        [[RCIM sharedRCIM]
                .userInfoDataSource
            getUserInfoWithUserId:userId
                       completion:^(RCUserInfo *userInfo) {
                           if (userInfo.name.length) {
                               [weakSelf
                                   notifyParticipantChange:[NSString
                                                               stringWithFormat:RTLLocalizedString(
                                                                                    @"someone_join_share_location"),
                                                                                userInfo.name]];
                           } else {
                               [weakSelf
                                   notifyParticipantChange:[NSString stringWithFormat:RTLLocalizedString(
                                                                                          @"user_join_share_location"),
                                                                                      userId]];
                           }
                       }];
    }
}

- (void)onParticipantsQuit:(NSString *)userId {
    __weak typeof(self) weakSelf = self;
    if ([userId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        [self notifyParticipantChange:RTLLocalizedString(@"you_quit_location_share")];
    } else {
        [[RCIM sharedRCIM]
                .userInfoDataSource
            getUserInfoWithUserId:userId
                       completion:^(RCUserInfo *userInfo) {
                           if (userInfo.name.length) {
                               [weakSelf
                                   notifyParticipantChange:[NSString
                                                               stringWithFormat:RTLLocalizedString(
                                                                                    @"someone_quit_location_share"),
                                                                                userInfo.name]];
                           } else {
                               [weakSelf
                                   notifyParticipantChange:[NSString stringWithFormat:RTLLocalizedString(
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

#pragma mark - 实时位置共享状态 view 代理方法
- (void)onJoin {
    [self showRealTimeLocationViewController];
}
- (RCRealTimeLocationStatus)getStatus {
    return [self.realTimeLocation getStatus];
}

- (void)onShowRealTimeLocationView {
    [self showRealTimeLocationViewController];
}

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

#pragma mark - 加载远端聊天室消息开始
//#pragma mark *************Load More Chatroom History Message From Server*************
////需要开通聊天室消息云端存储功能，调用getRemoteChatroomHistoryMessages接口才可以从服务器获取到聊天室消息的数据
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    //当会话类型是聊天室时，下拉加载消息会调用getRemoteChatroomHistoryMessages接口从服务器拉取聊天室消息
//    if (self.conversationType == ConversationType_CHATROOM) {
//        if (scrollView.contentOffset.y < -15.0f && !self.loading) {
//            self.loading = YES;
//            [self performSelector:@selector(loadMoreChatroomHistoryMessageFromServer) withObject:nil afterDelay:0.4f];
//        }
//    } else {
//        [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
//    }
//}
//
////从服务器拉取聊天室消息的方法
//- (void)loadMoreChatroomHistoryMessageFromServer {
//    long long recordTime = 0;
//    RCMessageModel *model;
//    if (self.conversationDataRepository.count > 0) {
//        model = [self.conversationDataRepository objectAtIndex:0];
//        recordTime = model.sentTime;
//    }
//    __weak typeof(self) weakSelf = self;
//    [[RCIMClient sharedRCIMClient] getRemoteChatroomHistoryMessages:self.targetId
//        recordTime:recordTime
//        count:20
//        order:RC_Timestamp_Desc
//        success:^(NSArray *messages, long long syncTime) {
//            self.loading = NO;
//            [weakSelf handleMessages:messages];
//        }
//        error:^(RCErrorCode status) {
//            NSLog(@"load remote history message failed(%zd)", status);
//        }];
//}
//
////对于从服务器拉取到的聊天室消息的处理
//- (void)handleMessages:(NSArray *)messages {
//    NSMutableArray *tempMessags = [[NSMutableArray alloc] initWithCapacity:0];
//    for (RCMessage *message in messages) {
//        RCMessageModel *model = [RCMessageModel modelWithMessage:message];
//        [tempMessags addObject:model];
//    }
//    //对去拉取到的消息进行逆序排列
//    NSArray *reversedArray = [[tempMessags reverseObjectEnumerator] allObjects];
//    tempMessags = [reversedArray mutableCopy];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        //将逆序排列的消息加入到数据源
//        [tempMessags addObjectsFromArray:self.conversationDataRepository];
//        self.conversationDataRepository = tempMessags;
//        //显示消息发送时间的方法
//        [self figureOutAllConversationDataRepository];
//        [self.conversationMessageCollectionView reloadData];
//        if (self.conversationDataRepository != nil && self.conversationDataRepository.count > 0 &&
//            [self.conversationMessageCollectionView numberOfItemsInSection:0] >= messages.count - 1) {
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:messages.count - 1 inSection:0];
//            [self.conversationMessageCollectionView scrollToItemAtIndexPath:indexPath
//                                                           atScrollPosition:UICollectionViewScrollPositionTop
//                                                                   animated:NO];
//        }
//    });
//}
//
////显示消息发送时间的方法
//- (void)figureOutAllConversationDataRepository {
//    for (int i = 0; i < self.conversationDataRepository.count; i++) {
//        RCMessageModel *model = [self.conversationDataRepository objectAtIndex:i];
//        if (0 == i) {
//            model.isDisplayMessageTime = YES;
//        } else if (i > 0) {
//            RCMessageModel *pre_model = [self.conversationDataRepository objectAtIndex:i - 1];
//
//            long long previous_time = pre_model.sentTime;
//
//            long long current_time = model.sentTime;
//
//            long long interval =
//                current_time - previous_time > 0 ? current_time - previous_time : previous_time - current_time;
//            if (interval / 1000 <= 3 * 60) {
//                if (model.isDisplayMessageTime && model.cellSize.height > 0) {
//                    CGSize size = model.cellSize;
//                    size.height = model.cellSize.height - 45;
//                    model.cellSize = size;
//                }
//                model.isDisplayMessageTime = NO;
//            } else if (![[[model.content class] getObjectName] isEqualToString:@"RC:OldMsgNtf"]) {
//                if (!model.isDisplayMessageTime && model.cellSize.height > 0) {
//                    CGSize size = model.cellSize;
//                    size.height = model.cellSize.height + 45;
//                    model.cellSize = size;
//                }
//                model.isDisplayMessageTime = YES;
//            }
//        }
//        if ([[[model.content class] getObjectName] isEqualToString:@"RC:OldMsgNtf"]) {
//            model.isDisplayMessageTime = NO;
//        }
//    }
//}
#pragma mark 加载远端聊天室消息结束
@end
