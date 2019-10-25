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

@interface RCDForwardSelectedViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) RCDBottomResultView *bottomResultView;
@property (nonatomic, strong) UIBarButtonItem *rightBarItem;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *conversationList;
@property (nonatomic, strong) NSDictionary *resultDict;
@property (nonatomic, assign) BOOL isMultiSelectModel;

@end

@implementation RCDForwardSelectedViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupData];
    [self setupViews];
    [self setupNavi];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.tableView reloadData];
    [self updateSelectedResult];
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
        view.backgroundColor = [UIColor colorWithHexString:@"" alpha:1];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 200, 30)];
        label.text = RCDLocalizedString(@"recent_chat");
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithHexString:@"" alpha:1];
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
            //            RCERightArrowCell *cell = [RCERightArrowCell cellWithTableView:tableView indexPath:indexPath];
            //            cell.leftLabel.text = RCEStringFor(@"choose_address_book");
            //            [cell setDataModel:nil];
            //            [self changeCellBackColor:cell];
            //            return cell;
        } else {
            //            RCEBaseSelectCell *cell = nil;
            //            RCConversation *con = self.conversationList[indexPath.row];
            //            if (con.conversationType == ConversationType_GROUP) {
            //                cell = [RCEGroupSelectCell cellWithTableView:tableView];
            //                [cell setDataModel:con.targetId];
            //            } else {
            //                cell = [RCEContactSelectCell cellWithTableView:tableView];
            //                [cell setDataModel:con.targetId];
            //            }
            //            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //            [self changeCellBackColor:cell];
            //            return cell;
        }

    } else {
        //        RCEBaseTableViewCell *cell;
        //        switch (indexPath.section) {
        //            case 0:
        //                cell = [RCERightArrowCell cellWithTableView:tableView indexPath:indexPath];
        //                if (indexPath.row == 0) {
        //                    ((RCERightArrowCell *)cell).leftLabel.text = RCEStringFor(@"create_new_chat");
        //                } else {
        //                    ((RCERightArrowCell *)cell).leftLabel.text = RCEStringFor(@"choose_a_group");
        //                    cell.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
        //                }
        //                [cell setDataModel:nil];
        //                break;
        //            case 1: {
        //                cell = [RCERecentContactsCell cellWithTableView:tableView indexPath:indexPath];
        //                RCConversation *model = self.conversationList[indexPath.row];
        //
        //                [cell setDataModel:model];
        //            } break;
        //            default:
        //                cell = [RCEBaseTableViewCell new];
        //                break;
        //        }
        //        [self changeCellBackColor:cell];
        //        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.isMultiSelectModel) {
        if (indexPath.section == 0) {
            //            [self pushToGroupMemberSelectViewControllerWithMyGroup:YES];
        } else {
            //            RCEBaseSelectCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            //            if (cell.selectStatus != RCEBaseSelectCellStatusAll) {
            //                [[RCEDepartmentDataManager sharedManager] addModel:cell.departModel];
            //            } else {
            //                [[RCEDepartmentDataManager sharedManager] removeModel:cell.departModel];
            //            }
            //            [cell updateSelectStatus];
        }
        [self updateSelectedResult];
    } else {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                //                [[RCEMultiFunctionManager sharedManager] createAConversation:YES];
                //                [[RCEDepartmentDataManager sharedManager] removeAllSelectedModel];
                //                [self pushToGroupMemberSelectViewControllerWithMyGroup:NO];
            } else if (indexPath.row == 1) {
                //                [[RCEMultiFunctionManager sharedManager] createAConversation:NO];
                //                RCEMyGroupViewController *myGroupVC = [[RCEMyGroupViewController alloc] init];
                //                myGroupVC.isForwardMessage = YES;
                //                [self.navigationController pushViewController:myGroupVC animated:YES];
            }
        } else if (indexPath.section == 1) {
            if (!self.isMultiSelectModel) {
                //                [[RCEDepartmentDataManager sharedManager] removeAllSelectedModel];
                //                RCConversation *con = self.conversationList[indexPath.row];
                //                RCEDepartmentDataModel *model = [RCEDepartmentDataAdapter
                //                getModelWithConversation:con];
                //                [[RCEDepartmentDataManager sharedManager] addModel:model];
                //                [self doForwardMessage];
            } else {
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isMultiSelectModel) {
        if (indexPath.section == 1) {
            //            RCEBaseSelectCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            //            if (cell.selectStatus == RCEBaseSelectCellStatusAll) {
            //                [[RCEDepartmentDataManager sharedManager] removeModel:cell.departModel];
            //            } else {
            //                [[RCEDepartmentDataManager sharedManager] addModel:cell.departModel];
            //            }
            //            [cell updateSelectStatus];
            [self updateSelectedResult];
        }
    }
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if (self.isMultiSelectModel) {
        //        [[RCESearchCoverProxy sharedProxy] searchDetailFrom:RCESearchCoverFromForwardMutli fromController:self
        //        searchResultBlock:nil];
    } else {
        //        __weak typeof(self) weakSelf = self;
        //        [[RCESearchCoverProxy sharedProxy] searchDetailFrom:(RCESearchCoverFromForwardSingle)
        //        fromController:self searchResultBlock:^(id result) {
        //            if ([result isKindOfClass:[RCConversation class]]) {
        //                [[RCEDepartmentDataManager sharedManager] removeAllSelectedModel];
        //                RCConversation *con = result;
        //                RCEDepartmentDataModel *model = [RCEDepartmentDataAdapter getModelWithConversation:con];
        //                [[RCEDepartmentDataManager sharedManager] addModel:model];
        //                [weakSelf doForwardMessage];
        //            }
        //        }];
    }
    return NO;
}

