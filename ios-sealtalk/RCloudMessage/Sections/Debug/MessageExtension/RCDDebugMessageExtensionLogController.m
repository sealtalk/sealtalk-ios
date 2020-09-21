//
//  RCDDebugMessageExtensionLogController.m
//  SealTalk
//
//  Created by 张改红 on 2020/8/5.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCDDebugMessageExtensionLogController.h"
#import "RCDTableView.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDDebugSelectView.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "UIView+MBProgressHUD.h"
#import "RCDDebubMessageUIdListView.h"
@interface RCDDebugMessageExtensionLogController ()<UITableViewDelegate,UITableViewDataSource, RCDDebugSelectViewDelegate, RCMessageExpansionDelegate>{
    NSString *text;
    NSMutableDictionary *setDic;
    NSMutableArray *removeKeys;
}
@property (nonatomic, strong) NSMutableArray *logList;
@property (nonatomic, strong) RCDTableView *tableView;
@property (nonatomic, strong) RCDDebugSelectView *selectView;
@property (nonatomic, strong) UITextField *firstTextField;
@property (nonatomic, strong) UITextField *secondTextField;
@property (nonatomic, strong) UITextField *threeTextField;
@end

@implementation RCDDebugMessageExtensionLogController

- (void)viewDidLoad {
    [super viewDidLoad];
    [RCIMClient sharedRCIMClient].messageExpansionDelegate = self;
    setDic = @{}.mutableCopy;
    removeKeys = @[].mutableCopy;
    self.logList = [NSMutableArray array];
    [self.view addSubview:self.selectView];
    [self.view addSubview:self.tableView];
    [self setNaviItem];
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.logList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //    根据indexPath准确地取出一行，而不是从cell重用队列中取出
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //    如果如果没有多余单元，则需要创建新的单元
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = [NSString stringWithFormat:@"%@",self.logList[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = [RCKitUtility getTextDrawingSize:self.logList[indexPath.row] font:[UIFont systemFontOfSize:15] constrainedSize:CGSizeMake(self.view.frame.size.width-40, MAXFLOAT)].height + 10;
    return height;
}

#pragma mark - RCMessageExpansionDelegate
- (void)messageExpansionDidUpdate:(NSDictionary<NSString *,NSString *> *)expansionDic message:(RCMessage *)message{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *str = [@"扩展信息设置监听: \n" stringByAppendingFormat:@"messageUid: %@;;;\n setKeys: %@;;;\nExpansion:%@",message.messageUId,[self getJson:expansionDic.copy],[self getJson:message.expansionDic]];
        [weakSelf.logList addObject:str];
        [weakSelf reloadViews];
    });
}

- (void)messageExpansionDidRemove:(NSArray<NSString *> *)keyArray message:(RCMessage *)message{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *str = [@"扩展信息移除监听: \n" stringByAppendingFormat:@"messageUid: %@;;;\n removeKeys: %@;;;\nExpansion:%@",message.messageUId,[self getJson:keyArray.copy],[self getJson:message.expansionDic]];
        [weakSelf.logList addObject:str];
        [weakSelf reloadViews];
    });
}

#pragma mark - RCDDebugSelectViewDelegate
- (void)didTipItemClicked:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [self setMessageExpansion];
    }else if (indexPath.row == 1){
        [self removeMessageExpansion];
    }else if (indexPath.row == 2){
        [self getDBMessages];
    }else if (indexPath.row == 3){
        [self getRemoteMessages];
    }else if (indexPath.row == 4){
        [self sendMessage];
    }
}

#pragma mark - privite
- (void)setMessageExpansion{
    [setDic removeAllObjects];
    __weak typeof(self) weakSelf = self;
    [RCDDebubMessageUIdListView showMessageUIdListView:self.view conversationType:self.conversationType targetId:self.targetId selectMessageBlock:^(RCMessage * _Nonnull message) {
        [self showsSetKeyAlert:message.messageUId complete:^(NSString *uId) {
            [[RCIMClient sharedRCIMClient] updateMessageExpansion:setDic.copy messageUId:uId success:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.view showHUDMessage:@"set success"];
                    NSString *str = [@"设置 key: \n" stringByAppendingFormat:@"messageUid: %@;;;\n setKeys: %@",uId,[self getJson:setDic.copy]];
                    [weakSelf.logList addObject:str];
                    [weakSelf reloadViews];
                });
            } error:^(RCErrorCode status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.view showHUDMessage:[NSString stringWithFormat:@"set failed:%ld",(long)status]];
                });
            }];
        }];
    }];
    
}

