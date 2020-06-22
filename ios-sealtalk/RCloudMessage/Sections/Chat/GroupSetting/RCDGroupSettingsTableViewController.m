//
//  RCDGroupSettingsTableViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/3/22.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDGroupSettingsTableViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "RCDContactSelectedTableViewController.h"
#import "RCDEditGroupNameViewController.h"
#import "RCDGroupAnnouncementViewController.h"
#import "RCDGroupMemberListController.h"
#import "RCDGroupSettingsTableViewCell.h"
#import "RCDBaseSettingTableViewCell.h"
#import "RCDPersonDetailViewController.h"
#import "RCDSearchHistoryMessageController.h"
#import "RCDUserInfoManager.h"
#import "RCDGroupManager.h"
#import "UIColor+RCColor.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "RCDUIBarButtonItem.h"
#import "UIImage+RCImage.h"
#import "RCDIMService.h"
#import "RCDUserListCollectionView.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDCommonString.h"
#import "RCDQRCodeController.h"
#import "RCDUploadManager.h"
#import "RCDGroupManageController.h"
#import "NormalAlertView.h"
#import "RCDUtilities.h"
#import "RCDDBManager.h"
#import "RCDTipFooterView.h"
#import "RCDChatManager.h"
#import "RCDGroupManager.h"
#import "UIView+MBProgressHUD.h"
#import "RCDGroupMemberDetailController.h"
static NSString *CellIdentifier = @"RCDBaseSettingTableViewCell";

@interface RCDGroupSettingsTableViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate,
                                                   RCDBaseSettingTableViewCellDelegate,
                                                   RCDUserListCollectionViewDelegate>
@property (nonatomic, strong) RCDUserListCollectionView *headerView;
@property (nonatomic, strong) NSArray *memberList;
@property (nonatomic, strong) NSArray *headerDisplayMembers;
@property (nonatomic, strong) RCDTipFooterView *tipFooterView;
@property (nonatomic, strong) NSArray *settingTableArr;
@property (nonatomic, strong) UIActivityIndicatorView *clearLoadingView;
@end

@implementation RCDGroupSettingsTableViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    RCDUIBarButtonItem *leftButton =
        [[RCDUIBarButtonItem alloc] initWithLeftBarButton:RCDLocalizedString(@"back")
                                                   target:self
                                                   action:@selector(backBarButtonItemClicked:)];
    [self.navigationItem setLeftBarButtonItem:leftButton];
    [self registerNotification];
    [self startLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.group.number) {
        self.title = [NSString stringWithFormat:RCDLocalizedString(@"group_information_x"), self.group.number];
    } else {
        self.title = RCDLocalizedString(@"group_information");
    }
}

