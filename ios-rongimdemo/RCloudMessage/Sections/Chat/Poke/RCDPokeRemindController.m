//
//  RCDPokeRemindController.m
//  SealTalk
//
//  Created by 张改红 on 2019/8/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDPokeRemindController.h"
#import "RCDPokeManager.h"
#import <Masonry/Masonry.h>
#import "RCDUserInfoManager.h"
#import <SDWebImage/SDWebImage.h>
#import "RCDGroupManager.h"
#import "RCDPokeMessage.h"
#import <AVFoundation/AVFoundation.h>
#import "RCDChatViewController.h"
#import "RCDUtilities.h"
@interface RCDPokeRemindController ()
@property (nonatomic, strong) UIImageView *headerView;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UILabel *groupNameLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIButton *ignoreButton;
@property (nonatomic, strong) UILabel *ignoreLabel;
@property (nonatomic, strong) UIButton *joinChatButton;
@property (nonatomic, strong) UILabel *joinChatlabel;

@property (nonatomic, strong) NSTimer *shakeTimer; //震动定时器
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, assign) NSInteger timeLimit;
@end

@implementation RCDPokeRemindController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [HEXCOLOR(0x000000) colorWithAlphaComponent:0.9];
    [self setDataInfo];
    [self setupSubviews];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillTerminate)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self beginShakeAndSound];
    [RCDPokeManager sharedInstance].isShowPokeVC = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [RCDPokeManager sharedInstance].isShowPokeVC = NO;
}

#pragma mark - helper
- (void)appWillTerminate {
    [self stopShakeAndSound];
}

- (void)didClickIgnoreButton {
    [self dismiss];
}

- (void)didClickJoinChatButton {
    [self dismiss];
    UIViewController *rootVC = [self getCurrentVC];
    RCDChatViewController *chatVC = [[RCDChatViewController alloc] init];
    chatVC.targetId = self.message.targetId;
    chatVC.conversationType = self.message.conversationType;
    if ([rootVC isKindOfClass:[UINavigationController class]]) {
        if ([rootVC.presentedViewController isKindOfClass:[UINavigationController class]]) {
            [(UINavigationController *)rootVC.presentedViewController pushViewController:chatVC animated:YES];
        } else {
            [(UINavigationController *)rootVC pushViewController:chatVC animated:YES];
        }
    } else {
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:rootVC];
        navi.modalPresentationStyle = UIModalPresentationFullScreen;
        [rootVC presentViewController:navi animated:YES completion:nil];
    }
}

- (void)dismiss {
    [self stopShakeAndSound];
    [self.view removeFromSuperview];
}

// 开始震动和播放音乐
- (void)beginShakeAndSound {
    self.shakeTimer =
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(shakePhone) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.shakeTimer forMode:NSDefaultRunLoopMode];

    NSError *error;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"poke" ofType:@".mp3"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return;
    }
    SystemSoundID soundID = 0;
    CFURLRef urlRef = (__bridge CFURLRef)([NSURL fileURLWithPath:path]);
    AudioServicesCreateSystemSoundID(urlRef, &soundID);

    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
    if (!self.player) {
        NSLog(@"Error: %@", [error localizedDescription]);
        return;
    }
    [self.player setNumberOfLoops:1000000];
    [self.player prepareToPlay];
    [self.player play];
}

/**
 停止震动和音乐
 */
- (void)stopShakeAndSound {
    [_player stop];
    //停止前手动出发震动一下
    [self shakePhone];
    [_shakeTimer invalidate];
}

- (void)shakePhone {
    self.timeLimit -= 1;
    if (self.timeLimit == 0) {
        [self dismiss];
    }
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)setDataInfo {
    if (self.message.conversationType == ConversationType_GROUP) {
        __weak typeof(self) weakSelf = self;
        [RCDUtilities getGroupUserDisplayInfo:self.message.senderUserId
                                      groupId:self.message.targetId
                                       result:^(RCUserInfo *user) {
                                           weakSelf.userNameLabel.text = user.name;
                                           [weakSelf.headerView
                                               sd_setImageWithURL:[NSURL URLWithString:user.portraitUri]
                                                 placeholderImage:[UIImage imageNamed:@"contact"]];
                                       }];
    } else {
        __weak typeof(self) weakSelf = self;
        [RCDUtilities getUserDisplayInfo:self.message.senderUserId
                                complete:^(RCUserInfo *user) {
                                    weakSelf.userNameLabel.text = user.name;
                                    [weakSelf.headerView sd_setImageWithURL:[NSURL URLWithString:user.portraitUri]
                                                           placeholderImage:[UIImage imageNamed:@"contact"]];
                                }];
    }

    if (self.message.conversationType == ConversationType_GROUP) {
        RCDGroupInfo *group = [RCDGroupManager getGroupInfo:self.message.targetId];
        if (!group) {
            [RCDGroupManager getGroupInfoFromServer:self.message.targetId
                                           complete:^(RCDGroupInfo *groupInfo) {
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   if (groupInfo) {
                                                       self.groupNameLabel.text = groupInfo.groupName;
                                                   }
                                               });
                                           }];
        } else {
            self.groupNameLabel.text = group.groupName;
        }
    }
    RCDPokeMessage *pokeMsg = (RCDPokeMessage *)self.message.content;
    self.contentLabel.text = pokeMsg.content;
    self.timeLimit = 60;
}

