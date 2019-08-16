//
//  RCDPersonDetailViewController.m
//  SealTalk
//
//  Created by 孙浩 on 2019/5/30.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDPersonDetailViewController.h"
#import "RCDPersonInfoView.h"
#import "RCDRemarksView.h"
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

typedef NS_ENUM(NSInteger, RCDPersonOperation) {
    RCDPersonOperationDelete = 0,
    RCDPersonOperationAddToBlacklist,
    RCDPersonOperationRemoveFromBlacklist,
};

@interface RCDPersonDetailViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) RCDPersonInfoView *infoView;
@property (nonatomic, strong) RCDRemarksView *remarksView;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIButton *conversationButton;
@property (nonatomic, strong) UIButton *audioCallButton;
@property (nonatomic, strong) UIButton *videoCallButton;

@property (nonatomic, strong) RCDFriendInfo *userInfo;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, assign) BOOL inBlacklist;

@property (nonatomic, assign) RCDPersonOperation operation;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation RCDPersonDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubviews];
    [self getUserInfoData];
}

#pragma mark - Private Method
- (void)setupSubviews {
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"f0f0f6" alpha:1.f];
    [self.view addSubview:self.infoView];
    [self.view addSubview:self.conversationButton];
    [self.view addSubview:self.audioCallButton];
    [self.view addSubview:self.videoCallButton];
    
    [self.infoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.offset(85);
    }];
    
    UIView *lastView = nil;
    if ([self isCurrentUser]) {
        lastView = self.infoView;
    } else {
        [self.view addSubview:self.remarksView];
        [self.view addSubview:self.tableView];
        [self.remarksView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.infoView.mas_bottom).offset(15);
            make.left.right.equalTo(self.infoView);
            make.height.offset(43);
        }];
        
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.remarksView.mas_bottom).offset(15);
            make.left.right.equalTo(self.view);
            make.height.offset(88);
        }];
        lastView = self.tableView;
    }
    
    [self.conversationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lastView.mas_bottom).offset(15);
        make.left.right.equalTo(self.view).inset(10);
        make.height.offset(43);
    }];
    
    [self.audioCallButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.conversationButton.mas_bottom).offset(15);
        make.left.right.equalTo(self.view).inset(10);
        make.height.offset(43);
    }];
    
    [self.videoCallButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.audioCallButton.mas_bottom).offset(15);
        make.left.right.equalTo(self.view).inset(10);
        make.height.offset(43);
    }];
}

- (void)getUserInfoData {
    if ([self isCurrentUser]) {
        NSString *currentUserId = [RCIM sharedRCIM].currentUserInfo.userId;
        RCDUserInfo *currentUserInfo = [RCDUserInfoManager getUserInfo:currentUserId];
        self.userInfo = [[RCDFriendInfo alloc] initWithUserId:currentUserInfo.userId name:currentUserInfo.name portrait:currentUserInfo.portraitUri];
        self.userInfo.stAccount = currentUserInfo.stAccount;
        self.userInfo.gender = currentUserInfo.gender;
        [self.infoView setUserInfo:self.userInfo];
    } else {
        [self.hud showAnimated:YES];
        [RCDUserInfoManager getFriendInfoFromServer:self.userId complete:^(RCDFriendInfo *friendInfo) {
            rcd_dispatch_main_async_safe(^{
                if (friendInfo) {
                    self.userInfo = friendInfo;
                    if (friendInfo.status == RCDFriendStatusAgree) {
                        self.inBlacklist = NO;
                    } else if (friendInfo.status == RCDFriendStatusBlock) {
                        self.inBlacklist = YES;
                    }
                } else {
                    self.userInfo = [RCDUserInfoManager getFriendInfo:self.userId];
                    self.inBlacklist = [RCDUserInfoManager isInBlacklist:self.userId];
                }
                [self.tableView reloadData];
                [self.hud hideAnimated:YES];
                [self.infoView setUserInfo:self.userInfo];
            });
        }];
    }
}

- (BOOL)isCurrentUser {
    BOOL isCurrentUser = [self.userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId];
    return isCurrentUser;
}

- (void)showAlertWithMessage:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:RCDLocalizedString(@"confirm") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)showAlertWithMessage:(NSString *)message highlightText:(NSString *)highlightText leftTitle:(NSString *)leftTitle rightTitle:(NSString *)rightTitle {
    
    [NormalAlertView showAlertWithMessage:message highlightText:highlightText leftTitle:leftTitle rightTitle:rightTitle cancel:^{
    } confirm:^{
        if (self.operation == RCDPersonOperationDelete) {
            [self deleteFriend];
        } else {
            [self dealWithBlacklist];
        }
    }];
    
}

