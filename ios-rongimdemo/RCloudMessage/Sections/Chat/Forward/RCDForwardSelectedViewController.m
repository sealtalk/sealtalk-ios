//
//  RCDForwardSelectedViewController.m
//  SealTalk
//
//  Created by 孙浩 on 2019/6/17.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDForwardSelectedViewController.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDBottomResultView.h"
#import "UIColor+RCColor.h"
#import "RCDForwardSelectedCell.h"
#import "RCDRightArrowCell.h"
#import "RCDForwardManager.h"
#import "RCDContactSelectedTableViewController.h"
#import "RCDSelectContactViewController.h"
#import <Masonry/Masonry.h>
#import "RCDForwardSearchViewController.h"
#import "RCDSelectGroupViewController.h"
#import "RCDTableView.h"
#import "RCDSearchBar.h"
static NSString *rightArrowCellIdentifier = @"RCDRightArrowCellIdentifier";
static NSString *forwardSelectedCellIdentifier = @"RCDForwardSelectedCellIdentifier";

@interface RCDForwardSelectedViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate,
                                                RCDForwardSearchViewDelegate>

@property (nonatomic, strong) RCDSearchBar *searchBar;
@property (nonatomic, strong) RCDBottomResultView *bottomResultView;
@property (nonatomic, strong) UIBarButtonItem *rightBarItem;
@property (nonatomic, strong) RCDTableView *tableView;
@property (nonatomic, strong) NSArray *conversationList;
@property (nonatomic, assign) BOOL isMultiSelectModel;
@property (nonatomic, strong) UINavigationController *searchNavigationController;

@end

@implementation RCDForwardSelectedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupData];
    [self setupViews];
    [self setupNavi];
    [self addObserver];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.tableView reloadData];
    [self updateSelectedResult];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
    case 0:
        if (self.isMultiSelectModel) {
            return 1;
        }
        return 2;
        break;
    case 1:
        return self.conversationList.count;
        break;
    default:
        break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 30;
    } else if (section == 0) {
        return 0.01;
    }
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 200, 30)];
        label.text = RCDLocalizedString(@"RecentChat");
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = RCDDYCOLOR(0x939393, 0x666666);
        [view addSubview:label];
        return view;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isMultiSelectModel) {
        if (indexPath.section == 0) {
            RCDRightArrowCell *cell = [self.tableView dequeueReusableCellWithIdentifier:rightArrowCellIdentifier];
            if (cell == nil) {
                cell = [[RCDRightArrowCell alloc] init];
            }
            [cell setLeftText:RCDLocalizedString(@"ChooseAddressBook")];
            return cell;
        } else {
            RCDForwardSelectedCell *cell =
                [self.tableView dequeueReusableCellWithIdentifier:forwardSelectedCellIdentifier];
            if (cell == nil) {
                cell = [[RCDForwardSelectedCell alloc] init];
            }
            RCConversation *conversation = self.conversationList[indexPath.row];
            RCDForwardCellModel *model = [RCDForwardCellModel createModelWith:conversation];
            [cell setModel:model];
            cell.selectStatus = RCDForwardSelectedStatusMultiUnSelected;
            if ([[RCDForwardManager sharedInstance] modelIsContains:model.targetId]) {
                cell.selectStatus = RCDForwardSelectedStatusMultiSelected;
            }
            return cell;
        }
    } else {
        if (indexPath.section == 0) {
            RCDRightArrowCell *cell = [self.tableView dequeueReusableCellWithIdentifier:rightArrowCellIdentifier];
            if (cell == nil) {
                cell = [[RCDRightArrowCell alloc] init];
            }
            if (indexPath.row == 0) {
                [cell setLeftText:RCDLocalizedString(@"CreateNewChat")];
            } else {
                [cell setLeftText:RCDLocalizedString(@"ChooseAGroup")];
            }
            return cell;
        } else {
            RCDForwardSelectedCell *cell =
                [self.tableView dequeueReusableCellWithIdentifier:forwardSelectedCellIdentifier];
            if (cell == nil) {
                cell = [[RCDForwardSelectedCell alloc] init];
            }
            RCConversation *conversation = self.conversationList[indexPath.row];
            RCDForwardCellModel *cellModel = [RCDForwardCellModel createModelWith:conversation];
            [cell setModel:cellModel];
            cell.selectStatus = RCDForwardSelectedStatusSingleSelect;
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.isMultiSelectModel) {
        if (indexPath.section == 0) {
            RCDSelectContactViewController *contactVC = [[RCDSelectContactViewController alloc] init];
            [self.navigationController pushViewController:contactVC animated:YES];
        } else {
            RCDForwardSelectedCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            RCConversation *conversation = self.conversationList[indexPath.row];
            RCDForwardCellModel *model = [RCDForwardCellModel createModelWith:conversation];
            if (cell.selectStatus == RCDForwardSelectedStatusMultiUnSelected) {
                [[RCDForwardManager sharedInstance] addForwardModel:model];
                cell.selectStatus = RCDForwardSelectedStatusMultiSelected;
            } else {
                [[RCDForwardManager sharedInstance] removeForwardModel:model];
                cell.selectStatus = RCDForwardSelectedStatusMultiUnSelected;
            }
        }
        [self updateSelectedResult];
    } else {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                RCDContactSelectedTableViewController *contactSelectedVC =
                    [[RCDContactSelectedTableViewController alloc] initWithTitle:RCDLocalizedString(@"select_contact")
                                                       isAllowsMultipleSelection:YES];
                contactSelectedVC.groupOptionType = RCDContactSelectedGroupOptionTypeCreate;
                [self.navigationController pushViewController:contactSelectedVC animated:YES];
            } else if (indexPath.row == 1) {
                RCDSelectGroupViewController *selecteGroupVC = [[RCDSelectGroupViewController alloc] init];
                [self.navigationController pushViewController:selecteGroupVC animated:YES];
            }
        } else if (indexPath.section == 1) {
            RCConversation *conversation = self.conversationList[indexPath.row];
            [self showForwardAlertView:conversation];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isMultiSelectModel) {
        if (indexPath.section == 1) {
            RCDForwardSelectedCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            RCConversation *conversation = self.conversationList[indexPath.row];
            RCDForwardCellModel *model = [RCDForwardCellModel createModelWith:conversation];
            if (cell.selectStatus == RCDForwardSelectedStatusMultiSelected) {
                [[RCDForwardManager sharedInstance] removeForwardModel:model];
                cell.selectStatus = RCDForwardSelectedStatusMultiUnSelected;
            } else {
                [[RCDForwardManager sharedInstance] addForwardModel:model];
                cell.selectStatus = RCDForwardSelectedStatusMultiSelected;
            }
            [self updateSelectedResult];
        }
    }
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    RCDForwardSearchViewController *searchViewController = [[RCDForwardSearchViewController alloc] init];
    self.searchNavigationController = [[UINavigationController alloc] initWithRootViewController:searchViewController];
    searchViewController.delegate = self;
    [self.navigationController.view addSubview:self.searchNavigationController.view];
}