- (void)dealloc {
    NSLog(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.settingTableArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.settingTableArr[section];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = self.settingTableArr[indexPath.section];
    NSString *title = array[indexPath.row];
    RCDGroupSettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[RCDGroupSettingsTableViewCell alloc] initWithTitle:title andGroupInfo:self.group];
    }

    //设置switchbutton的开关状态
    if ([title isEqualToString:RCDLocalizedString(@"mute_notifications")]) {
        [self setCurrentNotificationStatus:cell.switchButton];
    } else if ([title isEqualToString:RCDLocalizedString(@"stick_on_top")]) {
        RCConversation *conversation =
            [[RCIMClient sharedRCIMClient] getConversation:ConversationType_GROUP targetId:self.group.groupId];
        cell.switchButton.on = conversation.isTop;
    } else if ([title isEqualToString:RCDLocalizedString(@"ScreenCaptureNotification")]) {
        [self setScreenCaptureSwitchStatusWithCell:cell];
    }
    cell.baseSettingTableViewDelegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0 || section == 5 || section == 6) {
        return CGFLOAT_MIN;
    }
    return 14.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    NSArray *array = self.settingTableArr[section];
    NSString *title = array[0];
    if (array.count == 1 && [title isEqualToString:RCDLocalizedString(@"ScreenCaptureNotification")]) {
        return [self footerViewHeightWithContent:RCDLocalizedString(@"ScreenCaptureNotificationInfo")];
    } else if (array.count == 1 && [title isEqualToString:RCDLocalizedString(@"CleanUpGroupMessagesRegularly")]) {
        return [self footerViewHeightWithContent:RCDLocalizedString(@"CleanUpGroupMessagesInfo")];
    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    NSArray *array = self.settingTableArr[section];
    NSString *title = array[0];
    if (array.count == 1 && [title isEqualToString:RCDLocalizedString(@"ScreenCaptureNotification")]) {
        return [self footerViewWithContent:RCDLocalizedString(@"ScreenCaptureNotificationInfo")];
    } else if (array.count == 1 && [title isEqualToString:RCDLocalizedString(@"CleanUpGroupMessagesRegularly")]) {
        return [self footerViewWithContent:RCDLocalizedString(@"CleanUpGroupMessagesInfo")];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = self.settingTableArr[indexPath.section];
    NSString *title = array[indexPath.row];
    if ([title
            isEqualToString:[NSString stringWithFormat:RCDLocalizedString(@"all_group_member_z"), self.group.number]]) {
        [self pushGroupMemberVC];
    } else if ([title isEqualToString:RCDLocalizedString(@"group_portrait")]) {
        [self choosePortrait];
    } else if ([title isEqualToString:RCDLocalizedString(@"group_name")]) {
        [self pushEditGroupNameVC];
    } else if ([title isEqualToString:RCDLocalizedString(@"GroupQR")]) {
        [self pushQRCodeVC];
    } else if ([title isEqualToString:RCDLocalizedString(@"group_announcement")]) {
        [self pushGroupAnnouncementVC];
    } else if ([title isEqualToString:RCDLocalizedString(@"GroupManage")]) {
        [self pushGroupManageVC];
    } else if ([title isEqualToString:RCDLocalizedString(@"search_chat_history")]) {
        [self pushSearchHistoryVC];
    } else if ([title isEqualToString:RCDLocalizedString(@"CleanUpGroupMessagesRegularly")]) {
        if ([RCDGroupManager getGroupMember:[RCIM sharedRCIM].currentUserInfo.userId groupId:self.group.groupId].role ==
            RCDGroupMemberRoleOwner) {
            [self cleanUpGroupMessagesRegularly];
        } else {
            [self showHUDMessage:RCDLocalizedString(@"OperateOnlyGroupCreator")];
        }
    } else if ([title isEqualToString:RCDLocalizedString(@"clear_chat_history")]) {
        [self showActionSheet:RCDLocalizedString(@"clear_chat_history_alert") tag:100];
    } else if ([title isEqualToString:RCDLocalizedString(@"MyInfoInGroup")]) {
        [self pushMyInfoInGroup];
    }
}

#pragma mark - RCDUserListCollectionViewDelegate
- (void)didTipHeaderClicked:(NSString *)userId {
    UIViewController *vc = [RCDPersonDetailViewController configVC:userId groupId:self.group.groupId];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addButtonDidClicked {
    RCDContactSelectedTableViewController *contactSelectedVC =
        [[RCDContactSelectedTableViewController alloc] initWithTitle:RCDLocalizedString(@"select_contact")
                                           isAllowsMultipleSelection:YES];
    contactSelectedVC.groupId = self.group.groupId;
    contactSelectedVC.orignalGroupMembers = [self.memberList mutableCopy];
    contactSelectedVC.groupOptionType = RCDContactSelectedGroupOptionTypeAdd;
    [self.navigationController pushViewController:contactSelectedVC animated:YES];
}

- (void)deleteButtonDidClicked {
    RCDContactSelectedTableViewController *contactSelectedVC =
        [[RCDContactSelectedTableViewController alloc] initWithTitle:RCDLocalizedString(@"remove_member")
                                           isAllowsMultipleSelection:YES];
    contactSelectedVC.groupId = self.group.groupId;
    NSMutableArray *members = [NSMutableArray new];
    for (NSString *userId in self.memberList) {
        if (![userId isEqualToString:[RCDGroupManager getGroupOwner:self.group.groupId]]) {
            RCDFriendInfo *friendInfo = [RCDUserInfoManager getFriendInfo:userId];
            if (!friendInfo) {
                friendInfo = (RCDFriendInfo *)[RCDUserInfoManager getUserInfo:userId];
            }
            [members addObject:friendInfo];
        }
    }
    contactSelectedVC.groupOptionType = RCDContactSelectedGroupOptionTypeDelete;
    contactSelectedVC.orignalGroupMembers = [members mutableCopy];
    [self.navigationController pushViewController:contactSelectedVC animated:YES];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [UIApplication sharedApplication].statusBarHidden = NO;
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    NSData *data;
    if ([mediaType isEqual:@"public.image"]) {
        UIImage *originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        CGRect captureRect = [[info objectForKey:UIImagePickerControllerCropRect] CGRectValue];
        UIImage *captureImage =
            [UIImage getSubImage:originImage Rect:captureRect imageOrientation:originImage.imageOrientation];

        UIImage *scaleImage = [UIImage scaleImage:captureImage toScale:0.8];
        data = UIImageJPEGRepresentation(scaleImage, 0.00001);
    }
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.color = [UIColor colorWithHexString:@"343637" alpha:0.5];
    hud.labelText = RCDLocalizedString(@"Uploading_avatar");
    [hud show:YES];
    __weak typeof(self) weakSelf = self;
    [RCDUploadManager
        uploadImage:data
           complete:^(NSString *url) {
               if (url.length > 0) {
                   [RCDGroupManager
                       setGroupPortrait:url
                                groupId:weakSelf.group.groupId
                               complete:^(BOOL success) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [hud hide:YES];
                                       if (success == YES) {
                                           RCDBaseSettingTableViewCell *cell =
                                               (RCDBaseSettingTableViewCell *)[weakSelf.tableView
                                                   viewWithTag:RCDGroupSettingsTableViewCellGroupPortraitTag];
                                           [cell.rightImageView sd_setImageWithURL:[NSURL URLWithString:url]];
                                           //在修改群组头像成功后，更新本地数据库。
                                           //                                      cell.PortraitImg.image = image;
                                       } else {
                                           [self showAlert:RCDLocalizedString(@"Upload_avatar_fail")];
                                       }
                                   });
                               }];
               } else {
                   dispatch_async(dispatch_get_main_queue(), ^{
                       //关闭HUD
                       [hud hide:YES];
                       [self showAlert:RCDLocalizedString(@"Upload_avatar_fail")];
                   });
               }
           }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - RCDBaseSettingTableViewCellDelegate
- (void)onClickSwitchButton:(id)sender {
    UISwitch *switchBtn = (UISwitch *)sender;
    //如果是“消息免打扰”的switch点击
    if (switchBtn.tag == SwitchButtonTag) {
        [self clickNotificationBtn:sender];
    } else if (switchBtn.tag == SwitchButtonTag + 1) { //
        //“会话置顶”的switch点击
        [self clickIsTopBtn:sender];
    } else if (switchBtn.tag == SwitchButtonTag + 2) {
        //“保存到通讯录”的switch点击
        [self saveToAddressBook:sender];
    } else if (switchBtn.tag == SwitchButtonTag + 3) {
        [self setScreenCaptureNotificationWithSwitchButton:switchBtn];
    }
}

#pragma mark - Notification Center
- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didGroupInfoUpdateNotification:)
                                                 name:RCDGroupInfoUpdateKey
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didGroupMemberUpdateNotification:)
                                                 name:RCDGroupMemberUpdateKey
                                               object:nil];
}

