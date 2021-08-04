//
//  RCDAddFriendViewController.m
//  RCloudMessage
//
//  Created by Liv on 15/4/16.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDAddFriendViewController.h"
#import "DefaultPortraitView.h"
#import "RCDChatViewController.h"
#import "UIColor+RCColor.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>
#import "RCDUserInfoManager.h"
#import "RCDGroupManager.h"
#import "RCDCommonString.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "RCDRCIMDataSource.h"
#import "RCDBaseSettingTableViewCell.h"
#import "RCDGroupMemberDetailController.h"
@interface RCDAddFriendViewController ()
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *portraitImgView;
@property (nonatomic, strong) UIImageView *genderImgView;
@property (nonatomic, strong) UILabel *stAccountLabel;
@property (nonatomic, strong) UIButton *addFriendBtn;
@property (nonatomic, strong) UIButton *startChatBtn;
@property (nonatomic, strong) UILabel *groupNicknameLabel;

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) RCDGroupInfo *groupInfo;
@property (nonatomic, strong) RCDUserInfo *targetUserInfo;
@end

@implementation RCDAddFriendViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.groupInfo = [RCDGroupManager getGroupInfo:self.groupId];
    [self setupNavi];
    [self setupTableView];
    [self getUserInfo];
    [self setGroupMemberInfo];
    [self updateNameLayout];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.groupId.length > 0) {
        return 1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDBaseSettingTableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"PersonDetailSettingReuseIdentifier"];
    if (!cell) {
        cell = [[RCDBaseSettingTableViewCell alloc] init];
    }
    [cell setCellStyle:DefaultStyle];
    cell.leftLabel.text = RCDLocalizedString(@"Personal_information");
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDGroupMemberDetailController *vc = [[RCDGroupMemberDetailController alloc] init];
    vc.userId = self.targetUserId;
    vc.groupId = self.groupId;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Private Method
- (void)setupNavi {
    self.navigationItem.title = RCDLocalizedString(@"add_contacts");
}

- (void)setupTableView {
    [self setHeaderView];
    [self setFooterView];
}

- (void)setHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 86)];
    headerView.backgroundColor = [RCDUtilities generateDynamicColor:HEXCOLOR(0xffffff)
                                                          darkColor:[HEXCOLOR(0x1c1c1e) colorWithAlphaComponent:0.4]];
    self.tableView.tableHeaderView = headerView;

    [headerView addSubview:self.portraitImgView];
    [headerView addSubview:self.nameLabel];
    [headerView addSubview:self.genderImgView];
    [headerView addSubview:self.stAccountLabel];

    [self.portraitImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(headerView);
        make.left.equalTo(headerView).offset(10);
        make.height.width.offset(65);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.portraitImgView).offset(7);
        make.left.equalTo(self.portraitImgView.mas_right).offset(8);
        make.height.offset(20);
    }];

    [self.genderImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nameLabel);
        make.left.equalTo(self.nameLabel.mas_right).offset(5);
        make.height.width.equalTo(@15);
    }];

    [self.stAccountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).offset(7);
        make.left.equalTo(self.nameLabel);
        make.right.equalTo(headerView);
        make.height.offset(14);
    }];
}

- (void)getUserInfo {
    self.targetUserInfo = [RCDUserInfoManager getUserInfo:self.targetUserId];
    if (!self.targetUserInfo) {
        __weak typeof(self) weakSelf = self;
        [RCDUserInfoManager getUserInfoFromServer:self.targetUserId
                                         complete:^(RCDUserInfo *userInfo) {
                                             weakSelf.targetUserInfo = userInfo;
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [weakSelf setHeaderData];
                                             });
                                         }];
    } else {
        [self setHeaderData];
    }
}

- (void)setGroupMemberInfo {
    if (self.groupId.length > 0) {
        RCDGroupMember *member = [RCDGroupManager getGroupMember:self.targetUserId groupId:self.groupId];
        if (member.groupNickname.length > 0) {
            self.groupNicknameLabel.hidden = NO;
            [self.tableView.tableHeaderView addSubview:self.groupNicknameLabel];
            [self.groupNicknameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.stAccountLabel.hidden ? self.nameLabel.mas_bottom
                                                            : self.stAccountLabel.mas_bottom)
                    .offset(7);
                make.left.equalTo(self.nameLabel);
                make.right.equalTo(self.tableView.tableHeaderView);
                make.height.offset(16);
            }];
            self.groupNicknameLabel.text =
                [NSString stringWithFormat:@"%@：%@", RCDLocalizedString(@"GroupNickname"), member.groupNickname];
        }
    }
}

