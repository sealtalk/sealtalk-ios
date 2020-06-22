//
//  RCDCopyGroupController.m
//  SealTalk
//
//  Created by 张改红 on 2019/8/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDCopyGroupController.h"
#import <Masonry/Masonry.h>
#import "RCDGroupManager.h"
#import <SDWebImage/SDWebImage.h>
#import "DefaultPortraitView.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDUserInfoManager.h"
#import "UIView+MBProgressHUD.h"
#import "NormalAlertView.h"
#import "RCDChatViewController.h"
@interface RCDCopyGroupController ()
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *portraitImageView;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIButton *confirmBotton;

@property (nonatomic, strong) RCDGroupInfo *group;
@end

@implementation RCDCopyGroupController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = RCDLocalizedString(@"CopyGroup");
    self.group = [RCDGroupManager getGroupInfo:self.groupId];
    [self setGroupInfo];
    [self addSubViews];
}

#pragma mark - helper
- (void)setGroupInfo {
    self.infoLabel.text = [NSString stringWithFormat:@"%@ %@", self.group.number, RCDLocalizedString(@"Person")];

    if (self.group.portraitUri.length > 0) {
        [self.portraitImageView
            sd_setImageWithURL:[NSURL URLWithString:self.group.portraitUri]
              placeholderImage:[RCKitUtility imageNamed:@"default_group_portrait" ofBundle:@"RongCloud.bundle"]];
    }
    if (!self.portraitImageView.image) {
        self.portraitImageView.image = [DefaultPortraitView portraitView:self.group.groupId name:self.group.groupName];
    }
}

- (void)didClickConfirmAction {
    [NormalAlertView showAlertWithMessage:RCDLocalizedString(@"IsCopyGroup")
        highlightText:nil
        leftTitle:RCDLocalizedString(@"cancel")
        rightTitle:RCDLocalizedString(@"confirm")
        cancel:^{

        }
        confirm:^{
            [self copyGroup];
        }];
}

- (void)copyGroup {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *groupName = [self getGroupName];
    __weak typeof(self) weakSelf = self;
    [RCDGroupManager copyGroup:self.groupId
        groupName:groupName
        portraitUri:nil
        complete:^(NSString *groupId, RCDGroupAddMemberStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //关闭HUD
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if (groupId) {
                    if (status == RCDGroupAddMemberStatusInviteeApproving) {
                        [weakSelf.view showHUDMessage:RCDLocalizedString(@"MemberInviteNeedConfirm")];
                    }
                    [weakSelf gotoChatView:groupId groupName:groupName];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //关闭HUD
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [weakSelf.view showHUDMessage:RCDLocalizedString(@"CopyGroupFail")];
                    });
                }
            });
        }
        error:^(RCDGroupErrorCode errorCode) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //关闭HUD
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                // 20004: 群处于保护期
                // 20005: 7 天内已被复制一次
                if (errorCode == RCDGroupErrorCodeProtection) {
                    [weakSelf.view showHUDMessage:RCDLocalizedString(@"GroupIsProtectionTip")];
                } else if (errorCode == RCDGroupErrorCodeCopyOnceIn7D) {
                    [weakSelf.view showHUDMessage:RCDLocalizedString(@"GroupHasCopyInSevenDay")];
                } else if (errorCode == RCDGroupErrorCodeMemberOnlyOne) {
                    [weakSelf.view showHUDMessage:RCDLocalizedString(@"GroupMemberOnlyOne")];
                } else {
                    [weakSelf.view showHUDMessage:RCDLocalizedString(@"CopyGroupFail")];
                }
            });
        }];
}

- (NSString *)getGroupName {
    NSArray *members = [RCDGroupManager getGroupMembers:self.groupId];
    NSString *name = [RCIM sharedRCIM].currentUserInfo.name;
    for (NSString *userId in members) {
        if (![userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
            RCDUserInfo *user = [RCDUserInfoManager getUserInfo:userId];
            if (user.name.length > 0) {
                name = [name stringByAppendingString:[NSString stringWithFormat:@",%@", user.name]];
                break;
            }
        }
    }
    if (name.length > 6) {
        name = [[name substringWithRange:NSMakeRange(0, 6)] stringByAppendingString:@"..."];
    }
    return name;
}

- (void)gotoChatView:(NSString *)groupId groupName:(NSString *)groupName {
    RCDChatViewController *chatVC = [[RCDChatViewController alloc] init];
    chatVC.needPopToRootView = YES;
    chatVC.targetId = groupId;
    chatVC.conversationType = ConversationType_GROUP;
    chatVC.userName = groupName;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:chatVC animated:YES];
    });
}

- (void)addSubViews {
    [self.view addSubview:self.bgView];
    [self.view addSubview:self.tipLabel];
    [self.view addSubview:self.confirmBotton];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.offset(211);
        make.top.equalTo(self.view).offset(0);
    }];

    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.top.equalTo(self.bgView.mas_bottom).offset(10);
    }];

    [self.confirmBotton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.height.offset(44);
        make.left.equalTo(self.view).offset(32);
        make.top.equalTo(self.tipLabel.mas_bottom).offset(30);
    }];

    [self.bgView addSubview:self.portraitImageView];
    [self.bgView addSubview:self.infoLabel];

    [self.portraitImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bgView);
        make.top.equalTo(self.bgView).offset(60);
        make.width.height.offset(70);
    }];

    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bgView);
        make.top.equalTo(self.portraitImageView.mas_bottom).offset(17);
        make.height.offset(20);
        make.width.equalTo(self.bgView);
    }];
}

#pragma mark - getter
- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [RCDUtilities generateDynamicColor:HEXCOLOR(0xffffff)
                                                           darkColor:[HEXCOLOR(0x1c1c1e) colorWithAlphaComponent:0.4]];
    }
    return _bgView;
}

- (UIImageView *)portraitImageView {
    if (!_portraitImageView) {
        _portraitImageView = [[UIImageView alloc] init];
        _portraitImageView.layer.masksToBounds = YES;
        _portraitImageView.layer.cornerRadius = 4;
    }
    return _portraitImageView;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.textColor = RCDDYCOLOR(0x939393, 0x9f9f9f);
        _infoLabel.font = [UIFont systemFontOfSize:14];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _infoLabel;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.textColor = RCDDYCOLOR(0x939393, 0x9f9f9f);
        _tipLabel.font = [UIFont systemFontOfSize:14];
        _tipLabel.numberOfLines = 0;
        _tipLabel.text = [NSString
            stringWithFormat:@"%@\n%@", RCDLocalizedString(@"TipTitle"), RCDLocalizedString(@"CopyGroupTipInfo")];
    }
    return _tipLabel;
}

- (UIButton *)confirmBotton {
    if (!_confirmBotton) {
        _confirmBotton = [[UIButton alloc] init];
        _confirmBotton.backgroundColor = HEXCOLOR(0x368ae8);
        [_confirmBotton setTitleColor:HEXCOLOR(0xffffff) forState:(UIControlStateNormal)];
        _confirmBotton.titleLabel.font = [UIFont systemFontOfSize:17];
        [_confirmBotton setTitle:RCDLocalizedString(@"CopyGroupConfirm") forState:(UIControlStateNormal)];
        [_confirmBotton addTarget:self
                           action:@selector(didClickConfirmAction)
                 forControlEvents:(UIControlEventTouchUpInside)];
        _confirmBotton.layer.masksToBounds = YES;
        _confirmBotton.layer.cornerRadius = 4;
    }
    return _confirmBotton;
}

@end
