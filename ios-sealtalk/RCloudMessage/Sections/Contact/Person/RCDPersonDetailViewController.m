//
//  RCDPersonDetailViewController.m
//  SealTalk
//
//  Created by 孙浩 on 2019/5/30.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDPersonDetailViewController.h"
#import "RCDPersonInfoView.h"
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>
#import <RongIMKit/RongIMKit.h>
#import "RCDDBManager.h"
#import "RCDUtilities.h"
#import "RCDFriendRemarksViewController.h"
#import "RCDChatViewController.h"
#import <RongCallKit/RongCallKit.h>
#import "UIView+MBProgressHUD.h"
#import "RCDUserInfoManager.h"
#import "RCDPersonDetailCell.h"
#import "NormalAlertView.h"
#import "RCDCommonString.h"
#import "RCDRCIMDataSource.h"
#import "RCDBaseSettingTableViewCell.h"
#import "RCDAddFriendViewController.h"
#import "RCDGroupMemberDetailController.h"
#import "RCDGroupManager.h"

typedef NS_ENUM(NSInteger, RCDPersonOperation) {
    RCDPersonOperationDelete = 0,
    RCDPersonOperationAddToBlacklist,
    RCDPersonOperationRemoveFromBlacklist,
};

typedef NS_ENUM(NSInteger, RCDFriendDescriptionType) {
    RCDFriendDescriptionTypeDefault = 0,
    RCDFriendDescriptionTypeAll,
    RCDFriendDescriptionTypePhone,
    RCDFriendDescriptionTypeDesc,
};

@interface RCDPersonDetailViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSString *groupId;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) RCDPersonInfoView *infoView;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIButton *conversationButton;
@property (nonatomic, strong) UIButton *audioCallButton;
@property (nonatomic, strong) UIButton *videoCallButton;

@property (nonatomic, strong) RCDFriendInfo *userInfo;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, assign) BOOL inBlacklist;

@property (nonatomic, assign) RCDPersonOperation operation;
@property (nonatomic, strong) RCDFriendDescription *friendDescription;
@property (nonatomic, assign) BOOL isLoadFriendDescription;
@property (nonatomic, assign) RCDFriendDescriptionType descriptionType;

@property (nonatomic, assign) CGFloat tableViewHeight;

@end

@implementation RCDPersonDetailViewController
+ (UIViewController *)configVC:(NSString *)userId groupId:(NSString *)groupId {
    RCDFriendInfo *friendInfo = [RCDUserInfoManager getFriendInfo:userId];
    if ((friendInfo != nil &&
         (friendInfo.status == RCDFriendStatusAgree || friendInfo.status == RCDFriendStatusBlock)) ||
        [userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
        RCDPersonDetailViewController *detailViewController = [[RCDPersonDetailViewController alloc] init];
        detailViewController.userId = userId;
        detailViewController.groupId = groupId;
        return detailViewController;
    } else {
        RCDAddFriendViewController *addViewController = [[RCDAddFriendViewController alloc] init];
        addViewController.groupId = groupId;
        addViewController.targetUserId = userId;
        return addViewController;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupSubviews];
    [self getUserInfoData];
}

#pragma mark - Private Method
- (void)setupSubviews {
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.contentView];
    [self.contentView addSubview:self.infoView];
    [self.contentView addSubview:self.conversationButton];

    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.width.height.equalTo(self.view);
    }];

    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];

    [self.infoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.contentView);
        make.height.offset(85);
    }];

    UIView *lastView = nil;
    if ([self isCurrentUser]) {
        lastView = self.infoView;
    } else {
        [self.contentView addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.infoView.mas_bottom);
            make.left.right.equalTo(self.contentView);
            make.height.offset(self.tableView.contentSize.height - 30);
        }];
        lastView = self.tableView;
    }

    if (![self isCurrentUser]) {
        [self.contentView addSubview:self.audioCallButton];
        [self.contentView addSubview:self.videoCallButton];
        [self.conversationButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lastView.mas_bottom).offset(15);
            make.left.right.equalTo(self.contentView).inset(10);
            make.height.offset(43);
        }];
        [self.audioCallButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.conversationButton.mas_bottom).offset(15);
            make.left.right.equalTo(self.contentView).inset(10);
            make.height.offset(43);
        }];
        [self.videoCallButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.audioCallButton.mas_bottom).offset(15);
            make.left.right.equalTo(self.contentView).inset(10);
            make.height.offset(43);
            make.bottom.equalTo(self.contentView).offset(-15);
        }];
    } else {
        [self.conversationButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lastView.mas_bottom).offset(15);
            make.left.right.equalTo(self.contentView).inset(10);
            make.height.offset(43);
            make.bottom.equalTo(self.contentView).offset(-15);
        }];
    }
}