- (void)updateNameLayout {
    if (self.groupNicknameLabel.hidden && self.stAccountLabel.hidden) {
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.portraitImgView);
            make.left.equalTo(self.portraitImgView.mas_right).offset(8);
            make.height.offset(20);
        }];
    }
    if ((self.groupNicknameLabel.hidden && !self.stAccountLabel.hidden) ||
        (!self.groupNicknameLabel.hidden && self.stAccountLabel.hidden)) {
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.portraitImgView).offset(7);
            make.left.equalTo(self.portraitImgView.mas_right).offset(8);
            make.height.offset(20);
        }];
    }
    if (!self.groupNicknameLabel.hidden && !self.stAccountLabel.hidden) {
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.portraitImgView);
            make.left.equalTo(self.portraitImgView.mas_right).offset(8);
            make.height.offset(20);
        }];
    }
}

- (void)setHeaderData {
    self.nameLabel.text = self.targetUserInfo.name;
    if (self.targetUserInfo.portraitUri.length > 0) {
        [self.portraitImgView sd_setImageWithURL:[NSURL URLWithString:self.targetUserInfo.portraitUri]
                                placeholderImage:nil];
    }
    if (!self.portraitImgView.image) {
        UIImage *portrait = [DefaultPortraitView portraitView:self.targetUserId name:self.targetUserInfo.name];
        self.portraitImgView.image = portrait;
    }
    if (self.targetUserInfo.gender.length > 0) {
        self.genderImgView.image =
            [UIImage imageNamed:[NSString stringWithFormat:@"gender_%@", self.targetUserInfo.gender]];
    } else {
        self.genderImgView.image = [UIImage imageNamed:@"gender_male"];
    }
    if (self.targetUserInfo.stAccount.length > 0 && ![self.targetUserInfo.stAccount isEqualToString:@""] &&
        !self.groupInfo.memberProtection) {
        self.stAccountLabel.hidden = NO;
        self.stAccountLabel.text =
            [NSString stringWithFormat:@"%@：%@", RCDLocalizedString(@"SealTalkNumber"), self.targetUserInfo.stAccount];
    } else {
        self.stAccountLabel.hidden = YES;
    }
}

- (void)setFooterView {
    if (self.groupInfo.memberProtection) {
        [self showProtectTipView];
    } else {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 500)];
        self.tableView.tableFooterView = footerView;
        [footerView addSubview:self.addFriendBtn];
        [footerView addSubview:self.startChatBtn];

        [self.addFriendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(footerView).offset(15);
            make.left.right.equalTo(footerView).inset(10);
            make.height.offset(43);
        }];

        [self.startChatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.height.left.right.equalTo(self.addFriendBtn);
        }];

        [self updateFooterView];
    }
}

- (void)showProtectTipView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 500)];
    self.tableView.tableFooterView = footerView;

    UILabel *label = [[UILabel alloc] init];
    label.text = RCDLocalizedString(@"AddFriendProtectTip");
    label.textColor = RCDDYCOLOR(0x8b8b8b, 0x666666);
    label.font = [UIFont systemFontOfSize:14];
    label.numberOfLines = 0;
    [footerView addSubview:label];

    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(footerView).offset(15);
        make.left.right.equalTo(footerView).inset(36);
    }];
}

- (void)updateFooterView {
    NSMutableArray *cacheList = [[NSMutableArray alloc] initWithArray:[RCDUserInfoManager getAllFriends]];
    BOOL isFriend = NO;
    for (RCDFriendInfo *user in cacheList) {
        if ([user.userId isEqualToString:self.targetUserId]) {
            isFriend = YES;
            break;
        }
    }
    if (isFriend == YES) {
        self.addFriendBtn.hidden = YES;
        self.startChatBtn.hidden = NO;
    } else {
        self.addFriendBtn.hidden = NO;
        self.startChatBtn.hidden = YES;
    }
}

- (void)showAlertViewWith:(NSString *)message {
    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:RCDLocalizedString(@"confirm")
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                          [self.navigationController
                                                              popToRootViewControllerAnimated:YES];
                                                      }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Target Action
