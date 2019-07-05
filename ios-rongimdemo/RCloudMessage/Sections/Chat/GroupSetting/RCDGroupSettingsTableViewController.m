//
//  RCDGroupSettingsTableViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/3/22.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDGroupSettingsTableViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "RCDAddFriendViewController.h"
#import "RCDContactSelectedTableViewController.h"
#import "RCDEditGroupNameViewController.h"
#import "RCDGroupAnnouncementViewController.h"
#import "RCDGroupMembersTableViewController.h"
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
static NSString *CellIdentifier = @"RCDBaseSettingTableViewCell";

@interface RCDGroupSettingsTableViewController ()<UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, RCDBaseSettingTableViewCellDelegate, RCDUserListCollectionViewDelegate>
@property (nonatomic, strong) RCDUserListCollectionView *headerView;
@property (nonatomic, strong) NSArray *memberList;
@property (nonatomic, strong) NSArray *headerDisplayMembers;
@end

@implementation RCDGroupSettingsTableViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = HEXCOLOR(0xf0f0f6);
    self.tableView.separatorColor = HEXCOLOR(0xdfdfdf);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    RCDUIBarButtonItem *leftButton = [[RCDUIBarButtonItem alloc] initWithLeftBarButton:RCDLocalizedString(@"back") target:self action:@selector(backBarButtonItemClicked:)];
    [self.navigationItem setLeftBarButtonItem:leftButton];
    [self registerNotification];
    [self startLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.group.number) {
        self.title = [NSString stringWithFormat:RCDLocalizedString(@"group_information_x"),self.group.number];
    } else {
        self.title = RCDLocalizedString(@"group_information");
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 200) {
        [self pushImagePickVC:buttonIndex];
    }else if (actionSheet.tag == 100) {
        if (buttonIndex == 0) {
            [self clearHistoryMessage];
        }
    }else if (actionSheet.tag == 101) {
        if (buttonIndex == 0) {
            [self quitGroup];
        }
    }else if (actionSheet.tag == 102) {
        if (buttonIndex == 0) {
            [self dismissGroup];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.group.groupId == nil) {
        return 3;
    }
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    switch (section) {
    case 0:
        rows = 1;
        break;
    case 1:{
        RCDGroupMember *member = [RCDGroupManager getGroupMember:[RCIM sharedRCIM].currentUserInfo.userId groupId:self.group.groupId];
        if (member.role == RCDGroupMemberRoleMember) {
            return 4;
        } else {
            return 5;
        }
        break;
    }
    case 2:
        rows = 1;
        break;

    case 3:
        rows = 4;
        break;

    default:
        break;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDGroupSettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[RCDGroupSettingsTableViewCell alloc] initWithIndexPath:indexPath andGroupInfo:self.group];
    }
    //设置switchbutton的开关状态
    if (indexPath.section == 3 && indexPath.row == 0) {
        [self setCurrentNotificationStatus:cell.switchButton];
    } else if (indexPath.section == 3 && indexPath.row == 1) {
        RCConversation *conversation = [[RCIMClient sharedRCIMClient] getConversation:ConversationType_GROUP targetId:self.group.groupId];
        cell.switchButton.on = conversation.isTop;
    }
    cell.baseSettingTableViewDelegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 14.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
    case 0: {
        [self pushGroupMemberVC];
    } break;
    case 1: {
        switch (indexPath.row) {
        case 0: {
            [self choosePortrait];
        } break;
        case 1: {
            [self pushEditGroupNameVC];
        } break;
        case 2: {
            [self pushQRCodeVC];
        } break;
        case 3: {
            [self pushGroupAnnouncementVC];
        } break;
        case 4: {
            [self pushGroupManageVC];
        } break;
        default:
            break;
        }
    } break;
    case 2: {
        [self pushSearchHistoryVC];
    } break;
    case 3: {
        switch (indexPath.row) {
        case 3: {
            [self showActionSheet:RCDLocalizedString(@"clear_chat_history_alert") tag:100];
        } break;
        default:
            break;
        }
    } break;
    default:
        break;
    }
}

