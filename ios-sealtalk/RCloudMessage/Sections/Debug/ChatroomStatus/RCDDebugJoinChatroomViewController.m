//
//  RCDDebugJoinChatroomViewController.m
//  SealTalk
//
//  Created by 孙浩 on 2019/10/17.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDDebugJoinChatroomViewController.h"
#import <Masonry/Masonry.h>
#import "RCDDebugChatroomViewController.h"
#import <RongChatRoom/RongChatRoom.h>
#import "NormalAlertView.h"

@interface RCDDebugJoinChatroomViewController ()

@property (nonatomic, strong) UIButton *joinChatroom1Btn;
@property (nonatomic, strong) UIButton *joinChatroom2Btn;
@property (nonatomic, strong) UIButton *getChatRoom1EntriesBtn;
@property (nonatomic, strong) UIButton *getChatRoom2EntriesBtn;

@end

@implementation RCDDebugJoinChatroomViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
}

#pragma mark - Private Method
- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];

    [self.view addSubview:self.joinChatroom1Btn];
    [self.view addSubview:self.joinChatroom2Btn];
    
    [self.view addSubview:self.getChatRoom1EntriesBtn];
    [self.view addSubview:self.getChatRoom2EntriesBtn];

    [self.joinChatroom1Btn mas_makeConstraints:^(MASConstraintMaker *make) {

        make.bottom.equalTo(self.view).offset(-RCDExtraBottomHeight - 40);
        make.left.equalTo(self.view).offset(10);
        make.height.offset(50);
        make.width.equalTo(self.joinChatroom2Btn);
    }];

    [self.joinChatroom2Btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.width.height.equalTo(self.joinChatroom1Btn);
        make.left.equalTo(self.joinChatroom1Btn.mas_right).offset(10);
        make.right.equalTo(self.view).offset(-10);
    }];
    
    [self.getChatRoom1EntriesBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.joinChatroom1Btn.mas_top).offset(-10);
        make.left.width.height.equalTo(self.joinChatroom1Btn);
    }];
    
    [self.getChatRoom2EntriesBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.joinChatroom2Btn.mas_top).offset(-10);
        make.left.width.height.equalTo(self.joinChatroom2Btn);
    }];
}

#pragma mark - Target Action
- (void)joinChatroom:(UIButton *)sender {
    NSString *roomId = @"kvchatroom1";
    if (sender.tag == 100002) {
        roomId = @"kvchatroom2";
    }
    RCDDebugChatroomViewController *vc = [[RCDDebugChatroomViewController alloc] init];
    vc.roomId = roomId;
    [self.navigationController pushViewController:vc animated:YES];

}

- (void)getChatroomEntries:(UIButton *)sender {
    NSString *roomId = @"kvchatroom1";
    if (sender.tag == 100004) {
        roomId = @"kvchatroom2";
    }
    
    [[RCChatRoomClient sharedChatRoomClient] getAllChatRoomEntries:roomId success:^(NSDictionary * _Nonnull entry) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NormalAlertView showAlertWithTitle:nil
                                        message:[NSString stringWithFormat:@"不在聊天室获取 KV 成功 entry: %@", entry]
                                  describeTitle:nil
                                   confirmTitle:RCDLocalizedString(@"confirm")
                                        confirm:^{
            }];
        });
    } error:^(RCErrorCode nErrorCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NormalAlertView showAlertWithTitle:nil
                                        message:[NSString stringWithFormat:@"不在聊天室获取 KV 失败 失败原因：%ld", (long)nErrorCode]
                                  describeTitle:nil
                                   confirmTitle:RCDLocalizedString(@"confirm")
                                        confirm:^{
            }];
        });
    }];
}


#pragma mark - Getter && Setter
- (UIButton *)joinChatroom1Btn {
    if (!_joinChatroom1Btn) {
        _joinChatroom1Btn = [[UIButton alloc] init];
        _joinChatroom1Btn.tag = 100001;
        [_joinChatroom1Btn setTitle:@"加入聊天室1" forState:UIControlStateNormal];
        [_joinChatroom1Btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_joinChatroom1Btn addTarget:self
                              action:@selector(joinChatroom:)
                    forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _joinChatroom1Btn;
}

- (UIButton *)joinChatroom2Btn {
    if (!_joinChatroom2Btn) {
        _joinChatroom2Btn = [[UIButton alloc] init];
        _joinChatroom2Btn.tag = 100002;
        [_joinChatroom2Btn setTitle:@"加入聊天室2" forState:UIControlStateNormal];
        [_joinChatroom2Btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_joinChatroom2Btn addTarget:self
                              action:@selector(joinChatroom:)
                    forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _joinChatroom2Btn;
}

- (UIButton *)getChatRoom1EntriesBtn {
    if (!_getChatRoom1EntriesBtn) {
        _getChatRoom1EntriesBtn = [[UIButton alloc] init];
        _getChatRoom1EntriesBtn.tag = 100003;
        [_getChatRoom1EntriesBtn setTitle:@"获取聊天室 1 KV" forState:UIControlStateNormal];
        [_getChatRoom1EntriesBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_getChatRoom1EntriesBtn addTarget:self
                              action:@selector(getChatroomEntries:)
                    forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _getChatRoom1EntriesBtn;
}


- (UIButton *)getChatRoom2EntriesBtn {
    if (!_getChatRoom2EntriesBtn) {
        _getChatRoom2EntriesBtn = [[UIButton alloc] init];
        _getChatRoom2EntriesBtn.tag = 100004;
        [_getChatRoom2EntriesBtn setTitle:@"获取聊天室 2 KV" forState:UIControlStateNormal];
        [_getChatRoom2EntriesBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_getChatRoom2EntriesBtn addTarget:self
                              action:@selector(getChatroomEntries:)
                    forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _getChatRoom2EntriesBtn;
}

@end
