//
//  RCDDebugDiscussionController.m
//  SealTalk
//
//  Created by 张改红 on 2020/8/20.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCDDebugDiscussionController.h"
#import "RCDTableView.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDDebugSelectView.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "UIView+MBProgressHUD.h"
#import <RongDiscussion/RongDiscussion.h>
@interface RCDDebugDiscussionController ()<UITableViewDelegate,UITableViewDataSource, RCDDebugSelectViewDelegate>
@property (nonatomic, strong) NSMutableArray *logList;
@property (nonatomic, strong) RCDTableView *tableView;
@property (nonatomic, strong) RCDDebugSelectView *selectView;
@property (nonatomic, strong) UITextField *firstTextField;
@property (nonatomic, strong) UITextField *secondTextField;
@property (nonatomic, strong) UITextField *threeTextField;
@property (nonatomic, strong) RCDiscussion *discussion;
@end

@implementation RCDDebugDiscussionController

- (void)viewDidLoad {
    [super viewDidLoad];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, cell.frame.size.height)];
    label.font = [UIFont systemFontOfSize:15];
    label.numberOfLines = 0;
    label.text = [NSString stringWithFormat:@"%@",self.logList[indexPath.row]];
    [cell.contentView addSubview:label];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = [RCKitUtility getTextDrawingSize:self.logList[indexPath.row] font:[UIFont systemFontOfSize:15] constrainedSize:CGSizeMake(self.view.frame.size.width-20, MAXFLOAT)].height + 10;
    return height;
}

#pragma mark - RCDDebugSelectViewDelegate
- (void)didTipItemClicked:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [self createDiscussion];
    }else if (indexPath.row == 1){
        [self addMemberToDiscussion];
    }else if (indexPath.row == 2){
        [self removeMemberFromDiscussion];
    }else if (indexPath.row == 3){
        [self renameDiscussionName];
    }else if (indexPath.row == 4){
        [self quitDiscussion];
    }else if (indexPath.row == 5){
        [self getDiscussionInfo];
    }else if (indexPath.row == 6){
        [self setDiscussionInviteStatus];
    }else if (indexPath.row == 7){
        [self sendDiscussionMessage];
    }
}

#pragma mark - privite
- (void)createDiscussion{
    __weak typeof(self) weakSelf = self;
    [[RCDiscussionClient sharedDiscussionClient] createDiscussion:@"讨论组" userIdList:@[@"1",@"2",@"3"] success:^(RCDiscussion * _Nonnull discussion) {
        weakSelf.discussion = discussion;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *str = [@"create success;;;" stringByAppendingFormat:@"%@;;;%@",weakSelf.discussion.discussionName,[weakSelf getJson:discussion.memberIdList]];
            [weakSelf.logList addObject:str];
            [weakSelf reloadViews];
        });
    } error:^(RCErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view showHUDMessage:[NSString stringWithFormat:@"create discussion failed:%ld",(long)status]];
        });
    }];
}

- (void)addMemberToDiscussion{
    __weak typeof(self) weakSelf = self;
    [[RCDiscussionClient sharedDiscussionClient] addMemberToDiscussion:self.discussion.discussionId userIdList:@[@"4",@"5"] success:^(RCDiscussion * _Nonnull discussion) {
        weakSelf.discussion = discussion;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *str = [@"add member;;;" stringByAppendingFormat:@"%@;;;%@",weakSelf.discussion.discussionName,[weakSelf getJson:discussion.memberIdList]];
            [weakSelf.logList addObject:str];
            [weakSelf reloadViews];
        });
    } error:^(RCErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view showHUDMessage:[NSString stringWithFormat:@"add member failed:%ld",(long)status]];
        });
    }];
}

- (void)removeMemberFromDiscussion{
    __weak typeof(self) weakSelf = self;
    [[RCDiscussionClient sharedDiscussionClient] removeMemberFromDiscussion:weakSelf.discussion.discussionId userId:@"5" success:^(RCDiscussion * _Nonnull discussion) {
        weakSelf.discussion = discussion;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *str = [@"remove member;;;" stringByAppendingFormat:@"%@;;;%@",weakSelf.discussion.discussionName,[weakSelf getJson:discussion.memberIdList]];
            [weakSelf.logList addObject:str];
            [weakSelf reloadViews];
        });
    } error:^(RCErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view showHUDMessage:[NSString stringWithFormat:@"remove member failed:%ld",(long)status]];
        });
    }];
}