#pragma mark - RCDUserListCollectionViewDelegate
- (void)didTipHeaderClicked:(NSString *)userId{
    RCDFriendInfo *friendInfo = [RCDUserInfoManager getFriendInfo:userId];
    if ((friendInfo != nil && friendInfo.status == RCDFriendStatusAgree) || [userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]){
        RCDPersonDetailViewController *detailViewController = [[RCDPersonDetailViewController alloc] init];
        detailViewController.userId = userId;
        [self.navigationController pushViewController:detailViewController animated:YES];
    } else {
        RCUserInfo *user = [RCDUserInfoManager getUserInfo:userId];
        RCDAddFriendViewController *addViewController = [[RCDAddFriendViewController alloc] init];
        addViewController.targetUserInfo = user;
        [self.navigationController pushViewController:addViewController animated:YES];
    }
}

- (void)addButtonDidClicked{
    RCDContactSelectedTableViewController *contactSelectedVC = [[RCDContactSelectedTableViewController alloc] initWithTitle:RCDLocalizedString(@"select_contact") isAllowsMultipleSelection:YES];
    contactSelectedVC.groupId = self.group.groupId;
    contactSelectedVC.orignalGroupMembers = [self.memberList mutableCopy];
    contactSelectedVC.groupOptionType = RCDContactSelectedGroupOptionTypeAdd;
    [self.navigationController pushViewController:contactSelectedVC animated:YES];
}

- (void)deleteButtonDidClicked{
    RCDContactSelectedTableViewController *contactSelectedVC = [[RCDContactSelectedTableViewController alloc] initWithTitle:RCDLocalizedString(@"remove_member") isAllowsMultipleSelection:YES];
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
    [RCDUploadManager uploadImage:data
                         complete:^(NSString *url) {
                             if (url.length > 0) {
                                 [RCDGroupManager setGroupPortrait:url groupId:weakSelf.group.groupId complete:^(BOOL success) {
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         [hud hide:YES];
                                         if (success == YES) {
                                             RCDBaseSettingTableViewCell *cell =
                                             (RCDBaseSettingTableViewCell *)[weakSelf.tableView viewWithTag:RCDGroupSettingsTableViewCellGroupPortraitTag];
                                             [cell.rightImageView
                                              sd_setImageWithURL:[NSURL URLWithString:url]];
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
    } else if (switchBtn.tag == SwitchButtonTag+1){ //
        //“会话置顶”的switch点击
        [self clickIsTopBtn:sender];
    } else if (switchBtn.tag == SwitchButtonTag+2){
        //“保存到通讯录”的switch点击
        [self saveToAddressBook:sender];
    }
}

#pragma mark - Notification Center
- (void)registerNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didGroupInfoUpdateNotification:)
                                                 name:RCDGroupInfoUpdateKey
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didGroupMemberUpdateNotification:)
                                                 name:RCDGroupMemberUpdateKey
                                               object:nil];
}

- (void)didGroupInfoUpdateNotification:(NSNotification *)notification{
    NSString *targetId = notification.object;
    if ([targetId isEqualToString:self.group.groupId]) {
        [self refreshGroupInfo];
    }
}
- (void)didGroupMemberUpdateNotification:(NSNotification *)notification{
    NSDictionary *dic = notification.object;
    if ([dic[@"targetId"] isEqualToString:self.group.groupId]) {
        [self refreshGroupMemberInfo];
    }
}

#pragma mark - helper
- (void)pushGroupManageVC{
    RCDGroupMember *member = [RCDGroupManager getGroupMember:[RCIM sharedRCIM].currentUserInfo.userId groupId:self.group.groupId];
    if (member.role == RCDGroupMemberRoleOwner) {
        RCDGroupManageController *groupManageVC = [[RCDGroupManageController alloc] init];
        groupManageVC.groupId = self.group.groupId;
        [self.navigationController pushViewController:groupManageVC animated:YES];
    }else{
        [self showAlert:RCDLocalizedString(@"Only_the_group_owner_can_manage")];
    }
}

- (void)pushQRCodeVC{
    RCDQRCodeController *qrCodeVC = [[RCDQRCodeController alloc] initWithTargetId:self.group.groupId conversationType:ConversationType_GROUP];
    [self.navigationController pushViewController:qrCodeVC animated:YES];
}

- (void)pushGroupMemberVC{
    RCDGroupMembersTableViewController *groupMembersVC = [[RCDGroupMembersTableViewController alloc] initWithGroupId:self.group.groupId];
    groupMembersVC.groupMembers = self.memberList;
    [self.navigationController pushViewController:groupMembersVC animated:YES];
}

- (void)pushEditGroupNameVC{
    if ([[RCDGroupManager getGroupOwner:self.group.groupId] isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
        //如果是创建者，进入修改群名称页面
        RCDEditGroupNameViewController *editGroupNameVC = [[RCDEditGroupNameViewController alloc] init];
        editGroupNameVC.groupInfo = self.group;
        [self.navigationController pushViewController:editGroupNameVC animated:YES];
    } else {
        [self showAlert:RCDLocalizedString(@"Only_the_owner_can_edit_the_group_name")];
    }
}

- (void)pushGroupAnnouncementVC{
    RCDGroupMember *member = [RCDGroupManager getGroupMember:[RCIM sharedRCIM].currentUserInfo.userId groupId:self.group.groupId];
    if(member.role == RCDGroupMemberRoleMember){
        __weak typeof(self) weakSelf = self;
        [RCDGroupManager getGroupAnnouncement:self.group.groupId complete:^(RCDGroupAnnouncement *announce) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (announce.content.length > 0) {
                    [NormalAlertView showAlertWithTitle:RCDLocalizedString(@"group_announcement") message:announce.content describeTitle:[NSString stringWithFormat:RCDLocalizedString(@"AnnouncementTime"),[RCDUtilities getDataString:announce.publishTime]] confirmTitle:RCDLocalizedString(@"confirm") confirm:^{
                        
                    }];
                }else{
                    [weakSelf showAlert:RCDLocalizedString(@"GroupNoneAnnounce")];
                }
            });
        }];
    }else{
        RCDGroupAnnouncementViewController *vc = [[RCDGroupAnnouncementViewController alloc] init];
        vc.groupId = self.group.groupId;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)pushSearchHistoryVC{
    RCDSearchHistoryMessageController *searchViewController = [[RCDSearchHistoryMessageController alloc] init];
    searchViewController.conversationType = ConversationType_GROUP;
    searchViewController.targetId = self.group.groupId;
    [self.navigationController pushViewController:searchViewController animated:YES];
}
                           
                           