- (void)addFriendAction:(id)sender {
    [self.hud showAnimated:YES];
    [RCDUserInfoManager
        inviteFriend:self.targetUserId
         withMessage:[NSString stringWithFormat:@"我是%@", [RCIM sharedRCIM].currentUserInfo.name]
            complete:^(BOOL success, NSString *action) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.hud hideAnimated:YES];
                    if (success) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:RCDContactsRequestKey object:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:RCDContactsUpdateUIKey object:nil];
                        if ([action isEqualToString:@"AddDirectly"]) {
                            [self showAlertViewWith:RCDLocalizedString(@"AddSuccess")];
                        } else {
                            [self showAlertViewWith:RCDLocalizedString(@"request_had_send")];
                        }
                        [self updateFooterView];
                    } else {
                        [self showAlertViewWith:RCDLocalizedString(@"request_fail_retry")];
                    }
                });
            }];
}

- (void)startChatAction:(id)sender {
    RCDChatViewController *conversationVC = [[RCDChatViewController alloc] init];
    conversationVC.needPopToRootView = YES;
    conversationVC.conversationType = ConversationType_PRIVATE;
    conversationVC.targetId = self.targetUserInfo.userId;
    conversationVC.title = self.targetUserInfo.name;
    conversationVC.displayUserNameInCell = NO;
    [self.navigationController pushViewController:conversationVC animated:YES];
}

#pragma mark - Setter && Getter
- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = RCDDYCOLOR(0x000000, 0x9f9f9f);
    }
    return _nameLabel;
}

- (UIImageView *)portraitImgView {
    if (!_portraitImgView) {
        _portraitImgView = [[UIImageView alloc] init];
        if ([RCIM sharedRCIM].globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
            [RCIM sharedRCIM].globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
            _portraitImgView.layer.cornerRadius = 30.f;
        } else {
            _portraitImgView.layer.cornerRadius = 5.f;
        }
        _portraitImgView.clipsToBounds = YES;
        _portraitImgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _portraitImgView;
}

- (UIImageView *)genderImgView {
    if (!_genderImgView) {
        _genderImgView = [[UIImageView alloc] init];
        _genderImgView.layer.cornerRadius = 15 / 2;
        _genderImgView.layer.masksToBounds = YES;
    }
    return _genderImgView;
}

- (UILabel *)stAccountLabel {
    if (!_stAccountLabel) {
        _stAccountLabel = [[UILabel alloc] init];
        _stAccountLabel.textColor = [UIColor colorWithHexString:@"999999" alpha:1];
        _stAccountLabel.font = [UIFont systemFontOfSize:14];
    }
    return _stAccountLabel;
}

- (UILabel *)groupNicknameLabel {
    if (!_groupNicknameLabel) {
        _groupNicknameLabel = [[UILabel alloc] init];
        _groupNicknameLabel.font = [UIFont systemFontOfSize:14];
        _groupNicknameLabel.textColor = [UIColor colorWithHexString:@"999999" alpha:1];
        _groupNicknameLabel.hidden = YES;
    }
    return _groupNicknameLabel;
}

- (UIButton *)addFriendBtn {
    if (!_addFriendBtn) {
        _addFriendBtn = [[UIButton alloc] init];
        [_addFriendBtn setBackgroundColor:[UIColor colorWithHexString:@"0099ff" alpha:1.0]];
        _addFriendBtn.layer.masksToBounds = YES;
        _addFriendBtn.layer.cornerRadius = 5.f;
        [_addFriendBtn setTitle:RCDLocalizedString(@"add_contacts") forState:UIControlStateNormal];
        [_addFriendBtn addTarget:self action:@selector(addFriendAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addFriendBtn;
}

- (UIButton *)startChatBtn {
    if (!_startChatBtn) {
        _startChatBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 30, self.view.bounds.size.width, 86)];
        [_startChatBtn setTitle:RCDLocalizedString(@"start_chat") forState:UIControlStateNormal];
        [_startChatBtn setTintColor:[UIColor blackColor]];
        [_startChatBtn setBackgroundColor:[UIColor colorWithHexString:@"0099ff" alpha:1.0]];
        _startChatBtn.layer.masksToBounds = YES;
        _startChatBtn.layer.cornerRadius = 5.f;
        [_startChatBtn addTarget:self action:@selector(startChatAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startChatBtn;
}

- (MBProgressHUD *)hud {
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.color = [UIColor colorWithHexString:@"343637" alpha:0.8];
    }
    return _hud;
}

@end