- (void)getUserInfoData {
    if ([self isCurrentUser]) {
        NSString *currentUserId = [RCIM sharedRCIM].currentUserInfo.userId;
        RCDUserInfo *currentUserInfo = [RCDUserInfoManager getUserInfo:currentUserId];
        self.userInfo = [[RCDFriendInfo alloc] initWithUserId:currentUserInfo.userId
                                                         name:currentUserInfo.name
                                                     portrait:currentUserInfo.portraitUri];
        self.userInfo.stAccount = currentUserInfo.stAccount;
        self.userInfo.gender = currentUserInfo.gender;
        [self.infoView setUserInfo:self.userInfo];
    } else {
        self.userInfo = [RCDUserInfoManager getFriendInfo:self.userId];
        [self handleIsInBlockList];
        [self.infoView setUserInfo:self.userInfo];
        [RCDUserInfoManager getFriendInfoFromServer:self.userId
                                           complete:^(RCDFriendInfo *friendInfo) {
                                               rcd_dispatch_main_async_safe(^{
                                                   if (friendInfo) {
                                                       self.userInfo = friendInfo;
                                                   } else {
                                                       self.userInfo = [RCDUserInfoManager getFriendInfo:self.userId];
                                                   }
                                                   [self handleIsInBlockList];
                                                   [self.tableView reloadData];
                                                   [self.infoView setUserInfo:self.userInfo];
                                               });
                                           }];
        [self getFriendDescription];
    }
    if (self.groupId.length > 0) {
        RCDGroupMember *member = [RCDGroupManager getGroupMember:self.userId groupId:self.groupId];
        [self.infoView setGroupNickname:member.groupNickname];
    }
}

- (void)handleIsInBlockList {
    if (self.userInfo.status == RCDFriendStatusAgree) {
        self.inBlacklist = NO;
    } else if (self.userInfo.status == RCDFriendStatusBlock) {
        self.inBlacklist = YES;
    }
}

- (void)getFriendDescription {
    self.friendDescription = [RCDUserInfoManager getFriendDescription:self.userId];
    if (!self.friendDescription && !self.isLoadFriendDescription) {
        self.isLoadFriendDescription = YES;
        [RCDUserInfoManager getDescriptionFromServer:self.userId
                                            complete:^(RCDFriendDescription *description) {
                                                rcd_dispatch_main_async_safe(^{
                                                    self.friendDescription = description;
                                                    [self setupDescriptionType];
                                                    [self.tableView reloadData];
                                                    [self updateTableView];
                                                });
                                            }];
    } else {
        [self setupDescriptionType];
        [self.tableView reloadData];
        [self updateTableView];
    }
}

- (void)updateTableView {
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.infoView.mas_bottom);
        make.left.right.equalTo(self.contentView);
        make.height.offset(self.tableViewHeight);
    }];
}

- (void)setupDescriptionType {
    if (!self.friendDescription) {
        return;
    }
    if (self.friendDescription.phone.length > 0 && self.friendDescription.desc.length > 0) {
        self.descriptionType = RCDFriendDescriptionTypeAll;
    } else if (self.friendDescription.phone.length > 0) {
        self.descriptionType = RCDFriendDescriptionTypePhone;
    } else if (self.friendDescription.desc.length > 0) {
        self.descriptionType = RCDFriendDescriptionTypeDesc;
    } else {
        self.descriptionType = RCDFriendDescriptionTypeDefault;
    }
    [self calculateTableViewHeight];
}

- (void)calculateTableViewHeight {
    // 跟 numberOfRowsInSection 逻辑对应
    NSInteger rows = 2;
    if (self.descriptionType == RCDFriendDescriptionTypeDefault) {
        rows += 1;
    } else {
        rows += 2;
    }
    if (self.groupId.length > 0) {
        rows += 1;
    }
    self.tableViewHeight = rows * 44 + 2 * 15;
}

