//
//  RCDDebugConversationTagController.m
//  SealTalk
//
//  Created by 张改红 on 2021/2/1.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "RCDDebugConversationTagController.h"
#import "RCDTableView.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDDebugSelectView.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "UIView+MBProgressHUD.h"
#import "RCDDebubMessageUIdListView.h"
#import <RongIMLibCore/RongIMLibCore.h>
@interface RCDDebugConversationTagController ()<UITableViewDelegate,UITableViewDataSource, RCDDebugSelectViewDelegate, RCTagDelegate, RCConversationTagDelegate>
@property (nonatomic, strong) NSMutableArray *logList;
@property (nonatomic, strong) RCDTableView *tableView;
@property (nonatomic, strong) RCDDebugSelectView *selectView;
@property (nonatomic, strong) UITextField *firstTextField;
@property (nonatomic, strong) UITextField *secondTextField;
@property (nonatomic, strong) UITextField *threeTextField;
@end

@implementation RCDDebugConversationTagController

- (void)viewDidLoad {
    [super viewDidLoad];
    [RCCoreClient sharedCoreClient].tagDelegate = self;
    [RCCoreClient sharedCoreClient].conversationTagDelegate = self;
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    CGRect rect = cell.contentView.bounds;
    rect.origin.y = 0;
    rect.origin.x = 10;
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.font = [UIFont systemFontOfSize:15];
    label.numberOfLines = 0;
    label.text = [NSString stringWithFormat:@"%@",self.logList[indexPath.row]];
    [cell.contentView addSubview:label];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = [RCKitUtility getTextDrawingSize:self.logList[indexPath.row] font:[UIFont systemFontOfSize:15] constrainedSize:CGSizeMake(self.view.frame.size.width-20, MAXFLOAT)].height + 20;
    return height;
}

#pragma mark - RCTagDelegate

- (void)onTagChanged{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *str = @"onTagChanged";
        [self.logList addObject:str];
        [self reloadViews];
    });
}

#pragma mark - RCConversationTagDelegate

- (void)onConversationTagChanged{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *str = @"onConversationTagChanged";
        [self.logList addObject:str];
        [self reloadViews];
    });
}

#pragma mark - RCDDebugSelectViewDelegate
- (void)didTipItemClicked:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [self addTag];
    }else if (indexPath.row == 1){
        [self removeTag];
    }else if (indexPath.row == 2){
        [self updateTag];
    }else if (indexPath.row == 3){
        [self getTags];
    }else if (indexPath.row == 4){
        [self addConversationsForTag];
    }else if (indexPath.row == 5){
        [self removeConversationsForTag];
    }else if (indexPath.row == 6){
        [self removeTagsForConversation];
    }else if (indexPath.row == 7){
        [self getTagsForconversationIdentifier];
    }else if (indexPath.row == 8){
        [self getConvesationsForTag];
    }else if (indexPath.row == 9){
        [self getTagForConversation];
    }else if (indexPath.row == 10){
        [self getUnreadCountForTag];
    }else if (indexPath.row == 11){
        [self setConversationToTopForTag];
    }else if (indexPath.row == 12){
        [self clearUnreadCountFotTag];
    }else if (indexPath.row == 13){
        [self clearConversationFotTag];
    }
}

#pragma mark - privite
- (void)addTag{
    __weak typeof(self) weakSelf = self;
    [self showTextInputAlert:@[@"tagId",@"tagName"] complete:^(NSArray *texts) {
        RCTagInfo *tag = [[RCTagInfo alloc] init];
        tag.tagId = texts[0];
        tag.tagName = texts[1];
        [[RCCoreClient sharedCoreClient] addTag:tag success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view showHUDMessage:@"add tag success"];
                NSString *str = [@"添加标签: \n" stringByAppendingFormat:@"tagId: %@;;; tagName: %@",tag.tagId,tag.tagName];
                [weakSelf.logList addObject:str];
                [weakSelf reloadViews];
            });
        } error:^(RCErrorCode errorCode) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view showHUDMessage:[NSString stringWithFormat:@"add tag failed: %ld",(long)errorCode]];
            });
        }];
    }];
}

