//
//  RCDDebugChatroomViewController.m
//  SealTalk
//
//  Created by 孙浩 on 2019/10/17.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDDebugChatroomViewController.h"
#import <Masonry/Masonry.h>
#import "RCDDebugChatRoomCell.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDDebugAlertView.h"
#import <RongChatRoom/RongChatRoom.h>

static NSString *debugChatRoomCellIdentifier = @"RCDDebugChatRoomCellIdentifier";

@interface RCDDebugChatroomViewController () <UITableViewDelegate, UITableViewDataSource, RCChatRoomKVStatusChangeDelegate,RCChatRoomStatusDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation RCDDebugChatroomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[RCChatRoomClient sharedChatRoomClient] setChatRoomStatusDelegate:self];
    [self setupData];
    [self setupNav];
    [self setupUI];
    [self joinChatRoom];
}

- (void)dealloc {
    [[RCChatRoomClient sharedChatRoomClient] quitChatRoom:self.roomId
        success:^{
        }
        error:^(RCErrorCode status){
        }];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Target Action
- (void)onBackButtonClick:(id)sender {
    [[RCChatRoomClient sharedChatRoomClient] quitChatRoom:self.roomId
        success:^{
            NSLog(@"退出聊天室成功");
        }
        error:^(RCErrorCode status) {
            NSLog(@"退出聊天室失败：%ld", (long)status);
        }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}
- (void)onRightButtonClick:(id)sender {
    [RCActionSheetView showActionSheetView:nil cellArray:@[@"设置 Key(强制)", @"设置 Key(不强制)", @"删除 Key（强制）", @"删除 Key（不强制）", @"获取所有 Key", @"获取指定 Key", @"批量设置 Key(强制)", @"批量设置 Key(不强制)", @"批量删除 Key(强制)", @"批量删除 Key(不强制)"] cancelTitle:RCDLocalizedString(@"cancel") selectedBlock:^(NSInteger index) {
        [self alertActionDidClickIndex:index];
    } cancelBlock:^{
            
    }];
}

- (void)alertActionDidClickIndex:(NSInteger)index{
    if (index == 0) {
        [self showAlertViewWithType:RCDDebugAlertViewTypeSet force:YES];
    } else if (index == 1) {
        [self showAlertViewWithType:RCDDebugAlertViewTypeSet force:NO];
    } else if (index == 2) {
        [self showAlertViewWithType:RCDDebugAlertViewTypeDelete force:YES];
    } else if (index == 3) {
        [self showAlertViewWithType:RCDDebugAlertViewTypeDelete force:NO];
    } else if (index == 4) {
        [self getAllChatroomKey];
    } else if (index == 5) {
        [self showAlertViewWithType:RCDDebugAlertViewTypeGet force:NO];
    } else if (index == 6) {
        [self showAlertViewWithType:RCDDebugAlertViewTypeBatchSet force:YES];
    } else if (index == 7) {
        [self showAlertViewWithType:RCDDebugAlertViewTypeBatchSet force:NO];
    } else if (index == 8) {
        [self showAlertViewWithType:RCDDebugAlertViewTypeBatchDelete force:YES];
    } else if (index == 9) {
        [self showAlertViewWithType:RCDDebugAlertViewTypeBatchDelete force:NO];
    }
}

- (void)getAllChatroomKey{
    [[RCChatRoomClient sharedChatRoomClient] getAllChatRoomEntries:self.roomId
        success:^(NSDictionary *entry) {
            NSString *jsonString = @"";
            NSError *error = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:entry
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:&error];
            if (error) {
                jsonString = [entry description];
            }
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSString *targetString =
                [NSString stringWithFormat:@"获取所有 kv 成功：共 %lu 个，\n%@",
                                           (unsigned long)entry.count, jsonString];
            [self addStringToDataSource:targetString];
        }
        error:^(RCErrorCode nErrorCode) {
            NSString *targetString =
                [NSString stringWithFormat:@"获取所有 kv 失败：(%ld)%@", (long)nErrorCode,
                                           [self errorCodeToString:nErrorCode]];
            [self addStringToDataSource:targetString];
        }];
}

- (void)showAlertViewWithType:(RCDDebugAlertViewType)type force:(BOOL)isForce {

    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    RCDDebugAlertView *alertView = [[RCDDebugAlertView alloc] initWithAlertViewType:type];
    [window addSubview:alertView];
    [alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.width.height.equalTo(window);
    }];

    alertView.finishBlock = ^(RCDDebugAlertView *_Nonnull alertView) {
        NSString *key = alertView.key;
        NSString *value = alertView.value;
        NSString *chatroomId = self.roomId;
        BOOL isNotice = alertView.isNotice;
        BOOL isDelete = alertView.isDelete;
        NSString *extra = alertView.extra;

        if (type == RCDDebugAlertViewTypeSet) {
            if (isForce) {
                [[RCChatRoomClient sharedChatRoomClient] forceSetChatRoomEntry:chatroomId
                    key:key
                    value:value
                    sendNotification:isNotice
                    autoDelete:isDelete
                    notificationExtra:extra
                    success:^{
                        NSString *targetString =
                            [NSString stringWithFormat:@"强制设置 kv 成功：\n"
                                                       @"key:%@，value:%@，extra:%@，\n"
                                                       @"是否发送通知:%d，退出时是否删除:%d",
                                                       key, value, extra, isNotice, isDelete];
                        [self addStringToDataSource:targetString];
                    }
                    error:^(RCErrorCode nErrorCode) {
                        NSString *targetString =
                            [NSString stringWithFormat:@"强制设置 kv 失败：(%ld)%@", (long)nErrorCode,
                                                       [self errorCodeToString:nErrorCode]];
                        [self addStringToDataSource:targetString];
                    }];
            } else {
                [[RCChatRoomClient sharedChatRoomClient] setChatRoomEntry:chatroomId
                    key:key
                    value:value
                    sendNotification:isNotice
                    autoDelete:isDelete
                    notificationExtra:extra
                    success:^{
                        NSString *targetString =
                            [NSString stringWithFormat:@"设置 kv 成功：\n"
                                                       @"key:%@，value:%@，extra:%@，\n"
                                                       @"是否发送通知:%d，退出时是否删除:%d",
                                                       key, value, extra, isNotice, isDelete];
                        [self addStringToDataSource:targetString];
                    }
                    error:^(RCErrorCode nErrorCode) {
                        NSString *targetString =
                            [NSString stringWithFormat:@"设置 kv 失败：(%ld)%@", (long)nErrorCode,
                                                       [self errorCodeToString:nErrorCode]];
                        [self addStringToDataSource:targetString];
                    }];
            }
        } else if (type == RCDDebugAlertViewTypeGet) {
            [[RCChatRoomClient sharedChatRoomClient] getChatRoomEntry:chatroomId
                key:key
                success:^(NSDictionary *entry) {
                    NSString *targetString = [NSString stringWithFormat:@"获取 kv 成功：\n%@=%@", key, entry[key]];
                    [self addStringToDataSource:targetString];
                }
                error:^(RCErrorCode nErrorCode) {
                    NSString *targetString = [NSString stringWithFormat:@"获取 kv 失败：(%ld)%@", (long)nErrorCode,
                                                                        [self errorCodeToString:nErrorCode]];
                    [self addStringToDataSource:targetString];
                }];
        } else if (type == RCDDebugAlertViewTypeDelete) {
            if (isForce) {
                [[RCChatRoomClient sharedChatRoomClient] forceRemoveChatRoomEntry:chatroomId
                    key:key
                    sendNotification:isNotice
                    notificationExtra:extra
                    success:^{
                        NSString *targetString = [NSString
                            stringWithFormat:@"强制删除 kv 成功：\nkey:%@，extra:%@，\n是否发送通知:%d",
                                             key, extra, isNotice];
                        [self addStringToDataSource:targetString];
                    }
                    error:^(RCErrorCode nErrorCode) {
                        NSString *targetString =
                            [NSString stringWithFormat:@"强制删除 kv 失败：(%ld)%@", (long)nErrorCode,
                                                       [self errorCodeToString:nErrorCode]];
                        [self addStringToDataSource:targetString];
                    }];
            } else {
                [[RCChatRoomClient sharedChatRoomClient] removeChatRoomEntry:chatroomId
                    key:key
                    sendNotification:isNotice
                    notificationExtra:extra
                    success:^{
                        NSString *targetString = [NSString
                            stringWithFormat:@"删除 kv 成功：\nkey:%@，extra:%@，是否发送通知:%d", key,
                                             extra, isNotice];
                        [self addStringToDataSource:targetString];
                    }
                    error:^(RCErrorCode nErrorCode) {
                        NSString *targetString =
                            [NSString stringWithFormat:@"删除 kv 失败：(%ld)%@", (long)nErrorCode,
                                                       [self errorCodeToString:nErrorCode]];
                        [self addStringToDataSource:targetString];
                    }];
            }
        } else if (type == RCDDebugAlertViewTypeBatchSet) {
            NSArray *keys = [key componentsSeparatedByString:@","];
            NSArray *values = [value componentsSeparatedByString:@","];
            
            if (keys.count != values.count) {
                [RCAlertView showAlertController:@"提示" message:@"key value 数量不匹配" cancelTitle:@"取消"];
                return;
            }
            NSDictionary *entries = [NSDictionary dictionaryWithObjects:values forKeys:keys];;
                [[RCChatRoomClient sharedChatRoomClient] setChatRoomEntries:chatroomId entries:entries isForce:isForce autoDelete:isDelete success:^{
                    NSString *targetString =
                        [NSString stringWithFormat:@"%@批量设置 kv 成功：\n"
                                                   @"entries:%@，extra:%@，\n"
                                                   @"退出时是否删除:%d",
                         isForce ? @"强制" : @"", entries, extra, isDelete];
                    [self addStringToDataSource:targetString];
                } error:^(RCErrorCode nErrorCode, NSDictionary * _Nonnull entries) {
                    NSString *targetString =
                        [NSString stringWithFormat:@"%@设置 kv 失败：(%ld) 失败的 entries: %@ %@", isForce ? @"强制" : @"", (long)nErrorCode, entries, [self errorCodeToString:nErrorCode]];
                    [self addStringToDataSource:targetString];
                }];
        } else if (type == RCDDebugAlertViewTypeBatchDelete) {
            NSArray *keys = [key componentsSeparatedByString:@","];
            [[RCChatRoomClient sharedChatRoomClient] removeChatRoomEntries:chatroomId keys:keys isForce:isForce success:^{
                NSString *targetString = [NSString
                                          stringWithFormat:@"%@ 删除 kv 成功：\nkeys:%@，extra:%@",
                                          isForce ? @"强制" : @"", keys, extra];
                [self addStringToDataSource:targetString];
            } error:^(RCErrorCode nErrorCode, NSDictionary * _Nonnull entries) {
                NSString *targetString =
                [NSString stringWithFormat:@"%@设置 kv 失败：(%ld) 失败的 entries: %@ %@", isForce ? @"强制" : @"", (long)nErrorCode, entries, [self errorCodeToString:nErrorCode]];
                [self addStringToDataSource:targetString];
            }];
        }
    };
}