- (BOOL)isCurrentUser {
    BOOL isCurrentUser = [self.userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId];
    return isCurrentUser;
}

- (void)showAlertWithMessage:(NSString *)message {
    [RCAlertView showAlertController:nil message:message cancelTitle:RCDLocalizedString(@"confirm") inViewController:self];
}

- (void)showAlertWithMessage:(NSString *)message
               highlightText:(NSString *)highlightText
                   leftTitle:(NSString *)leftTitle
                  rightTitle:(NSString *)rightTitle {

    [NormalAlertView showAlertWithMessage:message
        highlightText:highlightText
        leftTitle:leftTitle
        rightTitle:rightTitle
        cancel:^{
        }
        confirm:^{
            if (self.operation == RCDPersonOperationDelete) {
                [self deleteFriend];
            } else {
                [self dealWithBlacklist];
            }
        }];
}

- (void)pushGroupMemberInfoVC {
    RCDGroupMemberDetailController *vc = [[RCDGroupMemberDetailController alloc] init];
    vc.userId = self.userId;
    vc.groupId = self.groupId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushToRemarksVC {
    RCDFriendRemarksViewController *vc = [[RCDFriendRemarksViewController alloc] init];
    vc.setRemarksSuccess = ^{
        [self getUserInfoData];
    };
    vc.friendId = self.userId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)dealWithBlacklist {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (!self.inBlacklist) {
        __weak typeof(self) weakSelf = self;
        hud.labelText = RCDLocalizedString(@"adding_to_blacklist");
        [RCDUserInfoManager
            addToBlacklist:self.userId
                  complete:^(BOOL success) {
                      if (success) {
                          weakSelf.inBlacklist = YES;
                          [[RCIMClient sharedRCIMClient] clearMessages:ConversationType_PRIVATE
                                                              targetId:weakSelf.userId];
                          [[RCIMClient sharedRCIMClient] removeConversation:ConversationType_PRIVATE
                                                                   targetId:weakSelf.userId];
                          dispatch_async(dispatch_get_main_queue(), ^{
                              [RCDDataSource syncFriendList];
                              [weakSelf.tableView reloadData];
                              [hud hide:YES];
                              [self.view showHUDMessage:RCDLocalizedString(@"HasAddBlacklist")];
                          });
                      } else {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              [hud hide:YES];
                              [weakSelf showAlertWithMessage:RCDLocalizedString(@"fail_to_add_to_blacklist")];
                          });
                      }
                  }];
    } else {
        hud.labelText = RCDLocalizedString(@"removing_from_blacklist");
        __weak typeof(self) weakSelf = self;
        [RCDUserInfoManager
            removeFromBlacklist:self.userId
                       complete:^(BOOL success) {
                           if (success) {
                               weakSelf.inBlacklist = NO;
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [RCDDataSource syncFriendList];
                                   [weakSelf.tableView reloadData];
                                   [hud hide:YES];
                                   [weakSelf.view showHUDMessage:RCDLocalizedString(@"HasRemoveBlacklist")];
                               });
                           } else {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [hud hide:YES];
                                   [weakSelf showAlertWithMessage:RCDLocalizedString(@"fail_to_remove_from_blacklist")];
                               });
                           }
                       }];
    }
}

- (void)deleteFriend {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [RCDUserInfoManager deleteFriend:self.userId
                            complete:^(BOOL success) {
                                rcd_dispatch_main_async_safe(^{
                                    [hud hideAnimated:YES];
                                    if (success) {
                                        [self.view showHUDMessage:RCDLocalizedString(@"DeleteSuccess")];
                                        [RCDDataSource syncFriendList];
                                        [self.navigationController popToRootViewControllerAnimated:YES];
                                    } else {
                                        [self.view showHUDMessage:RCDLocalizedString(@"DeleteFailure")];
                                    }
                                });
                            }];
}

