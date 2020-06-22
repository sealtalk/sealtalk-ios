//
//  RCDCleanChatHistoryViewController.m
//  SealTalk
//
//  Created by 孙浩 on 2019/8/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDCleanChatHistoryViewController.h"
#import <RongIMKit/RongIMKit.h>
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>
#import "RCDUIBarButtonItem.h"
#import "RCDForwardSelectedCell.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "NormalAlertView.h"
#import "UIView+MBProgressHUD.h"
#import "RCDTableView.h"
static NSString *cleanConversationCellIdentifier = @"RCDCleanConversationCellIdentifier";

@interface RCDCleanChatHistoryViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) RCDTableView *tableView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *allSelectBtn;
@property (nonatomic, strong) UIButton *deleteBtn;

@property (nonatomic, strong) NSArray *conversationList;
@property (nonatomic, strong) NSMutableArray *deleteConversationArray;

@end

@implementation RCDCleanChatHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupData];
    [self setupViews];
    [self setupNavi];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.conversationList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDForwardSelectedCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cleanConversationCellIdentifier];
    if (cell == nil) {
        cell = [[RCDForwardSelectedCell alloc] init];
    }
    RCConversation *conversation = self.conversationList[indexPath.row];
    RCDForwardCellModel *model = [RCDForwardCellModel createModelWith:conversation];
    [cell setModel:model];
    cell.selectStatus = RCDForwardSelectedStatusMultiUnSelected;
    if ([self.deleteConversationArray containsObject:conversation]) {
        cell.selectStatus = RCDForwardSelectedStatusMultiSelected;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    RCDForwardSelectedCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    RCConversation *conversation = self.conversationList[indexPath.row];
    if (cell.selectStatus == RCDForwardSelectedStatusMultiUnSelected) {
        [self.deleteConversationArray addObject:conversation];
        cell.selectStatus = RCDForwardSelectedStatusMultiSelected;
    } else {
        [self.deleteConversationArray removeObject:conversation];
        cell.selectStatus = RCDForwardSelectedStatusMultiUnSelected;
    }
    // 手动全选处理全选按钮
    self.allSelectBtn.selected = self.deleteConversationArray.count == self.conversationList.count;
    self.deleteBtn.enabled = self.deleteConversationArray.count > 0;
}

#pragma mark - Private Method
- (void)setupData {
    NSArray *conversations =
        [[RCIMClient sharedRCIMClient] getConversationList:@[ @(ConversationType_PRIVATE), @(ConversationType_GROUP) ]];
    NSMutableArray *dealWithArray = [NSMutableArray array];
    for (RCConversation *conversation in conversations) {
        if (![conversation.targetId isEqualToString:RCDGroupNoticeTargetId]) {
            [dealWithArray addObject:conversation];
        }
    }
    self.conversationList = [dealWithArray copy];
    self.deleteConversationArray = [NSMutableArray array];
}

- (void)setupViews {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.bottomView];
    [self.bottomView addSubview:self.allSelectBtn];
    [self.bottomView addSubview:self.deleteBtn];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.bottomView.mas_top);
    }];

    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.height.offset(49 + RCDExtraBottomHeight);
    }];

    [self.allSelectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView).offset(13);
        make.height.offset(25);
        make.left.equalTo(self.bottomView).offset(12);
    }];

    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(self.allSelectBtn);
        make.right.equalTo(self.bottomView).offset(-12);
    }];

    self.allSelectBtn.enabled = self.conversationList.count > 0;
}

- (void)setupNavi {
    self.title = RCDLocalizedString(@"CleanChatHistory");
    RCDUIBarButtonItem *leftButton = [[RCDUIBarButtonItem alloc] initWithLeftBarButton:RCDLocalizedString(@"back")
                                                                                target:self
                                                                                action:@selector(clickBackBtn:)];
    self.navigationItem.leftBarButtonItem = leftButton;
}