- (void)didReceiveMessageNotification:(NSNotification *)notification {
    RCMessage *rcMessage = notification.object;
    NSLog(@"Debug ChatroomVC，接收到消息，MessageUId：%@", rcMessage.messageUId);
    if ([rcMessage.content isMemberOfClass:[RCChatroomKVNotificationMessage class]] &&
        [rcMessage.targetId isEqualToString:self.roomId]) {
        RCChatroomKVNotificationMessage *chatroomKVMessage = (RCChatroomKVNotificationMessage *)rcMessage.content;
        NSString *timeString = [RCKitUtility convertConversationTime:rcMessage.sentTime / 1000];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *typeString = @"";
            if (chatroomKVMessage.type == RCChatroomKVNotificationTypeSet) {
                typeString = @"设置";
            } else if (chatroomKVMessage.type == RCChatroomKVNotificationTypeRemove) {
                typeString = @"删除";
            }
            NSString *targetString = [NSString
                stringWithFormat:@"%@  收到 kv 操作的通知消息：\ntype:%@，key:%@，value:%@，extra:%@", timeString,
                                 typeString, chatroomKVMessage.key, chatroomKVMessage.value, chatroomKVMessage.extra];
            NSLog(@"Debug ChatroomVC，%@", targetString);
            [self.dataArray addObject:targetString];
            [self.tableView reloadData];
            [self scrollToBottomAnimated:YES];
        });
    }
}