- (void)removeMessageExpansion{
    [removeKeys removeAllObjects];
    [RCDDebubMessageUIdListView showMessageUIdListView:self.view conversationType:self.conversationType targetId:self.targetId selectMessageBlock:^(RCMessage * _Nonnull message) {
        [self showsRemoveKeyAlert:message.messageUId complete:^(NSString *uId) {
            __weak typeof(self) weakSelf = self;
            [[RCIMClient sharedRCIMClient] removeMessageExpansionForKey:removeKeys.copy messageUId:uId success:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view showHUDMessage:@"remove success"];
                    NSString *str = [@"删除 key: " stringByAppendingFormat:@"messageUid: %@;;;\n keys: %@",uId,[self getJson:removeKeys.copy]];
                    [weakSelf.logList addObject:str];
                    [weakSelf reloadViews];
                });
            } error:^(RCErrorCode status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view showHUDMessage:[NSString stringWithFormat:@"remove failed:%ld",(long)status]];
                });
            }];
        }];
    }];
}

//- (void)removeMessageAllExpansion{
//    [RCDDebubMessageUIdListView showMessageUIdListView:self.view conversationType:self.conversationType targetId:self.targetId selectMessageBlock:^(RCMessage * _Nonnull message) {
//        __weak typeof(self) weakSelf = self;
//        [[RCIMClient sharedRCIMClient] removeMessageAllExpansion:message.messageUId success:^{
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.view showHUDMessage:@"remove success"];
//                NSString *str = [@"删除所有 key: " stringByAppendingFormat:@"messageUid: %@",message.messageUId];
//                [weakSelf.logList addObject:str];
//                [weakSelf reloadViews];
//            });
//        } error:^(RCErrorCode status) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.view showHUDMessage:[NSString stringWithFormat:@"remove failed:%ld",status]];
//            });
//        }];
//    }];
//}

- (void)getDBMessages{
    NSArray *array = [[RCIMClient sharedRCIMClient] getHistoryMessages:self.conversationType targetId:self.targetId oldestMessageId:-1 count:5];
    for (RCMessage *message in array) {
        NSString *str = [@"获取本地历史消息：\n" stringByAppendingFormat:@"messsageId: %ld;;;\nMessageUid: %@;;;\nContent: %@;;;\nExpansion: %@",message.messageId,message.messageUId,[[NSString alloc] initWithData:[message.content encode] encoding:NSUTF8StringEncoding],[self getJson:message.expansionDic]];
        [self.logList addObject:str];
    }
    if(array.count == 0){
        NSString *str = @"本地没有历史消息";
        [self.logList addObject:str];
    }
    [self reloadViews];
}

- (void)getRemoteMessages{
    [[RCIMClient sharedRCIMClient] deleteMessages:self.conversationType targetId:self.targetId success:^{
        
    } error:^(RCErrorCode status) {
        
    }];
    RCRemoteHistoryMsgOption *option = [[RCRemoteHistoryMsgOption alloc] init];
    option.count = 5;
    __weak typeof(self) weakSelf = self;
    [[RCIMClient sharedRCIMClient] getRemoteHistoryMessages:self.conversationType targetId:self.targetId option:option success:^(NSArray *messages, BOOL isRemaining) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(messages.count == 0){
                NSString *str = @"服务端没有历史消息";
                [weakSelf.logList addObject:str];
            }
            for (RCMessage *message in messages) {
                NSString *str = [@"获取服务端消息：\n" stringByAppendingFormat:@"messageId: %ld;;;\nmessageUid: %@;;;\ncontent: %@;;;\nExtension: %@",message.messageId,message.messageUId,[[NSString alloc] initWithData:[message.content encode] encoding:NSUTF8StringEncoding],[self getJson:message.expansionDic]];
                [weakSelf.logList addObject:str];
            }
            [weakSelf reloadViews];
        });
    } error:^(RCErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view showHUDMessage:[NSString stringWithFormat:@"get remote history failed:%ld",(long)status]];
        });
    }];
}