- (void)didGroupInfoUpdateNotification:(NSNotification *)notification {
    NSString *targetId = notification.object;
    if ([targetId isEqualToString:self.group.groupId]) {
        [self refreshGroupInfo];
    }
}
- (void)didGroupMemberUpdateNotification:(NSNotification *)notification {
    NSDictionary *dic = notification.object;
    if ([dic[@"targetId"] isEqualToString:self.group.groupId]) {
        [self refreshGroupMemberInfo];
    }
}

#pragma mark - helper
- (void)pushMyInfoInGroup {
    if (self.group.isDismiss) {
        [self.view showHUDMessage:RCDLocalizedString(@"GroupNoExist")];
    } else {
        RCDGroupMemberDetailController *myInfoVC = [[RCDGroupMemberDetailController alloc] init];
        [myInfoVC setUpdateMemberDetail:^{
            [self.headerView reloadData];
        }];
        myInfoVC.userId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
        myInfoVC.groupId = self.group.groupId;
        [self.navigationController pushViewController:myInfoVC animated:YES];
    }
}

- (void)pushGroupManageVC {
    RCDGroupMember *member =
        [RCDGroupManager getGroupMember:[RCIM sharedRCIM].currentUserInfo.userId groupId:self.group.groupId];
    if (member.role != RCDGroupMemberRoleMember) {
        RCDGroupManageController *groupManageVC = [[RCDGroupManageController alloc] init];
        groupManageVC.groupId = self.group.groupId;
        [self.navigationController pushViewController:groupManageVC animated:YES];
    } else {
        [self showAlert:RCDLocalizedString(@"Only_group_owner_and_manager_can_manage")];
    }
}

- (void)pushQRCodeVC {
    RCDQRCodeController *qrCodeVC =
        [[RCDQRCodeController alloc] initWithTargetId:self.group.groupId conversationType:ConversationType_GROUP];
    [self.navigationController pushViewController:qrCodeVC animated:YES];
}

- (void)pushGroupMemberVC {
    RCDGroupMemberListController *groupMembersVC =
        [[RCDGroupMemberListController alloc] initWithGroupId:self.group.groupId];
    groupMembersVC.groupMembers = self.memberList;
    [self.navigationController pushViewController:groupMembersVC animated:YES];
}