- (void)quitGroup{
    //判断如果当前群组已经解散，直接删除消息和会话，并跳转到会话列表页面。
    if (self.group.isDismiss) {
        [self clearConversationAndMessage];
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    
    [RCDGroupManager quitGroup:self.group.groupId complete:^(BOOL success) {
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

- (void)dismissGroup{
    [RCDGroupManager dismissGroup:self.group.groupId complete:^(BOOL success) {
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

- (void)saveToAddressBook:(UISwitch *)switchButton{
    if (!switchButton.on) {
        [RCDGroupManager removeFromMyGroups:self.group.groupId complete:^(BOOL success) {
            if (!success) {
                NSLog(@"移出失败");
                dispatch_async(dispatch_get_main_queue(), ^{
                    switchButton.on = YES;
                });
            }
        }];
    }else{
        [RCDGroupManager addToMyGroups:self.group.groupId complete:^(BOOL success) {
            if (!success) {
                NSLog(@"保存失败");
                dispatch_async(dispatch_get_main_queue(), ^{
                    switchButton.on = NO;
                });
                
            }
        }];
    }
}

- (void)clearHistoryMessage{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    RCDBaseSettingTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIActivityIndicatorView *activityIndicatorView =
    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    float cellWidth = cell.bounds.size.width;
    UIView *loadingView = [[UIView alloc] initWithFrame:CGRectMake(cellWidth - 50, 10, 40, 40)];
    [loadingView addSubview:activityIndicatorView];
    dispatch_async(dispatch_get_main_queue(), ^{
        [activityIndicatorView startAnimating];
        [cell addSubview:loadingView];
    });
    __weak typeof(self) weakSelf = self;
    [[RCDIMService sharedService] clearHistoryMessage:ConversationType_GROUP targetId:weakSelf.group.groupId successBlock:^{
        [weakSelf showAlert:RCDLocalizedString(@"clear_chat_history_success")];
        [loadingView removeFromSuperview];
        weakSelf.clearMessageHistory();
    } errorBlock:^(RCErrorCode status) {
        [weakSelf showAlert:RCDLocalizedString(@"clear_chat_history_fail")];
        [loadingView removeFromSuperview];
    }];
}

- (void)clearConversationAndMessage{
    NSArray *latestMessages = [[RCIMClient sharedRCIMClient] getLatestMessages:ConversationType_GROUP targetId:self.group.groupId count:1];
    if (latestMessages.count > 0) {
        RCMessage *message = (RCMessage *)[latestMessages firstObject];
        [[RCIMClient sharedRCIMClient]clearRemoteHistoryMessages:ConversationType_GROUP targetId:self.group.groupId recordTime:message.sentTime success:^{
            [[RCIMClient sharedRCIMClient] clearMessages:ConversationType_GROUP targetId:self.group.groupId];
        }error:nil];
    }
    [[RCIMClient sharedRCIMClient] removeConversation:ConversationType_GROUP targetId:self.group.groupId];
}

- (void)refreshGroupMemberInfo{
    __weak typeof(self) weakSelf = self;
    [RCDGroupManager getGroupMembersFromServer:self.group.groupId complete:^(NSArray<NSString *> * _Nonnull memberIdList) {
        if(memberIdList){
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.title = [NSString stringWithFormat:RCDLocalizedString(@"group_information_x"),[NSString stringWithFormat:@"%lu",(unsigned long)memberIdList.count]];
            });
            weakSelf.memberList = [weakSelf resetMemberList:memberIdList];
            weakSelf.headerDisplayMembers = [weakSelf getHeaderDisplayMemberData];
            [weakSelf setHeaderView];
            
        }
     }];
}

- (NSArray *)getHeaderDisplayMemberData{
    NSMutableArray *mutableArray = [NSMutableArray array];
    if (self.memberList.count <= 18) {
        mutableArray = self.memberList.mutableCopy;
    }else{
        for (int i = 0 ;i < 18;i++) {
            [mutableArray addObject:self.memberList[i]];
        }
    }
    return mutableArray.copy;
}

- (void)refreshGroupInfo {
    self.group = [RCDGroupManager getGroupInfo:self.group.groupId];
    __weak typeof(self) weakSelf = self;
    [RCDGroupManager getGroupInfoFromServer:self.group.groupId complete:^(RCDGroupInfo * _Nonnull groupInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (groupInfo) {
                weakSelf.group = groupInfo;
            }
            [weakSelf.tableView reloadData];
        });
    }];
}

- (void)setCurrentNotificationStatus:(UISwitch *)switchButton{
    [[RCIMClient sharedRCIMClient] getConversationNotificationStatus:ConversationType_GROUP targetId:self.group.groupId success:^(RCConversationNotificationStatus nStatus) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switchButton.on = !nStatus;
        });
    }error:^(RCErrorCode status){
        
    }];
}

