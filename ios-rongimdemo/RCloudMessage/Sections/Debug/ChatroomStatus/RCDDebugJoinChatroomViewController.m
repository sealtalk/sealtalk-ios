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
#import <RongIMLib/RongIMLib.h>

@interface RCDDebugJoinChatroomViewController ()

@property (nonatomic, strong) UIButton *joinChatroom1Btn;
@property (nonatomic, strong) UIButton *joinChatroom2Btn;

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
}

#pragma mark - Target Action
- (void)joinChatroom:(UIButton *)sender {
    NSString *roomId = @"kvchatroom1";
    if (sender.tag == 100002) {
        roomId = @"kvchatroom2";
    }

    [[RCIMClient sharedRCIMClient] joinChatRoom:roomId
        messageCount:20
        success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                RCDDebugChatroomViewController *vc = [[RCDDebugChatroomViewController alloc] init];
                vc.roomId = roomId;
                [self.navigationController pushViewController:vc animated:YES];
            });
        }
        error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                RCDDebugChatroomViewController *vc = [[RCDDebugChatroomViewController alloc] init];
                vc.roomId = roomId;
                [self.navigationController pushViewController:vc animated:YES];
                NSLog(@"debug 测试聊天室状态存储，加入聊天室失败：%ld", (long)status);
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

@end