- (void)pushEditGroupNameVC {
    if ([[RCDGroupManager getGroupOwner:self.group.groupId] isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
        //如果是创建者，进入修改群名称页面
        RCDEditGroupNameViewController *editGroupNameVC = [[RCDEditGroupNameViewController alloc] init];
        editGroupNameVC.groupInfo = self.group;
        [self.navigationController pushViewController:editGroupNameVC animated:YES];
    } else {
        [self showAlert:RCDLocalizedString(@"Only_the_owner_can_edit_the_group_name")];
    }
}

- (void)pushGroupAnnouncementVC {
    RCDGroupMember *member =
        [RCDGroupManager getGroupMember:[RCIM sharedRCIM].currentUserInfo.userId groupId:self.group.groupId];
    if (member.role == RCDGroupMemberRoleMember) {
        __weak typeof(self) weakSelf = self;
        [RCDGroupManager
            getGroupAnnouncement:self.group.groupId
                        complete:^(RCDGroupAnnouncement *announce) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (announce.content.length > 0) {
                                    [NormalAlertView
                                        showAlertWithTitle:RCDLocalizedString(@"group_announcement")
                                                   message:announce.content
                                             describeTitle:[NSString
                                                               stringWithFormat:RCDLocalizedString(@"AnnouncementTime"),
                                                                                [RCDUtilities
                                                                                    getDataString:announce.publishTime]]
                                              confirmTitle:RCDLocalizedString(@"confirm")
                                                   confirm:^{

                                                   }];
                                } else {
                                    [weakSelf showAlert:RCDLocalizedString(@"GroupNoneAnnounce")];
                                }
                            });
                        }];
    } else {
        RCDGroupAnnouncementViewController *vc = [[RCDGroupAnnouncementViewController alloc] init];
        vc.groupId = self.group.groupId;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)pushSearchHistoryVC {
    RCDSearchHistoryMessageController *searchViewController = [[RCDSearchHistoryMessageController alloc] init];
    searchViewController.conversationType = ConversationType_GROUP;
    searchViewController.targetId = self.group.groupId;
    [self.navigationController pushViewController:searchViewController animated:YES];
}

- (void)quitGroup {
    //判断如果当前群组已经解散，直接删除消息和会话，并跳转到会话列表页面。
    if (self.group.isDismiss) {
        [self clearConversationAndMessage];
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }

    [RCDGroupManager quitGroup:self.group.groupId
                      complete:^(BOOL success) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              if (success) {
                                  [self clearConversationAndMessage];
                                  [self.navigationController popToRootViewControllerAnimated:YES];
                              } else {
                                  [self showAlert:RCDLocalizedString(@"quit_fail")];
                              }
                          });
                      }];
}

- (void)dismissGroup {
    [RCDGroupManager dismissGroup:self.group.groupId
                         complete:^(BOOL success) {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 if (success) {
                                     [self clearConversationAndMessage];
                                     [self.navigationController popToRootViewControllerAnimated:YES];
                                 } else {
                                     [self showAlert:RCDLocalizedString(@"Disband_group_fail")];
                                 }
                             });
                         }];
}

- (void)saveToAddressBook:(UISwitch *)switchButton {
    __weak typeof(self) weakSelf = self;
    if (!switchButton.on) {
        [RCDGroupManager removeFromMyGroups:self.group.groupId
                                   complete:^(BOOL success) {
                                       if (!success) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               switchButton.on = YES;
                                               [weakSelf.view showHUDMessage:RCDLocalizedString(@"set_fail")];
                                           });
                                       }
                                   }];
    } else {
        [RCDGroupManager addToMyGroups:self.group.groupId
                              complete:^(BOOL success) {
                                  if (!success) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [weakSelf.view showHUDMessage:RCDLocalizedString(@"set_fail")];
                                          switchButton.on = NO;
                                      });
                                  }
                              }];
    }
}

- (void)clearHistoryMessage {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    RCDBaseSettingTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self.clearLoadingView removeFromSuperview];
    [cell addSubview:self.clearLoadingView];
    [self.clearLoadingView startAnimating];
    __weak typeof(self) weakSelf = self;
    [[RCDIMService sharedService] clearHistoryMessage:ConversationType_GROUP
        targetId:weakSelf.group.groupId
        successBlock:^{
            [weakSelf showAlert:RCDLocalizedString(@"clear_chat_history_success")];
            [self.clearLoadingView removeFromSuperview];
            [self.clearLoadingView stopAnimating];
            weakSelf.clearMessageHistory();
        }
        errorBlock:^(RCErrorCode status) {
            [weakSelf showAlert:RCDLocalizedString(@"clear_chat_history_fail")];
            [self.clearLoadingView removeFromSuperview];
            [self.clearLoadingView stopAnimating];
        }];
}

- (void)clearConversationAndMessage {
    NSArray *latestMessages =
        [[RCIMClient sharedRCIMClient] getLatestMessages:ConversationType_GROUP targetId:self.group.groupId count:1];
    if (latestMessages.count > 0) {
        RCMessage *message = (RCMessage *)[latestMessages firstObject];
        [[RCIMClient sharedRCIMClient] clearRemoteHistoryMessages:ConversationType_GROUP
                                                         targetId:self.group.groupId
                                                       recordTime:message.sentTime
                                                          success:^{
                                                              [[RCIMClient sharedRCIMClient]
                                                                  clearMessages:ConversationType_GROUP
                                                                       targetId:self.group.groupId];
                                                          }
                                                            error:nil];
    }
    [[RCIMClient sharedRCIMClient] removeConversation:ConversationType_GROUP targetId:self.group.groupId];
}

