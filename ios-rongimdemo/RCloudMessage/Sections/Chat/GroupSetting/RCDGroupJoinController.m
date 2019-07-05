//
//  RCGroupJoinController.m
//  SealTalk
//
//  Created by 张改红 on 2019/6/17.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDGroupJoinController.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "DefaultPortraitView.h"
#import "RCDUIBarButtonItem.h"
#import "RCDGroupManager.h"
#import "RCDChatViewController.h"
@interface RCDGroupJoinController ()
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *portraitImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIButton *joinButton;
@end

@implementation RCDGroupJoinController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = HEXCOLOR(0xf2f2f3);
    [self getGroupInfo];
    [self setNaviItem];
    [self addSubViews];
}

#pragma mark - helper
- (void)getGroupInfo{
    __weak typeof(self) weakSelf = self;
    [RCDGroupManager getGroupInfoFromServer:self.groupId complete:^(RCDGroupInfo * _Nonnull groupInfo) {
        rcd_dispatch_main_async_safe((^{
            if (groupInfo) {
                if (groupInfo.isDismiss) {
                    weakSelf.joinButton.enabled = NO;
                    [weakSelf.joinButton setTitle:RCDLocalizedString(@"GroupDidDismiss") forState:(UIControlStateNormal)];
                }
                weakSelf.infoLabel.text = [NSString stringWithFormat:RCDLocalizedString(@"GroupDetailCount"),groupInfo.number];
                
                weakSelf.nameLabel.text = groupInfo.groupName;
                if ([groupInfo.portraitUri isEqualToString:@""]) {
                    [weakSelf.portraitImageView sd_setImageWithURL:[NSURL URLWithString:groupInfo.portraitUri] placeholderImage:[UIImage imageNamed:@"contact"]];
                }
                if (!weakSelf.portraitImageView.image) {
                    weakSelf.portraitImageView.image = [DefaultPortraitView portraitView:groupInfo.groupId name:groupInfo.groupName];
                }
            }
        }));
    }];
}

- (void)setNaviItem{
    self.navigationItem.title = RCDLocalizedString(@"JoinGroup");
    RCDUIBarButtonItem *leftBtn = [[RCDUIBarButtonItem alloc] initWithLeftBarButton:RCDLocalizedString(@"back") target:self action:@selector(clickBackBtn)];
    self.navigationItem.leftBarButtonItem = leftBtn;
}

- (void)clickBackBtn{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didClickJoinAction{
    __weak typeof(self) weakSelf = self;
    [RCDGroupManager joinGroup:self.groupId complete:^(BOOL success) {
        rcd_dispatch_main_async_safe(^{
            if (success) {
                [weakSelf pushChatVC];
            }else{
                [weakSelf showAlert:@"GroupJoinFail"];
            }
        });
    }];
}

- (void)pushChatVC{
    RCDChatViewController *chatVC = [[RCDChatViewController alloc] init];
    chatVC.targetId = self.groupId;
    chatVC.conversationType = ConversationType_GROUP;
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (void)showAlert:(NSString *)alertContent {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:alertContent
                                                   delegate:nil
                                          cancelButtonTitle:RCDLocalizedString(@"confirm")
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)addSubViews{
    [self.view addSubview:self.bgView];
    [self.view addSubview:self.joinButton];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.offset(211);
        make.top.equalTo(self.view).offset(0);
    }];
    [self.joinButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.height.offset(44);
        make.left.equalTo(self.view).offset(32);
        make.top.equalTo(self.bgView.mas_bottom).offset(30);
    }];
    
    [self.bgView addSubview:self.portraitImageView];
    [self.bgView addSubview:self.nameLabel];
    [self.bgView addSubview:self.infoLabel];

    [self.portraitImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bgView);
        make.top.equalTo(self.bgView).offset(60);
        make.width.height.offset(70);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bgView);
        make.top.equalTo(self.portraitImageView.mas_bottom).offset(9);
        make.height.offset(28);
        make.width.equalTo(self.bgView);
    }];
    
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bgView);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(2);
        make.height.offset(20);
        make.width.equalTo(self.bgView);
    }];
}

#pragma mark - getter
- (UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor whiteColor];
    }
    return _bgView;
}

- (UIImageView *)portraitImageView{
    if (!_portraitImageView) {
        _portraitImageView = [[UIImageView alloc] init];
        _portraitImageView.layer.masksToBounds = YES;
        _portraitImageView.layer.cornerRadius = 4;
    }
    return _portraitImageView;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = HEXCOLOR(0x262626);
        _nameLabel.font = [UIFont systemFontOfSize:20];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

- (UILabel *)infoLabel{
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.textColor = HEXCOLOR(0x939393);
        _infoLabel.font = [UIFont systemFontOfSize:14];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _infoLabel;
}

- (UIButton *)joinButton{
    if (!_joinButton) {
        _joinButton = [[UIButton alloc] init];
        _joinButton.backgroundColor = HEXCOLOR(0x368ae8);
        [_joinButton setTitleColor:HEXCOLOR(0xffffff) forState:(UIControlStateNormal)];
        _joinButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [_joinButton setTitle:RCDLocalizedString(@"JoinThisGroup") forState:(UIControlStateNormal)];
        [_joinButton addTarget:self action:@selector(didClickJoinAction) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _joinButton;
}

@end