- (void)deleteConversation {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = RCDLocalizedString(@"Deleting");
    [hud show:YES];
    for (RCConversation *conversation in self.deleteConversationArray) {
        [[RCIMClient sharedRCIMClient] clearMessages:conversation.conversationType targetId:conversation.targetId];
        [[RCIMClient sharedRCIMClient] removeConversation:conversation.conversationType targetId:conversation.targetId];
    }
    [hud hideAnimated:YES];
    [self.view showHUDMessage:RCDLocalizedString(@"DeleteSuccess")];
    [self setupData];

    if (self.conversationList.count > 0) {
        self.allSelectBtn.enabled = YES;
        [self.allSelectBtn setTitleColor:RCDDYCOLOR(0x000000, 0x999999) forState:UIControlStateNormal];
    } else {
        self.allSelectBtn.enabled = NO;
        [self.allSelectBtn setTitleColor:[[UIColor grayColor] colorWithAlphaComponent:0.6]
                                forState:UIControlStateNormal];
    }
    self.deleteBtn.enabled = self.deleteConversationArray.count > 0;
    [self.tableView reloadData];
}

#pragma mark - Target Action
- (void)clickBackBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)allSelectAction {
    self.allSelectBtn.selected = !self.allSelectBtn.selected;
    if (self.allSelectBtn.isSelected) {
        [self.deleteConversationArray removeAllObjects];
        for (RCConversation *conversation in self.conversationList) {
            [self.deleteConversationArray addObject:conversation];
            self.deleteBtn.enabled = YES;
        }
    } else {
        [self.deleteConversationArray removeAllObjects];
        self.deleteBtn.enabled = NO;
    }
    [self.tableView reloadData];
}

- (void)deleteAction {
    if (self.deleteConversationArray.count > 0) {
        [NormalAlertView showAlertWithMessage:RCDLocalizedString(@"clear_chat_history_alert")
            highlightText:nil
            leftTitle:RCDLocalizedString(@"cancel")
            rightTitle:RCDLocalizedString(@"Delete_Confirm")
            cancel:^{

            }
            confirm:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self deleteConversation];
                });
            }];
    }
}

#pragma mark - Setter && Getter
- (RCDTableView *)tableView {
    if (!_tableView) {
        _tableView = [[RCDTableView alloc] init];
        [_tableView setSectionIndexColor:[UIColor darkGrayColor]];
        _tableView.allowsMultipleSelection = YES;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = RCDDYCOLOR(0xffffff, 0x1a1a1a);
    }
    return _bottomView;
}

- (UIButton *)allSelectBtn {
    if (!_allSelectBtn) {
        _allSelectBtn = [[UIButton alloc] init];
        [_allSelectBtn setTitle:RCDLocalizedString(@"AllSelect") forState:UIControlStateNormal];
        [_allSelectBtn setImage:[UIImage imageNamed:@"forward_unselected"] forState:UIControlStateNormal];
        [_allSelectBtn setImage:[UIImage imageNamed:@"forward_selected"] forState:UIControlStateSelected];
        [_allSelectBtn setTitleColor:RCDDYCOLOR(0x000000, 0x999999) forState:UIControlStateNormal];
        [_allSelectBtn setTitleColor:[[UIColor grayColor] colorWithAlphaComponent:0.6] forState:UIControlStateDisabled];
        _allSelectBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [_allSelectBtn addTarget:self action:@selector(allSelectAction) forControlEvents:UIControlEventTouchUpInside];
        _allSelectBtn.enabled = NO;
    }
    return _allSelectBtn;
}

- (UIButton *)deleteBtn {
    if (!_deleteBtn) {
        _deleteBtn = [[UIButton alloc] init];
        [_deleteBtn setTitle:RCDLocalizedString(@"Delete") forState:UIControlStateNormal];
        [_deleteBtn setTitleColor:[UIColor colorWithHexString:@"FF0000" alpha:1] forState:UIControlStateNormal];
        [_deleteBtn setTitleColor:[[UIColor grayColor] colorWithAlphaComponent:0.6] forState:UIControlStateDisabled];
        _deleteBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [_deleteBtn addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
        _deleteBtn.enabled = NO;
    }
    return _deleteBtn;
}

@end