- (void)refreshGroupMemberInfo {
    __weak typeof(self) weakSelf = self;
    [RCDGroupManager
        getGroupMembersFromServer:self.group.groupId
                         complete:^(NSArray<NSString *> *_Nonnull memberIdList) {
                             if (memberIdList) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     weakSelf.title = [NSString
                                         stringWithFormat:RCDLocalizedString(@"group_information_x"),
                                                          [NSString
                                                              stringWithFormat:@"%lu",
                                                                               (unsigned long)memberIdList.count]];
                                 });
                                 weakSelf.memberList = [weakSelf resetMemberList:memberIdList];
                                 weakSelf.headerDisplayMembers = [weakSelf getHeaderDisplayMemberData];
                                 [weakSelf setHeaderView];
                             }
                         }];
}

- (void)refreshGroupClearStatus {
    [RCDChatManager getGroupMessageClearStatus:self.group.groupId
                                      complete:^(RCDGroupMessageClearStatus status) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [self changeGroupMessageStatus:status];
                                          });
                                      }];
}

- (NSArray *)getHeaderDisplayMemberData {
    NSMutableArray *mutableArray = [NSMutableArray array];
    if (self.memberList.count <= 18) {
        mutableArray = self.memberList.mutableCopy;
    } else {
        for (int i = 0; i < 18; i++) {
            [mutableArray addObject:self.memberList[i]];
        }
    }
    return mutableArray.copy;
}

- (void)refreshGroupInfo {
    self.group = [RCDGroupManager getGroupInfo:self.group.groupId];
    [self refreshTableViewInfo];
    __weak typeof(self) weakSelf = self;
    [RCDGroupManager getGroupInfoFromServer:self.group.groupId
                                   complete:^(RCDGroupInfo *_Nonnull groupInfo) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           if (groupInfo) {
                                               weakSelf.group = groupInfo;
                                           }
                                           [weakSelf refreshTableViewInfo];
                                       });
                                   }];
}

- (void)refreshTableViewInfo {
    NSMutableArray *oneSectionArr = @[
        RCDLocalizedString(@"group_portrait"),
        RCDLocalizedString(@"group_name"),
        RCDLocalizedString(@"GroupQR"),
        RCDLocalizedString(@"group_announcement"),
        RCDLocalizedString(@"MyInfoInGroup"),
        RCDLocalizedString(@"GroupManage")
    ].mutableCopy;
    RCDGroupMember *member =
        [RCDGroupManager getGroupMember:[RCIM sharedRCIM].currentUserInfo.userId groupId:self.group.groupId];
    if (member.role == RCDGroupMemberRoleMember) {
        [oneSectionArr removeObject:RCDLocalizedString(@"GroupManage")];
    }
    if ([RCDGroupManager currentUserIsGroupCreatorOrManager:self.group.groupId]) {
        self.settingTableArr = @[
            @[ [NSString stringWithFormat:RCDLocalizedString(@"all_group_member_z"), self.group.number] ],
            oneSectionArr.copy,
            @[ RCDLocalizedString(@"search_chat_history") ],
            @[
               RCDLocalizedString(@"mute_notifications"),
               RCDLocalizedString(@"stick_on_top"),
               RCDLocalizedString(@"SaveToAddress")
            ],
            @[ RCDLocalizedString(@"ScreenCaptureNotification") ],
            @[ RCDLocalizedString(@"CleanUpGroupMessagesRegularly") ],
            @[ RCDLocalizedString(@"clear_chat_history") ]
        ];
    } else {
        self.settingTableArr = @[
            @[ [NSString stringWithFormat:RCDLocalizedString(@"all_group_member_z"), self.group.number] ],
            oneSectionArr.copy,
            @[ RCDLocalizedString(@"search_chat_history") ],
            @[
               RCDLocalizedString(@"mute_notifications"),
               RCDLocalizedString(@"stick_on_top"),
               RCDLocalizedString(@"SaveToAddress")
            ],
            @[ RCDLocalizedString(@"CleanUpGroupMessagesRegularly") ],
            @[ RCDLocalizedString(@"clear_chat_history") ]
        ];
    }
    [self.tableView reloadData];
}

- (void)setCurrentNotificationStatus:(UISwitch *)switchButton {
    [[RCIMClient sharedRCIMClient] getConversationNotificationStatus:ConversationType_GROUP
        targetId:self.group.groupId
        success:^(RCConversationNotificationStatus nStatus) {
            dispatch_async(dispatch_get_main_queue(), ^{
                switchButton.on = !nStatus;
            });
        }
        error:^(RCErrorCode status){

        }];
}

- (void)showAlert:(NSString *)alertContent {
    [NormalAlertView showAlertWithTitle:nil
                                message:alertContent
                          describeTitle:nil
                           confirmTitle:RCDLocalizedString(@"confirm")
                                confirm:^{
                                }];
}

- (void)showActionSheet:(NSString *)title tag:(NSInteger)tag {
    UIAlertAction *cancelAction =
        [UIAlertAction actionWithTitle:RCDLocalizedString(@"cancel") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:RCDLocalizedString(@"confirm")
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction *_Nonnull action) {
                                                              if (tag == 100) {
                                                                  [self clearHistoryMessage];
                                                              } else if (tag == 101) {
                                                                  [self quitGroup];
                                                              } else if (tag == 102) {
                                                                  [self dismissGroup];
                                                              }
                                                          }];
    [RCKitUtility showAlertController:title
                              message:nil
                       preferredStyle:UIAlertControllerStyleActionSheet
                              actions:@[ cancelAction, confirmAction ]
                     inViewController:self];
}