#pragma mark - RCChatRoomKVStatusChangeDelegate
- (void)onChatRoomDestroyed:(NSString *)chatroomId type:(RCChatRoomDestroyType)type {
    NSString *msg;
    if (type == RCChatRoomDestroyTypeAuto) {
        msg = @"聊天室长时间不活跃，被系统自动回收";
    }else {
        msg = @"开发者主动销毁";
    }
    [RCAlertView showAlertController:@"提示" message:[NSString stringWithFormat:@"聊天室：%@ 被销毁,类型:%@",chatroomId,msg] cancelTitle:@"取消"];
}

- (void)onChatRoomReset:(NSString *)chatroomId {
    [RCAlertView showAlertController:@"提示" message:[NSString stringWithFormat:@"聊天室：%@ 重置加入",chatroomId] cancelTitle:@"取消"];
}

- (void)onChatRoomJoined:(NSString *)chatroomId {
    [RCAlertView showAlertController:@"提示" message:[NSString stringWithFormat:@"聊天室：%@ 加入成功回调",chatroomId] cancelTitle:@"取消"];
}

- (void)joinChatRoom{
    [[RCChatRoomClient sharedChatRoomClient] joinChatRoom:self.roomId
                                             messageCount:20
                                                  success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    }
                                                    error:^(RCErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"debug 测试聊天室状态存储，加入聊天室失败：%ld", (long)status);
        });
    }];
}