- (void)removeTag{
    __weak typeof(self) weakSelf = self;
    [self showTextInputAlert:@[@"tagId"] complete:^(NSArray *texts) {
        [[RCCoreClient sharedCoreClient] removeTag:texts[0] success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view showHUDMessage:@"remove tag success"];
                NSString *str = [@"移除标签: \n" stringByAppendingFormat:@"tagId: %@;;;",texts[0]];
                [weakSelf.logList addObject:str];
                [weakSelf reloadViews];
            });
        } error:^(RCErrorCode errorCode) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view showHUDMessage:[NSString stringWithFormat:@"remove tag failed: %ld",(long)errorCode]];
            });
        }];
    }];
}

- (void)updateTag{
    __weak typeof(self) weakSelf = self;
    [self showTextInputAlert:@[@"tagId",@"tagName"] complete:^(NSArray *texts) {
        RCTagInfo *tag = [[RCTagInfo alloc] init];
        tag.tagId = texts[0];
        tag.tagName = texts[1];
        [[RCCoreClient sharedCoreClient] updateTag:tag success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view showHUDMessage:@"update tag success"];
                NSString *str = [@"更新标签: \n" stringByAppendingFormat:@"tagId: %@;;; tagName: %@",tag.tagId,tag.tagName];
                [weakSelf.logList addObject:str];
                [weakSelf reloadViews];
            });
        } error:^(RCErrorCode errorCode) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view showHUDMessage:[NSString stringWithFormat:@"update tag failed: %ld",(long)errorCode]];
            });
        }];
    }];
}

- (void)getTags{
    NSArray *tags = [[RCCoreClient sharedCoreClient] getTags];
    NSString *str = [@"获取所有标签:" stringByAppendingFormat:@"%lu",(unsigned long)tags.count];
    for (RCTagInfo *tag in tags) {
        str = [str stringByAppendingFormat:@"\ntagId: %@;;; tagName: %@;;; count:%ld;;;ts:%lld",tag.tagId,tag.tagName, (long)tag.count,tag.timestamp];
    }
    [self.logList addObject:str];
    [self reloadViews];
}

- (void)addConversationsForTag{
    __weak typeof(self) weakSelf = self;
    [self showTextInputAlert:@[@"tagId",@"targetId"] complete:^(NSArray *texts) {
        RCConversationIdentifier *iden = [[RCConversationIdentifier alloc] init];
        iden.type = ConversationType_PRIVATE;
        iden.targetId = texts[1];
        [[RCCoreClient sharedCoreClient] addConversationsToTag:texts[0] conversationIdentifiers:@[iden] success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view showHUDMessage:@"addConversationsForTag success"];
                NSString *str = [@"添加会话到标签: \n" stringByAppendingFormat:@"tagId: %@;;;type %lu;;;targetId: %@",texts[0],(unsigned long)iden.type,texts[1]];
                [weakSelf.logList addObject:str];
                [weakSelf reloadViews];
            });
        } error:^(RCErrorCode errorCode) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view showHUDMessage:[NSString stringWithFormat:@"addConversationsForTag failed: %ld",(long)errorCode]];
            });
        }];
    }];
}

- (void)removeConversationsForTag{
    __weak typeof(self) weakSelf = self;
    [self showTextInputAlert:@[@"tagId",@"targetId"] complete:^(NSArray *texts) {
        RCConversationIdentifier *iden = [[RCConversationIdentifier alloc] init];
        iden.type = ConversationType_PRIVATE;
        iden.targetId = texts[1];
        [[RCCoreClient sharedCoreClient] removeConversationsFromTag:texts[0] conversationIdentifiers:@[iden] success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view showHUDMessage:@"removeConversationsForTag success"];
                NSString *str = [@"删除标签中会话: \n" stringByAppendingFormat:@"tagId: %@;;;type %lu;;;targetId: %@",texts[0],(unsigned long)iden.type,texts[1]];
                [weakSelf.logList addObject:str];
                [weakSelf reloadViews];
            });
        } error:^(RCErrorCode errorCode) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view showHUDMessage:[NSString stringWithFormat:@"removeConversationsForTag failed: %ld",(long)errorCode]];
            });
        }];
    }];
}