//将创建者挪到第一的位置
- (NSMutableArray *)resetMemberList:(NSArray *)groupMemberList {
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:groupMemberList];
    NSString *owner = [RCDGroupManager getGroupOwner:self.group.groupId];
    NSArray *managers = [RCDGroupManager getGroupManagers:self.group.groupId];
    for (NSString *memberId in managers) {
        [temp removeObject:memberId];
        [temp insertObject:memberId atIndex:0];
    }
    if (owner) {
        [temp removeObject:owner];
        [temp insertObject:owner atIndex:0];
    }
    return temp;
}

- (void)setHeaderView {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.group.isDismiss) {
            self.tableView.tableHeaderView = nil;
            return;
        }
        self.headerView = nil;
        [self.headerView reloadData:self.headerDisplayMembers];
        self.headerView.frame =
            CGRectMake(0, 0, RCDScreenWidth, self.headerView.collectionViewLayout.collectionViewContentSize.height);
        CGRect frame = self.headerView.frame;
        frame.size.height += 14;
        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:frame];
        [self.tableView.tableHeaderView addSubview:self.headerView];

        UIView *separatorLine =
            [[UIView alloc] initWithFrame:CGRectMake(10, frame.size.height - 1, frame.size.width - 10, 1)];
        separatorLine.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
        [self.tableView.tableHeaderView addSubview:separatorLine];
    });
}

- (void)setTableFooterView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 150)];
    UIButton *joinOrQuitGroupBtn = [[UIButton alloc] init];
    [joinOrQuitGroupBtn setBackgroundImage:[UIImage imageNamed:@"group_quit"] forState:UIControlStateNormal];
    [joinOrQuitGroupBtn setBackgroundImage:[UIImage imageNamed:@"group_quit_hover"] forState:UIControlStateSelected];
    [joinOrQuitGroupBtn setTitle:RCDLocalizedString(@"delete_and_exit") forState:UIControlStateNormal];
    joinOrQuitGroupBtn.layer.cornerRadius = 5.f;
    joinOrQuitGroupBtn.layer.borderWidth = 0.5f;
    joinOrQuitGroupBtn.layer.borderColor = [HEXCOLOR(0xcc4445) CGColor];
    [view addSubview:joinOrQuitGroupBtn];
    [joinOrQuitGroupBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *views = NSDictionaryOfVariableBindings(joinOrQuitGroupBtn);
    if ([[RCDGroupManager getGroupOwner:self.group.groupId] isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
        [joinOrQuitGroupBtn setTitle:RCDLocalizedString(@"DisbandAndDelete") forState:UIControlStateNormal];
        [joinOrQuitGroupBtn addTarget:self
                               action:@selector(btnDismissAction:)
                     forControlEvents:UIControlEventTouchUpInside];
    } else {
        [joinOrQuitGroupBtn setTitle:RCDLocalizedString(@"delete_and_exit") forState:UIControlStateNormal];
        [joinOrQuitGroupBtn addTarget:self
                               action:@selector(btnJOQAction:)
                     forControlEvents:UIControlEventTouchUpInside];
    }
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-29-[joinOrQuitGroupBtn(42)]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[joinOrQuitGroupBtn]-10-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    self.tableView.tableFooterView = view;
}

- (void)clickNotificationBtn:(id)sender {
    UISwitch *swch = sender;
    RCConnectionStatus connectStatus = [[RCIM sharedRCIM] getConnectionStatus];
    if (connectStatus != ConnectionStatus_Connected) {
        swch.on = !swch.on;
        UIAlertController *alertC =
            [UIAlertController alertControllerWithTitle:nil
                                                message:RCDLocalizedString(@"Set failed")
                                         preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action =
            [UIAlertAction actionWithTitle:RCDLocalizedString(@"confirm") style:UIAlertActionStyleCancel handler:nil];
        [alertC addAction:action];
        [self showDetailViewController:alertC sender:self];
        return;
    }
    [[RCIMClient sharedRCIMClient] setConversationNotificationStatus:ConversationType_GROUP
        targetId:self.group.groupId
        isBlocked:swch.on
        success:^(RCConversationNotificationStatus nStatus) {
        }
        error:^(RCErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            swch.on = !swch.on;
        });
        }];
}


- (void)clickIsTopBtn:(id)sender {
    UISwitch *swch = sender;
    [[RCIMClient sharedRCIMClient] setConversationToTop:ConversationType_GROUP
                                               targetId:self.group.groupId
                                                  isTop:swch.on];
}