#pragma mark - RCDForwardSearchViewDelegate
- (void)forwardSearchViewControllerDidClickCancel {
    [self.searchNavigationController.view removeFromSuperview];
    [self.searchNavigationController removeFromParentViewController];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self refreshTableViewIfNeed];
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
}

- (void)setupViews {
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.tableView];

    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.offset(44);
    }];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-RCDExtraBottomHeight);
    }];
}

- (void)setupNavi {

    self.title = RCDLocalizedString(@"SelectAConversation");
    self.navigationItem.rightBarButtonItem = self.rightBarItem;

    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithTitle:RCDLocalizedString(@"cancel")
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(onLeftButtonClick:)];
    self.navigationItem.leftBarButtonItem = leftBarItem;
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onEndForwardMessage)
                                                 name:@"RCDForwardMessageEnd"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateSelectedResult)
                                                 name:@"ReloadBottomResultView"
                                               object:nil];
}

- (void)onEndForwardMessage {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateSelectedResult {
    [self.bottomResultView updateSelectResult];
}

- (void)showForwardAlertView:(RCConversation *)conversation {
    [RCDForwardManager sharedInstance].toConversation = conversation;
    [[RCDForwardManager sharedInstance] showForwardAlertViewInViewController:self];
}

#pragma mark - Target Action
- (void)onRightButtonClick:(id)sender {
    self.isMultiSelectModel = !self.isMultiSelectModel;
    [RCDForwardManager sharedInstance].isMultiSelect = self.isMultiSelectModel;
    if (self.isMultiSelectModel) {
        self.rightBarItem.title = RCDLocalizedString(@"SingleChoice");
    } else {
        self.rightBarItem.title = RCDLocalizedString(@"MultiChoice");
    }
    [[RCDForwardManager sharedInstance] clearForwardModelArray];
    [self updateSelectedResult];
    [self refreshTableViewIfNeed];
}

- (void)refreshTableViewIfNeed {
    if (!self.isMultiSelectModel) {
        [self.bottomResultView removeFromSuperview];

        [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.searchBar.mas_bottom);
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-RCDExtraBottomHeight);
        }];
    } else {
        [self.view addSubview:self.bottomResultView];
        [self.bottomResultView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
            make.height.offset(50 + RCDExtraBottomHeight);
        }];

        [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.searchBar.mas_bottom);
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.bottomResultView.mas_top);
        }];

        [self updateSelectedResult];
    }
    self.tableView.allowsMultipleSelection = self.isMultiSelectModel;
    [self.tableView reloadData];
}

- (void)onLeftButtonClick:(id)sender {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    [[RCDForwardManager sharedInstance] clear];
}

#pragma mark - Setter && Getter
- (RCDTableView *)tableView {
    if (!_tableView) {
        _tableView = [[RCDTableView alloc] init];
        [_tableView setSectionIndexColor:[UIColor darkGrayColor]];
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
        _tableView.allowsMultipleSelection = YES;
        _tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (RCDSearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[RCDSearchBar alloc] init];
        _searchBar.delegate = self;
        _searchBar.placeholder = RCDLocalizedString(@"search");
    }
    return _searchBar;
}

- (UIBarButtonItem *)rightBarItem {
    if (!_rightBarItem) {
        _rightBarItem = [[UIBarButtonItem alloc] initWithTitle:RCDLocalizedString(@"MultiChoice")
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(onRightButtonClick:)];
    }
    return _rightBarItem;
}

- (RCDBottomResultView *)bottomResultView {
    if (!_bottomResultView) {
        _bottomResultView = [[RCDBottomResultView alloc] init];
    }
    return _bottomResultView;
}

@end