- (void)removeTagsForConversation{
    __weak typeof(self) weakSelf = self;
    [self showTextInputAlert:@[@"tagId",@"targetId"] complete:^(NSArray *texts) {
        RCConversationIdentifier *iden = [[RCConversationIdentifier alloc] init];
        iden.type = ConversationType_PRIVATE;
        iden.targetId = texts[1];
        [[RCCoreClient sharedCoreClient] removeTagsFromConversation:iden tagIds:@[texts[0]] success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view showHUDMessage:@"removeTagsForConversation success"];
                NSString *str = [@"删除会话的标签: \n" stringByAppendingFormat:@"tagId: %@;;;type %lu;;;targetId: %@",texts[0],(unsigned long)iden.type,texts[1]];
                [weakSelf.logList addObject:str];
                [weakSelf reloadViews];
            });
        } error:^(RCErrorCode errorCode) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view showHUDMessage:[NSString stringWithFormat:@"removeTagsForConversation failed: %ld",(long)errorCode]];
            });
        }];
    }];
}

- (void)getTagsForconversationIdentifier{
    __weak typeof(self) weakSelf = self;
    [self showTextInputAlert:@[@"targetId"] complete:^(NSArray *texts) {
        RCConversationIdentifier *iden = [[RCConversationIdentifier alloc] init];
        iden.type = ConversationType_PRIVATE;
        iden.targetId = texts[0];
        NSArray<RCConversationTagInfo *> *list = [[RCCoreClient sharedCoreClient] getTagsFromConversation:iden];
        NSString *str = [@"获取某个会话中标签:" stringByAppendingFormat:@"%@(%lu)",iden.targetId ,(unsigned long)list.count];
        for (RCConversationTagInfo *info in list) {
            str = [str stringByAppendingFormat:@"\ntagId: %@;;; tagName: %@;;; count:%ld;;; ts:%lld;;; istop:%d",info.tagInfo.tagId, info.tagInfo.tagName, (long)info.tagInfo.count, info.tagInfo.timestamp, info.isTop];
        }
        [weakSelf.logList addObject:str];
        [weakSelf reloadViews];
    }];
}

- (void)getTagForConversation{
    __weak typeof(self) weakSelf = self;
    [self showTextInputAlert:@[@"targetId",@"tagId"] complete:^(NSArray *texts) {
        RCConversationIdentifier *iden = [[RCConversationIdentifier alloc] init];
        iden.type = ConversationType_PRIVATE;
        iden.targetId = texts[0];
        BOOL isTop = [[RCCoreClient sharedCoreClient] getConversationTopStatusInTag:iden tagId:texts[1]];
        NSString *str = [@"获取某个会话的某个标签:" stringByAppendingFormat:@"\ntagId: %@;;; targetId: %@;;; istop:%d",texts[1], iden.targetId, isTop];
        [weakSelf.logList addObject:str];
        [weakSelf reloadViews];
    }];
}

- (void)getConvesationsForTag{
    __weak typeof(self) weakSelf = self;
    [self showTextInputAlert:@[@"tagId"] complete:^(NSArray *texts) {
        NSArray<RCConversation *> *list = [[RCCoreClient sharedCoreClient] getConversationsFromTagByPage:texts[0] timestamp:0 count:20];
        NSString *str = [@"获取标签中会话:" stringByAppendingFormat:@"%lu",(unsigned long)list.count];
        for (RCConversation *info in list) {
            str = [str stringByAppendingFormat:@"\ntype: %lu;;;targetId: %@",(unsigned long)info.conversationType, info.targetId];
        }
        [weakSelf.logList addObject:str];
        [weakSelf reloadViews];
    }];
}

- (void)getUnreadCountForTag{
    __weak typeof(self) weakSelf = self;
    [self showTextInputAlert:@[@"tagId",@"isBlocked"] complete:^(NSArray *texts) {
        BOOL isBlocked = ([texts[1]  isEqual: @"0"] ? NO : YES);
        int count = [[RCCoreClient sharedCoreClient] getUnreadCountByTag:texts[0] containBlocked:isBlocked];
        NSString *str = [@"获取标签中会话消息未读数:" stringByAppendingFormat:@"%d",count];
        [weakSelf.logList addObject:str];
        [weakSelf reloadViews];
    }];
}