- (void)startChat:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeTabBarIndex" object:@0];
    RCDChatViewController *chatVC = [[RCDChatViewController alloc] init];
    chatVC.conversationType = ConversationType_PRIVATE;
    chatVC.targetId = self.userId;
    NSString *title;
    if ([self isCurrentUser]) {
        title = [RCIM sharedRCIM].currentUserInfo.name;
    } else {
        if (self.userInfo.displayName.length > 0) {
            title = self.userInfo.displayName;
        } else {
            title = self.userInfo.name;
        }
    }
    chatVC.title = title;
    chatVC.needPopToRootView = YES;
    chatVC.displayUserNameInCell = NO;
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (void)audioCall:(UIButton *)sender {
//语音通话
    [[RCCall sharedRCCall] startSingleCall:self.userInfo.userId mediaType:RCCallMediaAudio];
}

- (void)videoCall:(UIButton *)sender {
//视频通话
    [[RCCall sharedRCCall] startSingleCall:self.userInfo.userId mediaType:RCCallMediaVideo];
}

- (void)presentActionSheet {
    [RCActionSheetView showActionSheetView:nil cellArray:@[RCDLocalizedString(@"Call"), RCDLocalizedString(@"CopyNumber")] cancelTitle:RCDLocalizedString(@"cancel") selectedBlock:^(NSInteger index) {
        [self alertActionDidClickIndex:index];
    } cancelBlock:^{
            
    }];
}

- (void)alertActionDidClickIndex:(NSInteger)index{
    if (index == 0) {
        if (self.friendDescription.phone) {
            NSURL *phoneUrl = [NSURL
                URLWithString:[NSString stringWithFormat:@"tel://%@", self.friendDescription.phone]];
            if (IOS_FSystenVersion > 10) {
                [[UIApplication sharedApplication] openURL:phoneUrl options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:phoneUrl];
            }
        }
    }else{
        if (self.friendDescription.phone) {
            UIPasteboard *pastboard =
                [UIPasteboard generalPasteboard];
            [pastboard setString:self.friendDescription.phone];
        }
    }
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        NSInteger row = 0;
        if (self.descriptionType == RCDFriendDescriptionTypeDefault) {
            row = 1;
        } else {
            row = 2;
        }
        if (self.groupId.length > 0) {
            row = row + 1;
        }
        return row;
    } else {
        return 2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, RCDScreenWidth, 15)];
    view.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDPersonDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PersonDetailSettingReuseIdentifier"];
    if (!cell) {
        cell = [[RCDPersonDetailCell alloc] init];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        switch (self.descriptionType) {
        case RCDFriendDescriptionTypeAll:
        case RCDFriendDescriptionTypePhone:
        case RCDFriendDescriptionTypeDesc: {
            [cell setCellStyle:Style_Title_Detail];
            if (indexPath.row == 0) {
                cell.detailLabel.textColor = [UIColor colorWithHexString:@"0099FF" alpha:1];
                cell.titleLabel.text = RCDLocalizedString(@"PhoneNumber");
                cell.detailLabel.text = self.friendDescription.phone;
                cell.detailLabel.userInteractionEnabled = YES;
                cell.tapDetailBlock = ^(NSString *_Nonnull detail) {
                    rcd_dispatch_main_async_safe(^{
                        [self presentActionSheet];
                    });
                };
            } else {
                cell.detailLabel.textColor = [UIColor colorWithHexString:@"999999" alpha:1];
                cell.titleLabel.text = RCDLocalizedString(@"Describe");
                cell.detailLabel.text = self.friendDescription.desc;
                cell.detailLabel.userInteractionEnabled = NO;
            }
        } break;
        case RCDFriendDescriptionTypeDefault:
        default: {
            [cell setCellStyle:Style_Default];
            cell.titleLabel.text = RCDLocalizedString(@"SetRemarksAndDescription");
        } break;
        }
        if (self.groupId.length > 0) {
            NSInteger count = [self tableView:tableView numberOfRowsInSection:0];
            if (indexPath.row == count - 1) {
                [cell setCellStyle:Style_Default];
                cell.titleLabel.text = RCDLocalizedString(@"Personal_information");
            }
        }
        return cell;
    } else {
        [cell setCellStyle:Style_Default];
        if (indexPath.row == 0) {
            NSString *blackString =
                self.inBlacklist ? RCDLocalizedString(@"cancel_block") : RCDLocalizedString(@"add_to_blacklist");
            cell.titleLabel.text = blackString;
        } else {
            cell.titleLabel.text = RCDLocalizedString(@"DeleteFriend");
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        if (self.groupId.length > 0) {
            NSInteger count = [self tableView:tableView numberOfRowsInSection:0];
            if (indexPath.row == count - 1) {
                [self pushGroupMemberInfoVC];
            } else {
                [self pushToRemarksVC];
            }
        } else {
            [self pushToRemarksVC];
        }
    } else {
        if (indexPath.row == 0) {
            self.operation =
                self.inBlacklist ? RCDPersonOperationRemoveFromBlacklist : RCDPersonOperationAddToBlacklist;
            NSString *hintString = self.inBlacklist ? RCDLocalizedString(@"cancel_block")
                                                    : RCDLocalizedString(@"AddToBlacklistHintMessage");

            [self showAlertWithMessage:hintString
                         highlightText:nil
                             leftTitle:RCDLocalizedString(@"cancel")
                            rightTitle:RCDLocalizedString(@"confirm")];
        } else {
            self.operation = RCDPersonOperationDelete;
            [self showAlertWithMessage:[NSString stringWithFormat:RCDLocalizedString(@"DeleteFriendHindMessage"),
                                                                  self.userInfo.name]
                         highlightText:self.userInfo.name
                             leftTitle:RCDLocalizedString(@"cancel")
                            rightTitle:RCDLocalizedString(@"Delete")];
        }
    }
}