//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC {
    UIViewController *result = nil;
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for (UIWindow *tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        result = nextResponder;
    } else {
        result = window.rootViewController;
    }
    return result;
}

- (void)setupSubviews {
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.userNameLabel];
    UIView *contentBgView = [[UIView alloc] init];
    contentBgView.backgroundColor = HEXCOLOR(0x555555);
    contentBgView.layer.cornerRadius = 2.f;
    contentBgView.layer.masksToBounds = YES;
    [self.view addSubview:contentBgView];
    [self.view addSubview:self.contentLabel];
    [self.view addSubview:self.ignoreButton];
    [self.view addSubview:self.ignoreLabel];
    [self.view addSubview:self.joinChatButton];
    [self.view addSubview:self.joinChatlabel];

    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(83);
        } else {
            make.top.equalTo(self.view).offset(83);
        }
        make.centerX.equalTo(self.view);
        make.height.width.offset(130);
    }];
    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView.mas_bottom).offset(10);
        make.centerX.equalTo(self.view);
        make.height.offset(28);
    }];
    if (self.message.conversationType == ConversationType_GROUP) {
        [self.view addSubview:self.groupNameLabel];
        [self.groupNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.userNameLabel.mas_bottom).offset(5);
            make.centerX.equalTo(self.view);
            make.height.offset(28);
        }];
    }
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userNameLabel.mas_bottom).offset(48);
        make.centerX.equalTo(self.view);
        make.left.greaterThanOrEqualTo(self.view).offset(25);
    }];
    [contentBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.centerX.equalTo(self.contentLabel);
        make.centerX.equalTo(self.view);
        make.height.equalTo(self.contentLabel).offset(20);
        make.width.equalTo(self.contentLabel).offset(30);
    }];
    [self.ignoreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.ignoreLabel.mas_top).offset(-10);
        make.centerX.equalTo(self.ignoreLabel);
        make.height.width.offset(60);
    }];
    [self.ignoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-32);
        } else {
            make.bottom.equalTo(self.view).offset(-32);
        }
        make.centerX.equalTo(self.view).multipliedBy(0.5);
        make.height.offset(21);
    }];
    [self.joinChatButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.ignoreButton);
        make.centerX.equalTo(self.view).multipliedBy(1.5);
        make.height.width.offset(60);
    }];
    [self.joinChatlabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.ignoreLabel);
        make.centerX.equalTo(self.view).multipliedBy(1.5);
        make.height.offset(21);
    }];
}

#pragma mark - getter
- (UIImageView *)headerView {
    if (!_headerView) {
        _headerView = [[UIImageView alloc] init];
        _headerView.layer.cornerRadius = 6.f;
        _headerView.layer.masksToBounds = YES;
        _headerView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _headerView;
}

- (UILabel *)userNameLabel {
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc] init];
        _userNameLabel.font = [UIFont systemFontOfSize:20];
        _userNameLabel.textColor = HEXCOLOR(0xffffff);
        _userNameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _userNameLabel;
}

- (UILabel *)groupNameLabel {
    if (!_groupNameLabel) {
        _groupNameLabel = [[UILabel alloc] init];
        _groupNameLabel.font = [UIFont systemFontOfSize:20];
        _groupNameLabel.textColor = HEXCOLOR(0xffffff);
        _groupNameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _groupNameLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:15];
        _contentLabel.textColor = HEXCOLOR(0xffffff);
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

- (UIButton *)ignoreButton {
    if (!_ignoreButton) {
        _ignoreButton = [[UIButton alloc] init];
        [_ignoreButton setImage:[UIImage imageNamed:@"poke_ignore"] forState:(UIControlStateNormal)];
        [_ignoreButton addTarget:self
                          action:@selector(didClickIgnoreButton)
                forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _ignoreButton;
}

- (UILabel *)ignoreLabel {
    if (!_ignoreLabel) {
        _ignoreLabel = [[UILabel alloc] init];
        _ignoreLabel.font = [UIFont systemFontOfSize:15];
        _ignoreLabel.textColor = HEXCOLOR(0xffffff);
        _ignoreLabel.textAlignment = NSTextAlignmentCenter;
        _ignoreLabel.text = RCDLocalizedString(@"Ignore");
    }
    return _ignoreLabel;
}

- (UIButton *)joinChatButton {
    if (!_joinChatButton) {
        _joinChatButton = [[UIButton alloc] init];
        [_joinChatButton setImage:[UIImage imageNamed:@"poke_join_chat"] forState:(UIControlStateNormal)];
        [_joinChatButton addTarget:self
                            action:@selector(didClickJoinChatButton)
                  forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _joinChatButton;
}

- (UILabel *)joinChatlabel {
    if (!_joinChatlabel) {
        _joinChatlabel = [[UILabel alloc] init];
        _joinChatlabel.font = [UIFont systemFontOfSize:15];
        _joinChatlabel.textColor = HEXCOLOR(0xffffff);
        _joinChatlabel.textAlignment = NSTextAlignmentCenter;
        _joinChatlabel.text = RCDLocalizedString(@"JoinChat");
    }
    return _joinChatlabel;
}
@end