- (void)setConversationToTopForTag{
    __weak typeof(self) weakSelf = self;
    [self showTextInputAlert:@[@"tagId",@"targetId",@"isTop"] complete:^(NSArray *texts) {
        BOOL isTop = ([texts[2]  isEqual: @"0"] ? NO : YES);
        RCConversationIdentifier *iden = [[RCConversationIdentifier alloc] init];
        iden.type = ConversationType_PRIVATE;
        iden.targetId = texts[1];
        [[RCCoreClient sharedCoreClient] setConversationToTopInTag:texts[0] conversationIdentifier:iden isTop:isTop success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view showHUDMessage:@"setConversationToTopForTag success"];
                NSString *str = [@"设置标签中会话置顶: \n" stringByAppendingFormat:@"tagId: %@;;;type %lu;;;targetId: %@",texts[0],(unsigned long)iden.type,texts[1]];
                [weakSelf.logList addObject:str];
                [weakSelf reloadViews];
            });
        } error:^(RCErrorCode errorCode) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view showHUDMessage:[NSString stringWithFormat:@"setConversationToTopForTag failed: %ld",(long)errorCode]];
            });
        }];
    }];
}

- (void)clearUnreadCountFotTag {
    __weak typeof(self) weakSelf = self;
    [self showTextInputAlert:@[@"tagId"] complete:^(NSArray *texts) {
        BOOL isSuccess = [[RCCoreClient sharedCoreClient] clearMessagesUnreadStatusByTag:texts[0]];
        NSString *str = [NSString stringWithFormat:@"清除标签 %@ 对应会话的未读数:%@", texts[0], isSuccess ? @"成功" : @"失败"];
        [weakSelf.logList addObject:str];
        [weakSelf reloadViews];
    }];
}

- (void)clearConversationFotTag {
    __weak typeof(self) weakSelf = self;
    [self showTextInputAlert:@[@"tagId", @"needDeleteMessage"] complete:^(NSArray *texts) {
        BOOL needDelete = ([texts[1]  isEqual: @"0"] ? NO : YES);
        RCClearConversationOption *option = [[RCClearConversationOption alloc] init];
        option.isDeleteMessage = needDelete;
        [[RCCoreClient sharedCoreClient] clearConversationsByTag:texts[0] option:option success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view showHUDMessage:@"clearConversationFotTag success"];
                NSString *str = [NSString stringWithFormat:@"清除标签 %@ 中的会话, %@清除本地历史消息", texts[0], needDelete ? @"" : @"不"];
                [weakSelf.logList addObject:str];
                [weakSelf reloadViews];
            });
        } error:^(RCErrorCode errorCode) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view showHUDMessage:[NSString stringWithFormat:@"setConversationToTopForTag failed: %ld",(long)errorCode]];
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

- (void)showTextInputAlert:(NSArray *)titleList complete:(void (^)(NSArray *texts))complete{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:nil preferredStyle:UIAlertControllerStyleAlert];
    for (NSString *string in titleList) {
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = string;
        }];
    }
    //增加确定按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSArray *textFieldArr = alertController.textFields;
        NSMutableArray *texts = [NSMutableArray array];
        for (UITextField *textField in textFieldArr) {
            [texts addObject:textField.text];
        }
        complete(texts);
    }]];
    //增加取消按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
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
        _selectView = [[RCDDebugSelectView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 240, self.view.frame.size.width, 150) titleList:@[@"添加标签", @"删除标签", @"更新标签", @"获取标签列表", @"添加会话到标签", @"删除标签中的会话", @"删除会话的标签", @"获取会话标签", @"获取标签中的会话",@"获取会话标签的置顶状态", @"获取标签下会话未读数",@"设置标签下会话置顶",@"清除标签对应会话的未读数",@"删除标签对应的会话"]];
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