- (void)sendMessage{
    [self showTextInputAlert:^() {
        RCTextMessage *txt = [RCTextMessage messageWithContent:text];
        RCMessage *msg = [[RCMessage alloc] initWithType:self.conversationType targetId:self.targetId direction:(MessageDirection_SEND) messageId:-1 content:txt];
        msg.canIncludeExpansion = YES;
        msg.expansionDic = setDic.copy;
        __weak typeof(self) weakSelf = self;
        [[RCIMClient sharedRCIMClient] sendMessage:msg pushContent:nil pushData:nil successBlock:^(RCMessage *successMessage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view showHUDMessage:[NSString stringWithFormat:@"send message success"]];
                NSString *str = [@"发送消息：\n" stringByAppendingFormat:@"messageId:%ld;;;\nmessageUid:%@;;;\ncontent:%@;;;\nExtension: %@",successMessage.messageId,successMessage.messageUId,[[NSString alloc] initWithData:[successMessage.content encode] encoding:NSUTF8StringEncoding],[self getJson:successMessage.expansionDic]];
                [weakSelf.logList addObject:str];
                [weakSelf reloadViews];
            });
        } errorBlock:^(RCErrorCode nErrorCode, RCMessage *errorMessage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view showHUDMessage:[NSString stringWithFormat:@"send message failed:%ld",(long)nErrorCode]];
            });
        }];
    }];
}

- (void)reloadViews{
    [self.tableView reloadData];
    if (self.logList.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.logList.count - 1 inSection:0] atScrollPosition:(UITableViewScrollPositionBottom) animated:YES];
    }
}

- (void)showsSetKeyAlert:(NSString *)msgUid complete:(void (^)(NSString *uid))complete{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"设置 Key" message:msgUid preferredStyle:UIAlertControllerStyleAlert];
    //增加确定按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSArray *textFieldArr = alertController.textFields;
        UITextField *keyTF = textFieldArr[0];
        UITextField *valueTF = textFieldArr[1];
        if (keyTF.text.length > 0) {
            [setDic setValue:valueTF.text forKey:keyTF.text];
        }
        complete(msgUid);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"继续添加" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSArray *textFieldArr = alertController.textFields;
        UITextField *keyTF = textFieldArr[0];
        UITextField *valueTF = textFieldArr[1];
        if (keyTF.text.length > 0) {
            [setDic setValue:valueTF.text forKey:keyTF.text];
        }
        [self showsSetKeyAlert:msgUid complete:^(NSString *uid) {
            complete(msgUid);
        }];
    }]];
    //增加取消按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Key";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Value";
    }];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)showsRemoveKeyAlert:(NSString *)msgUid complete:(void (^)(NSString *uid))complete{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除 Key" message:msgUid preferredStyle:UIAlertControllerStyleAlert];
    //增加确定按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSArray *textFieldArr = alertController.textFields;
        UITextField *keyTF = textFieldArr[0];
        if (keyTF.text.length > 0) {
            [removeKeys addObject:keyTF.text];
        }
        complete(msgUid);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"继续添加" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSArray *textFieldArr = alertController.textFields;
        UITextField *keyTF = textFieldArr[0];
        if (keyTF.text.length > 0) {
            [removeKeys addObject:keyTF.text];
        }
        [self showsRemoveKeyAlert:msgUid complete:^(NSString *uid) {
            complete(msgUid);
        }];
    }]];
    //增加取消按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Key";
    }];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)showTextInputAlert:(void (^)())complete{
    [setDic removeAllObjects];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"发送消息" message:nil preferredStyle:UIAlertControllerStyleAlert];
    //增加确定按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSArray *textFieldArr = alertController.textFields;
        UITextField *textTF = textFieldArr.firstObject;
        text = textTF.text;
        complete();
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"添加 Key" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSArray *textFieldArr = alertController.textFields;
        UITextField *textTF = textFieldArr.firstObject;
        text = textTF.text;
        [self showsSetKeyAlert:nil complete:^(NSString *uid) {
            complete();
        }];
    }]];
    //增加取消按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"输入文本";
        }];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)setNaviItem{
   //创建rightBarButtonItem
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"清理"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(clickDoneBtn)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)clickDoneBtn{
    [self.logList removeAllObjects];
    [self.tableView reloadData];
}

#pragma mark - getter
- (RCDTableView *)tableView {
    if (!_tableView) {
        _tableView = [[RCDTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 240)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return _tableView;
}
- (RCDDebugSelectView *)selectView{
    if (!_selectView) {
        _selectView = [[RCDDebugSelectView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 240, self.view.frame.size.width, 150) titleList:@[@"设置 Key", @"删除 Key", @"获取本地消息", @"获取服务端消息", @"发送文本消息"]];
        _selectView.debugSelectViewDelegate = self;
    }
    return _selectView;
}

- (NSString *)getJson:(id )sender{
    if(!sender) {
        return @"";
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:sender options:kNilOptions error:nil];
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return json;
}
@end