#pragma mark - Private Method
- (void)setupData {
    self.conversationList =
        [[RCIMClient sharedRCIMClient] getConversationList:@[ @(ConversationType_PRIVATE), @(ConversationType_GROUP) ]];
}

- (void)setupViews {

    [self.bottomResultView setConfirmButtonBlock:^(RCDBottomResultView *resultView){
        //        [ws doForwardMessage];
    }];
}

- (void)setupNavi {
    self.navigationItem.rightBarButtonItem = self.rightBarItem;

    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithTitle:RCDLocalizedString(@"cancel")
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(onLeftButtonClick:)];
    leftBarItem.tintColor = [RCIM sharedRCIM].globalNavigationBarTintColor;
    self.navigationItem.leftBarButtonItem = leftBarItem;
}

- (void)updateSelectedResult {
    [self.bottomResultView updateSelectResult];
}

- (void)pushToGroupMemberSelectViewControllerWithMyGroup {
}

- (void)doForwardMessage {
}

#pragma mark - Target Action
- (void)onRightButtonClick:(id)sender {
    self.isMultiSelectModel = !self.isMultiSelectModel;
    if (self.isMultiSelectModel) {
        //        self.itemInfo.maxCount = RCEForwardMessageMaxCount;
        //        self.itemInfo.canSelectCurrentUser = YES;
        //        [[RCEMultiFunctionManager sharedManager] createAConversation:NO];
        self.rightBarItem.title = RCDLocalizedString(@"single_choice");
    } else {
        //        self.itemInfo.maxCount = RCEGroupMemberMaxCount;
        //        self.itemInfo.canSelectCurrentUser = YES;
        //        [[RCEDepartmentDataService sharedDataService] config:self.itemInfo];
        self.rightBarItem.title = RCDLocalizedString(@"multi_choice");
    }
}

- (void)onLeftButtonClick:(id)sender {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Setter && Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_tableView setSectionIndexColor:[UIColor darkGrayColor]];
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
        _tableView.allowsMultipleSelection = YES;
        _tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.tableHeaderView = self.searchBar;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
        _searchBar.delegate = self;
    }
    return _searchBar;
}

- (UIBarButtonItem *)rightBarItem {
    if (!_rightBarItem) {
        _rightBarItem = [[UIBarButtonItem alloc] initWithTitle:RCDLocalizedString(@"multi_choice")
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(onRightButtonClick:)];
        _rightBarItem.tintColor = [RCIM sharedRCIM].globalNavigationBarTintColor;
    }
    return _rightBarItem;
}

@end