- (void)showAlert:(NSString *)alertContent {
    [NormalAlertView showAlertWithTitle:nil message:alertContent describeTitle:nil confirmTitle:RCDLocalizedString(@"confirm") confirm:^{
    }];
}

- (void)showActionSheet:(NSString *)title tag:(NSInteger)tag{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                             delegate:self
                                                    cancelButtonTitle:RCDLocalizedString(@"cancel")
                                               destructiveButtonTitle:RCDLocalizedString(@"confirm")
                                                    otherButtonTitles:nil];
    [actionSheet showInView:self.view];
    actionSheet.tag = tag;
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
        [self.headerView reloadData:self.headerDisplayMembers];
        self.headerView.frame =
            CGRectMake(0, 0, RCDScreenWidth, self.headerView.collectionViewLayout.collectionViewContentSize.height);
        CGRect frame = self.headerView.frame;
        frame.size.height += 14;
        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:frame];
        self.tableView.tableHeaderView.backgroundColor = [UIColor whiteColor];
        [self.tableView.tableHeaderView addSubview:self.headerView];

        UIView *separatorLine =
            [[UIView alloc] initWithFrame:CGRectMake(10, frame.size.height - 1, frame.size.width - 10, 1)];
        separatorLine.backgroundColor = [UIColor colorWithRed:230 / 255.0 green:230 / 255.0 blue:230 / 255.0 alpha:1];
        [self.tableView.tableHeaderView addSubview:separatorLine];
    });
}