- (void)backBarButtonItemClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)startLoad {
    self.memberList = [RCDGroupManager getGroupMembers:self.group.groupId];
    self.memberList = [self resetMemberList:self.memberList];
    if (self.memberList > 0) {
        /******************添加headerview*******************/
        self.headerDisplayMembers = [self getHeaderDisplayMemberData];
        [self setHeaderView];
    }
    [self refreshGroupMemberInfo];
    [self refreshGroupInfo];
    [self refreshGroupClearStatus];
    /******************添加footerview*******************/
    [self setTableFooterView];
}

- (void)btnJOQAction:(id)sender {
    [self showActionSheet:RCDLocalizedString(@"delete_group_alert") tag:101];
}

- (void)btnDismissAction:(id)sender {
    [self showActionSheet:RCDLocalizedString(@"Disband_group_alert") tag:102];
}

- (void)choosePortrait {
    if ([[RCDGroupManager getGroupOwner:self.group.groupId] isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
        UIAlertAction *cancelAction =
            [UIAlertAction actionWithTitle:RCDLocalizedString(@"cancel") style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *takePictureAction = [UIAlertAction actionWithTitle:RCDLocalizedString(@"take_picture")
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *_Nonnull action) {
                                                                      [self pushImagePickVC:0];
                                                                  }];
        UIAlertAction *myAlbumAction = [UIAlertAction actionWithTitle:RCDLocalizedString(@"my_album")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *_Nonnull action) {
                                                                  [self pushImagePickVC:1];
                                                              }];
        [RCKitUtility showAlertController:nil
                                  message:nil
                           preferredStyle:UIAlertControllerStyleActionSheet
                                  actions:@[ cancelAction, takePictureAction, myAlbumAction ]
                         inViewController:self];
    } else {
        [self showAlert:RCDLocalizedString(@"Only_the_owner_can_change_the_group_portrait")];
    }
}

- (void)pushImagePickVC:(NSInteger)buttonIndex {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.allowsEditing = YES;
        picker.delegate = self;
        if (buttonIndex == 0 &&
            [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else if (buttonIndex == 1) {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.modalPresentationStyle = UIModalPresentationFullScreen;
        }
        [self presentViewController:picker animated:YES completion:nil];
    });
}

- (void)showMBProgressHUDWithSuccess:(BOOL)success {
    NSString *message = success ? RCDLocalizedString(@"setting_success") : RCDLocalizedString(@"set_fail");
    [self showHUDMessage:message];
}

- (void)showHUDMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view showHUDMessage:message];
    });
}

- (void)changeGroupMessageStatus:(RCDGroupMessageClearStatus)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        RCDGroupSettingsTableViewCell *cell = nil;
        if ([RCDGroupManager currentUserIsGroupCreatorOrManager:self.group.groupId]) {
            cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:5]];
        } else {
            cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:4]];
        }
        NSString *content = nil;
        switch (status) {
        case RCDGroupMessageClearStatusClose:
            content = RCDLocalizedString(@"PleaseSetTime");
            break;
        case RCDGroupMessageClearStatusBefore3d:
            content = RCDLocalizedString(@"CleanUpGroupMessages3DaysAgo");
            break;
        case RCDGroupMessageClearStatusBefore7d:
            content = RCDLocalizedString(@"CleanUpGroupMessages7DaysAgo");
            break;
        case RCDGroupMessageClearStatusBefore36h:
            content = RCDLocalizedString(@"CleanUpGroupMessages36HoursAgo");
            break;
        case RCDGroupMessageClearStatusUnknown:
            content = RCDLocalizedString(@"PleaseSetTime");
        default:
            break;
        }
        cell.rightLabel.text = content;
    });
}