- (void)tapRemarksView:(UIGestureRecognizer *)tap {
    RCDFriendRemarksViewController *vc = [[RCDFriendRemarksViewController alloc] init];
    vc.setRemarksSuccess = ^{
        [self getUserInfoData];
    };
    vc.friendInfo = self.userInfo;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)dealWithBlacklist {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (!self.inBlacklist) {
        __weak typeof(self) weakSelf = self;
        hud.labelText = RCDLocalizedString(@"adding_to_blacklist");
        [RCDUserInfoManager addToBlacklist:self.userId complete:^(BOOL success) {
            if (success) {
                weakSelf.inBlacklist = YES;
                [[RCIMClient sharedRCIMClient] clearMessages:ConversationType_PRIVATE targetId:weakSelf.userId];
                [[RCIMClient sharedRCIMClient] removeConversation:ConversationType_PRIVATE targetId:weakSelf.userId];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [RCDDataSource syncFriendList];
                    [weakSelf.tableView reloadData];
                    [hud hide:YES];
                    [self.view showHUDMessage:RCDLocalizedString(@"HasAddBlacklist")];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [hud hide:YES];
                    [weakSelf showAlertWithMessage:RCDLocalizedString(@"fail_to_add_to_blacklist")];
                });
            }
        }];
    } else {
        hud.labelText = RCDLocalizedString(@"removing_from_blacklist");
        __weak typeof(self) weakSelf = self;
        [RCDUserInfoManager removeFromBlacklist:self.userId complete:^(BOOL success) {
            if (success) {
                weakSelf.inBlacklist = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [RCDDataSource syncFriendList];
                    [weakSelf.tableView reloadData];
                    [hud hide:YES];
                    [weakSelf.view showHUDMessage:RCDLocalizedString(@"HasRemoveBlacklist")];
                });
            }else{
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
    [RCDUserInfoManager deleteFriend:self.userId complete:^(BOOL success) {
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

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDPersonDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PersonDetailCellReuseIdentifier"];
    if (!cell) {
        cell = [[RCDPersonDetailCell alloc] init];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {
        NSString *blackString = self.inBlacklist ? RCDLocalizedString(@"cancel_block") : RCDLocalizedString(@"add_to_blacklist");
        cell.titleLabel.text = blackString;
    } else{
        cell.titleLabel.text = RCDLocalizedString(@"DeleteFriend");
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        self.operation = self.inBlacklist ? RCDPersonOperationRemoveFromBlacklist : RCDPersonOperationAddToBlacklist;
        NSString *hintString = self.inBlacklist ? RCDLocalizedString(@"cancel_block") : RCDLocalizedString(@"AddToBlacklistHintMessage");
        
        [self showAlertWithMessage:hintString highlightText:nil leftTitle:RCDLocalizedString(@"cancel") rightTitle:RCDLocalizedString(@"confirm")];
    } else {
        self.operation = RCDPersonOperationDelete;
        [self showAlertWithMessage:[NSString stringWithFormat:RCDLocalizedString(@"DeleteFriendHindMessage"),self.userInfo.name] highlightText:self.userInfo.name leftTitle:RCDLocalizedString(@"cancel") rightTitle:RCDLocalizedString(@"Delete")];
    }
}

#pragma mark - Setter && Getter
- (RCDPersonInfoView *)infoView {
    if (!_infoView) {
        _infoView = [[RCDPersonInfoView alloc] init];
    }
    return _infoView;
}

- (RCDRemarksView *)remarksView {
    if (!_remarksView) {
        _remarksView = [[RCDRemarksView alloc] init];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRemarksView:)];
        [_remarksView addGestureRecognizer:tap];
    }
    return _remarksView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = [UIColor colorWithHexString:@"FFFFFF" alpha:1];
        _tableView.separatorColor = [UIColor colorWithHexString:@"E5E5E5" alpha:1];
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _tableView.bounds.size.width, 0.01f)];
    }
    return _tableView;
}

- (UIButton *)conversationButton {
    if (!_conversationButton) {
        _conversationButton = [[UIButton alloc] init];
        _conversationButton.backgroundColor = [UIColor colorWithHexString:@"0099ff" alpha:1.f];
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
        _audioCallButton.backgroundColor = [UIColor whiteColor];
        [_audioCallButton setTitle:RCDLocalizedString(@"voice_call") forState:UIControlStateNormal];
        [_audioCallButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
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
        _videoCallButton.backgroundColor = [UIColor whiteColor];
        [_videoCallButton setTitle:RCDLocalizedString(@"video_call") forState:UIControlStateNormal];
        [_videoCallButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_videoCallButton addTarget:self action:@selector(videoCall:) forControlEvents:UIControlEventTouchUpInside];
        _videoCallButton.translatesAutoresizingMaskIntoConstraints = NO;
        _videoCallButton.layer.masksToBounds = YES;
        _videoCallButton.layer.cornerRadius = 5.f;
    }
    return _videoCallButton;
}

- (MBProgressHUD *)hud {
    if(!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.color = [UIColor colorWithHexString:@"343637" alpha:0.8];
    }
    return _hud;
}

@end