- (void)renameDiscussionName{
    __weak typeof(self) weakSelf = self;
    [[RCDiscussionClient sharedDiscussionClient] setDiscussionName:weakSelf.discussion.discussionId name:@"讨论组 1" success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *str = @"rename success;;;";
            [weakSelf.logList addObject:str];
            [weakSelf reloadViews];
        });
    } error:^(RCErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view showHUDMessage:[NSString stringWithFormat:@"rename failed:%ld",(long)status]];
        });
    }];
}

- (void)quitDiscussion{
    __weak typeof(self) weakSelf = self;
    [[RCDiscussionClient sharedDiscussionClient] quitDiscussion:weakSelf.discussion.discussionId success:^(RCDiscussion * _Nonnull discussion) {
        weakSelf.discussion = discussion;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *str = [@"quit success;;;" stringByAppendingFormat:@"%@;;;%@",weakSelf.discussion.discussionName,[weakSelf getJson:discussion.memberIdList]];
            [weakSelf.logList addObject:str];
            [weakSelf reloadViews];
        });
    } error:^(RCErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view showHUDMessage:[NSString stringWithFormat:@"quit failed:%ld",(long)status]];
        });
    }];
}

- (void)getDiscussionInfo{
    __weak typeof(self) weakSelf = self;
    [[RCDiscussionClient sharedDiscussionClient] getDiscussion:weakSelf.discussion.discussionId success:^(RCDiscussion * _Nonnull discussion) {
        weakSelf.discussion = discussion;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *str = [@"get discussion success;;;" stringByAppendingFormat:@"%@;;;%@;;;%d",weakSelf.discussion.discussionName,[weakSelf getJson:discussion.memberIdList],weakSelf.discussion.inviteStatus];
            [weakSelf.logList addObject:str];
            [weakSelf reloadViews];
        });
    } error:^(RCErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view showHUDMessage:[NSString stringWithFormat:@"quit failed:%ld",(long)status]];
        });
    }];
}

- (void)setDiscussionInviteStatus{
    __weak typeof(self) weakSelf = self;
    [[RCDiscussionClient sharedDiscussionClient] setDiscussionInviteStatus:weakSelf.discussion.discussionId isOpen:weakSelf.discussion.inviteStatus == 1 ? YES:NO success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *str = [@"set invite status success" stringByAppendingFormat:@"%d",weakSelf.discussion.inviteStatus==1?0:1 ];
            [weakSelf.logList addObject:str];
            [weakSelf reloadViews];
        });
    } error:^(RCErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view showHUDMessage:[NSString stringWithFormat:@"set invite status failed:%ld",(long)status]];
        });
    }];
}

- (void)sendDiscussionMessage{
    RCDiscussionNotificationMessage *message = [[RCDiscussionNotificationMessage alloc] init];
    message.type = RCInviteDiscussionNotification;
    message.operatorId = [RCIM sharedRCIM].currentUserInfo.userId;
//    RCTextMessage *msg = [RCTextMessage messageWithContent:@"123"];
    __weak typeof(self) weakSelf = self;
    [[RCIM sharedRCIM] sendMessage:ConversationType_DISCUSSION targetId:self.discussion.discussionId content:message pushContent:nil pushData:nil success:^(long messageId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *str = @"send message success";
            [weakSelf.logList addObject:str];
            [weakSelf reloadViews];
        });
    } error:^(RCErrorCode nErrorCode, long messageId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view showHUDMessage:[NSString stringWithFormat:@"send message failed:%ld",(long)nErrorCode]];
        });
    }];
}

- (void)reloadViews{
    [self.tableView reloadData];
    if (self.logList.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.logList.count - 1 inSection:0] atScrollPosition:(UITableViewScrollPositionBottom) animated:YES];
    }
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
        _tableView = [[RCDTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 290)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return _tableView;
}
- (RCDDebugSelectView *)selectView{
    if (!_selectView) {
        _selectView = [[RCDDebugSelectView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 290, self.view.frame.size.width, 200) titleList:@[@"创建讨论组", @"讨论组加人", @"讨论组删人", @"修改讨论组名称", @"退出讨论组", @"获取讨论组信息",@"设置加人权限",@"发送讨论组消息"]];
        _selectView.debugSelectViewDelegate = self;
    }
    return _selectView;
}

- (NSString *)getJson:(id )sender{
    if (!sender) {
        return @"";
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:sender options:kNilOptions error:nil];
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return json;
}
@end