- (void)setTableFooterView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 150)];
    UIButton *joinOrQuitGroupBtn = [[UIButton alloc] init];
    [joinOrQuitGroupBtn setBackgroundImage:[UIImage imageNamed:@"group_quit"] forState:UIControlStateNormal];
    [joinOrQuitGroupBtn setBackgroundImage:[UIImage imageNamed:@"group_quit_hover"] forState:UIControlStateSelected];
    [joinOrQuitGroupBtn setTitle:RCDLocalizedString(@"delete_and_exit")
                        forState:UIControlStateNormal];
    joinOrQuitGroupBtn.layer.cornerRadius = 5.f;
    joinOrQuitGroupBtn.layer.borderWidth = 0.5f;
    joinOrQuitGroupBtn.layer.borderColor = [HEXCOLOR(0xcc4445) CGColor];
    [view addSubview:joinOrQuitGroupBtn];
    [joinOrQuitGroupBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *views = NSDictionaryOfVariableBindings(joinOrQuitGroupBtn);
    if ([[RCDGroupManager getGroupOwner:self.group.groupId] isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
        [joinOrQuitGroupBtn setTitle:RCDLocalizedString(@"DisbandAndDelete") forState:UIControlStateNormal];
        [joinOrQuitGroupBtn addTarget:self action:@selector(btnDismissAction:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [joinOrQuitGroupBtn setTitle:RCDLocalizedString(@"delete_and_exit")
                            forState:UIControlStateNormal];
        [joinOrQuitGroupBtn addTarget:self action:@selector(btnJOQAction:) forControlEvents:UIControlEventTouchUpInside];
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
    [[RCIMClient sharedRCIMClient] setConversationNotificationStatus:ConversationType_GROUP targetId:self.group.groupId isBlocked:swch.on success:^(RCConversationNotificationStatus nStatus) {
        NSLog(@"成功");
    }error:^(RCErrorCode status) {
        NSLog(@"失败");
    }];
}

- (void)clickIsTopBtn:(id)sender {
    UISwitch *swch = sender;
    [[RCIMClient sharedRCIMClient] setConversationToTop:ConversationType_GROUP targetId:self.group.groupId isTop:swch.on];
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
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:RCDLocalizedString(@"cancel") destructiveButtonTitle:nil otherButtonTitles:RCDLocalizedString(@"take_picture"),RCDLocalizedString(@"my_album"), nil];
        actionSheet.tag = 200;
        [actionSheet showInView:self.view];
    } else {
        [self showAlert:RCDLocalizedString(@"Only_the_owner_can_change_the_group_portrait")];
    }
}

- (void)pushImagePickVC:(NSInteger)buttonIndex{
    if (buttonIndex <= 1) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.allowsEditing = YES;
        picker.delegate = self;
        if (buttonIndex == 0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }else if (buttonIndex == 1){
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        [self presentViewController:picker animated:YES completion:nil];
    }
}

#pragma mark - getter & setter
- (RCDUserListCollectionView *)headerView{
    if (!_headerView) {
        CGRect tempRect =
        CGRectMake(0, 0, RCDScreenWidth, _headerView.collectionViewLayout.collectionViewContentSize.height);
        NSString *currentUserId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
        NSString *groupOwnerId = [RCDGroupManager getGroupOwner:self.group.groupId];
        NSArray<NSString *> *groupManagers = [RCDGroupManager getGroupManagers:self.group.groupId];
        BOOL isCreator = NO;
        //群主，管理员都可以删除群成员
        if([groupOwnerId isEqualToString:currentUserId] || [groupManagers containsObject:currentUserId]) {
            isCreator = YES;
        }
        _headerView = [[RCDUserListCollectionView alloc] initWithFrame:tempRect isAllowAdd:YES isAllowDelete:isCreator];
        _headerView.userListCollectionViewDelegate = self;
    }
    return _headerView;
}
@end