#pragma mark - RCChatRoomKVStatusChangeDelegate
- (void)chatRoomKVDidSync:(NSString *)roomId {
    NSLog(@"chatRoomKVDidSync --- roomId：%@", roomId);
    NSString *targetString = [NSString stringWithFormat:@"chatRoomKVDidSync：%@", roomId];
    [self addStringToDataSource:targetString];
}

- (void)chatRoomKVDidUpdate:(NSString *)roomId entry:(NSDictionary<NSString *,NSString *> *)entry {
    NSLog(@"chatRoomKVDidUpdate --- roomId：%@，entry：%@", roomId, entry);
    NSString *jsonString = @"";
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:entry
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (error) {
        jsonString = [entry description];
    }
    jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *targetString =
    [NSString stringWithFormat:@"chatRoomKVDidUpdate：共 %lu 个，\n roomId：%@，entry：%@",
     (unsigned long)entry.count, roomId, jsonString];
    [self addStringToDataSource:targetString];
}

- (void)chatRoomKVDidRemove:(NSString *)roomId entry:(NSDictionary<NSString *,NSString *> *)entry {
    NSLog(@"chatRoomKVDidRemove --- roomId：%@，entry：%@", roomId, entry);
    NSString *jsonString = @"";
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:entry
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (error) {
        jsonString = [entry description];
    }
    jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *targetString =
    [NSString stringWithFormat:@"chatRoomKVDidRemove：共 %lu 个，\n roomId：%@，entry：%@",
    (unsigned long)entry.count, roomId, jsonString];
    [self addStringToDataSource:targetString];
}