- (void)cleanUpGroupMessagesRegularly {
    UIAlertAction *cancelAction =
        [UIAlertAction actionWithTitle:RCDLocalizedString(@"cancel") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *hoursAction = [UIAlertAction
        actionWithTitle:RCDLocalizedString(@"CleanUpGroupMessages36HoursAgo")
                  style:UIAlertActionStyleDefault
                handler:^(UIAlertAction *_Nonnull action) {
                    [RCDChatManager
                        setGroupMessageClearStatus:RCDGroupMessageClearStatusBefore36h
                                           groupId:self.group.groupId
                                          complete:^(BOOL success) {
                                              if (success) {
                                                  [self changeGroupMessageStatus:RCDGroupMessageClearStatusBefore36h];
                                              }
                                              [self showMBProgressHUDWithSuccess:success];
                                          }];
                }];

    UIAlertAction *threeDaysAction = [UIAlertAction
        actionWithTitle:RCDLocalizedString(@"CleanUpGroupMessages3DaysAgo")
                  style:UIAlertActionStyleDefault
                handler:^(UIAlertAction *_Nonnull action) {
                    [RCDChatManager
                        setGroupMessageClearStatus:RCDGroupMessageClearStatusBefore3d
                                           groupId:self.group.groupId
                                          complete:^(BOOL success) {
                                              if (success) {
                                                  [self changeGroupMessageStatus:RCDGroupMessageClearStatusBefore3d];
                                              }
                                              [self showMBProgressHUDWithSuccess:success];
                                          }];
                }];

    UIAlertAction *sevenDaysAction = [UIAlertAction
        actionWithTitle:RCDLocalizedString(@"CleanUpGroupMessages7DaysAgo")
                  style:UIAlertActionStyleDefault
                handler:^(UIAlertAction *_Nonnull action) {
                    [RCDChatManager
                        setGroupMessageClearStatus:RCDGroupMessageClearStatusBefore7d
                                           groupId:self.group.groupId
                                          complete:^(BOOL success) {
                                              if (success) {
                                                  [self changeGroupMessageStatus:RCDGroupMessageClearStatusBefore7d];
                                              }
                                              [self showMBProgressHUDWithSuccess:success];
                                          }];
                }];

    UIAlertAction *neverCleanAction = [UIAlertAction
        actionWithTitle:RCDLocalizedString(@"NeverClean")
                  style:UIAlertActionStyleDefault
                handler:^(UIAlertAction *_Nonnull action) {
                    [RCDChatManager
                        setGroupMessageClearStatus:RCDGroupMessageClearStatusClose
                                           groupId:self.group.groupId
                                          complete:^(BOOL success) {
                                              if (success) {
                                                  [self changeGroupMessageStatus:RCDGroupMessageClearStatusClose];
                                              }
                                              [self showMBProgressHUDWithSuccess:success];
                                          }];
                }];

    [RCKitUtility showAlertController:nil
                              message:nil
                       preferredStyle:UIAlertControllerStyleActionSheet
                              actions:@[ cancelAction, hoursAction, threeDaysAction, sevenDaysAction, neverCleanAction ]
                     inViewController:self];
}

- (void)setScreenCaptureSwitchStatusWithCell:(RCDGroupSettingsTableViewCell *)cell {
    cell.switchButton.on =
        [RCDDBManager getScreenCaptureNotification:ConversationType_GROUP targetId:self.group.groupId];
    [RCDChatManager getScreenCaptureNotification:ConversationType_GROUP
        targetId:self.group.groupId
        complete:^(BOOL result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.switchButton.on = result;
            });
        }
        error:^{

        }];
}

- (RCDTipFooterView *)footerViewWithContent:(NSString *)content {
    RCDTipFooterView *tipFooterView = [[RCDTipFooterView alloc] init];
    [tipFooterView renderWithTip:content font:[UIFont fontWithName:@"PingFangSC-Regular" size:14]];
    return tipFooterView;
}

- (CGFloat)footerViewHeightWithContent:(NSString *)content {
    return [self.tipFooterView
        heightForTipFooterViewWithTip:content
                                 font:[UIFont fontWithName:@"PingFangSC-Regular" size:14]
                      constrainedSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 27, MAXFLOAT)];
}

- (void)setScreenCaptureNotificationWithSwitchButton:(UISwitch *)switchButton {
    [RCDChatManager setScreenCaptureNotification:switchButton.on
                                conversationType:ConversationType_GROUP
                                        targetId:self.group.groupId
                                        complete:^(BOOL result) {
                                            if (!result) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    switchButton.on = [RCDDBManager
                                                        getScreenCaptureNotification:ConversationType_GROUP
                                                                            targetId:self.group.groupId];
                                                });
                                            } else {
                                                [self showHUDMessage:RCDLocalizedString(@"setting_success")];
                                            }
                                        }];
}

#pragma mark - getter & setter
- (RCDUserListCollectionView *)headerView {
    if (!_headerView) {
        CGRect tempRect =
            CGRectMake(0, 0, RCDScreenWidth, _headerView.collectionViewLayout.collectionViewContentSize.height);
        NSString *currentUserId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
        NSString *groupOwnerId = [RCDGroupManager getGroupOwner:self.group.groupId];
        NSArray<NSString *> *groupManagers = [RCDGroupManager getGroupManagers:self.group.groupId];
        BOOL isCreator = NO;
        //群主，管理员都可以删除群成员
        if ([groupOwnerId isEqualToString:currentUserId] || [groupManagers containsObject:currentUserId]) {
            isCreator = YES;
        }
        _headerView = [[RCDUserListCollectionView alloc] initWithFrame:tempRect isAllowAdd:YES isAllowDelete:isCreator];
        _headerView.groupId = self.group.groupId;
        _headerView.userListCollectionViewDelegate = self;
    }
    return _headerView;
}

- (RCDTipFooterView *)tipFooterView {
    if (!_tipFooterView) {
        _tipFooterView = [[RCDTipFooterView alloc] init];
    }
    return _tipFooterView;
}

- (UIActivityIndicatorView *)clearLoadingView {
    if (!_clearLoadingView) {
        UIActivityIndicatorView *activityIndicatorView =
        [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        if (@available(iOS 13.0, *)) {
            activityIndicatorView =
                [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        }
        activityIndicatorView.frame = CGRectMake(self.tableView.bounds.size.width - 55, 0, 44, 44);
        _clearLoadingView = activityIndicatorView;
    }
    return _clearLoadingView;
}
@end