#pragma mark - Setter && Getter
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
    }
    return _scrollView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}

- (RCDPersonInfoView *)infoView {
    if (!_infoView) {
        _infoView = [[RCDPersonInfoView alloc] init];
    }
    return _infoView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

- (UIButton *)conversationButton {
    if (!_conversationButton) {
        _conversationButton = [[UIButton alloc] init];
        _conversationButton.backgroundColor = RCDDYCOLOR(0x0099ff, 0x007acc);
        _conversationButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_conversationButton setTitle:RCDLocalizedString(@"start_chat") forState:UIControlStateNormal];
        [_conversationButton addTarget:self action:@selector(startChat:) forControlEvents:UIControlEventTouchUpInside];
        _conversationButton.layer.masksToBounds = YES;
        _conversationButton.layer.cornerRadius = 5.f;
        _conversationButton.layer.borderWidth = 0.5;
        _conversationButton.layer.borderColor = [UIColor colorWithHexString:@"0181dd" alpha:1].CGColor;
    }
    return _conversationButton;
}

- (UIButton *)audioCallButton {
    if (!_audioCallButton) {
        _audioCallButton = [[UIButton alloc] init];
        _audioCallButton.backgroundColor = RCDDYCOLOR(0xffffff, 0x1c1c1e);
        [_audioCallButton setTitle:RCDLocalizedString(@"voice_call") forState:UIControlStateNormal];
        [_audioCallButton setTitleColor:RCDDYCOLOR(0x000000, 0x9f9f9f) forState:UIControlStateNormal];
        [_audioCallButton addTarget:self action:@selector(audioCall:) forControlEvents:UIControlEventTouchUpInside];
        _audioCallButton.translatesAutoresizingMaskIntoConstraints = NO;
        _audioCallButton.layer.masksToBounds = YES;
        _audioCallButton.layer.cornerRadius = 5.f;
    }
    return _audioCallButton;
}

- (UIButton *)videoCallButton {
    if (!_videoCallButton) {
        _videoCallButton = [[UIButton alloc] init];
        _videoCallButton.backgroundColor = RCDDYCOLOR(0xffffff, 0x1c1c1e);
        [_videoCallButton setTitle:RCDLocalizedString(@"video_call") forState:UIControlStateNormal];
        [_videoCallButton setTitleColor:RCDDYCOLOR(0x000000, 0x9f9f9f) forState:UIControlStateNormal];
        [_videoCallButton addTarget:self action:@selector(videoCall:) forControlEvents:UIControlEventTouchUpInside];
        _videoCallButton.translatesAutoresizingMaskIntoConstraints = NO;
        _videoCallButton.layer.masksToBounds = YES;
        _videoCallButton.layer.cornerRadius = 5.f;
    }
    return _videoCallButton;
}

@end