#pragma mark - Private Method
- (void)setupData {

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMessageNotification:)
                                                 name:RCKitDispatchMessageNotification
                                               object:nil];

    [self addStringToDataSource:[NSString stringWithFormat:@"加入聊天室：%@", self.roomId]];
    
    [[RCChatRoomClient sharedChatRoomClient] setRCChatRoomKVStatusChangeDelegate:self];
}


- (void)setupNav {
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithTitle:@"退出"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(onBackButtonClick:)];

    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:@"测试"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(onRightButtonClick:)];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    self.navigationItem.rightBarButtonItem = rightBarItem;
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];

    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-RCDExtraBottomHeight);
    }];
}

- (NSString *)errorCodeToString:(RCErrorCode)nErrorCode {
    NSString *errorString = @"";
    switch (nErrorCode) {
    case RC_EXCCED_MAX_KV_SIZE:
        errorString = @"超聊天室中最大设置 KV 值";
        break;
    case RC_TRY_OVERWRITE_INVALID_KEY:
        errorString = @"聊天室中非法覆盖 KEY 值";
        break;
    case RC_EXCCED_MAX_CALL_API_SIZE:
        errorString = @"超聊天室中 KV 设置频率";
        break;
    case RC_KV_STORE_NOT_AVAILABLE:
        errorString = @"聊天室 KV 功能没有开通";
        break;
    case RC_KEY_NOT_EXIST:
        errorString = @"聊天室 Key 不存在";
        break;
    case INVALID_PARAMETER:
        errorString = @"开发者接口调用时传入的参数错误";
        break;
    case RC_KV_STORE_NOT_SYNC:
        errorString = @"聊天室 KV 未同步完成";
        break;
    case RC_KV_STORE_NOT_ALL_SUCCESS:
        errorString = @"聊天室批量设置 KV 部分不成功";
        break;
    case RC_KV_STORE_OUT_OF_LIMIT:
        errorString = @"聊天室设置 KV，数量超限（最多一次10条）";
        break;
    default:
        errorString = @"其他错误码";
        break;
    }
    return errorString;
}

- (void)addStringToDataSource:(NSString *)string {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *targetString = @"";
        targetString = [NSString stringWithFormat:@"%@  %@", [self currentDateStr], string];
        [self.dataArray addObject:targetString];
        [self.tableView reloadData];
        [self scrollToBottomAnimated:YES];
    });
}

- (NSString *)currentDateStr {
    NSDate *currentDate = [NSDate date];
    NSTimeInterval time = [currentDate timeIntervalSince1970];
    NSString *dateString = [RCKitUtility convertConversationTime:time];
    return dateString;
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    if ([self.tableView numberOfSections] == 0) {
        return;
    }
    NSUInteger finalRow = MAX(0, [self.tableView numberOfRowsInSection:0] - 1);
    if (0 == finalRow) {
        return;
    }

    NSIndexPath *finalIndexPath = [NSIndexPath indexPathForRow:finalRow inSection:0];

    if (@available(iOS 13.0, *)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView scrollToRowAtIndexPath:finalIndexPath
                                  atScrollPosition:UITableViewScrollPositionBottom
                                          animated:animated];
        });
    } else {
        [self.tableView scrollToRowAtIndexPath:finalIndexPath
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:animated];
    }
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDDebugChatRoomCell *cell = [self.tableView dequeueReusableCellWithIdentifier:debugChatRoomCellIdentifier];
    if (cell == nil) {
        cell = [[RCDDebugChatRoomCell alloc] init];
    }
    cell.contentLabel.text = self.dataArray[indexPath.row];
    return cell;
}

#pragma mark - Getter && Setter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        [_tableView setSectionIndexColor:[UIColor darkGrayColor]];
        _tableView.estimatedRowHeight = 60;
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

@end
