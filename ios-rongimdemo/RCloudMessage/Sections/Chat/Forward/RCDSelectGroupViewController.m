//
//  RCDSelectGroupViewController.m
//  SealTalk
//
//  Created by 孙浩 on 2019/6/20.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDSelectGroupViewController.h"
#import "RCDGroupManager.h"
#import "RCDForwardManager.h"
#import "UIColor+RCColor.h"
#import "RCDForwardSelectedCell.h"
#import <Masonry/Masonry.h>
#import "RCDBottomResultView.h"
#import "RCDUtilities.h"
#import "RCDUIBarButtonItem.h"
#import "RCDTableView.h"
#import "RCDSearchBar.h"
static NSString *selectGroupCellIdentifier = @"RCDSelectGroupCellIdentifier";

@interface RCDSelectGroupViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,
                                            UISearchControllerDelegate>

@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic, strong) NSArray *displayGroups;
@property (nonatomic, assign) BOOL isBeginSearch;
@property (nonatomic, assign) BOOL isMultiSelectModel;

@property (nonatomic, strong) RCDTableView *tableView;
@property (nonatomic, strong) RCDSearchBar *searchBar;
@property (nonatomic, strong) RCDBottomResultView *bottomResultView;

@end

@implementation RCDSelectGroupViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadData];
    [self setupView];
    [self setupNavi];
    [self addObserver];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private Method
- (void)loadData {
    self.isMultiSelectModel = [RCDForwardManager sharedInstance].isMultiSelect;
    self.groups = [NSMutableArray arrayWithArray:[RCDGroupManager getMyGroupList]];
    self.displayGroups = [self.groups copy];
    __weak typeof(self) weakSelf = self;
    [RCDGroupManager getMyGroupListFromServer:^(NSArray<RCDGroupInfo *> *_Nonnull groupList) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.groups = groupList.mutableCopy;
            [weakSelf.tableView reloadData];
        });
    }];
}

- (void)setupView {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.searchBar];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];

    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
    }];

    if (!self.isMultiSelectModel) {
        [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.searchBar.mas_bottom);
            make.bottom.equalTo(self.view).offset(-RCDExtraBottomHeight);
        }];
    } else {
        [self.view addSubview:self.bottomResultView];
        [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.searchBar.mas_bottom);
            make.bottom.equalTo(self.bottomResultView.mas_top);
        }];
        [self.bottomResultView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
            make.height.offset(50 + RCDExtraBottomHeight);
        }];

        [self updateSelectedResult];
    }
}

- (void)setupNavi {
    self.navigationItem.title = RCDLocalizedString(@"group");
    self.navigationItem.leftBarButtonItem =
        [[RCDUIBarButtonItem alloc] initWithLeftBarButton:RCDLocalizedString(@"back")
                                                   target:self
                                                   action:@selector(clickBackBtn)];
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateSelectedResult)
                                                 name:@"ReloadBottomResultView"
                                               object:nil];
}

- (void)resetSearchBarAndMatchFriendList {
    self.isBeginSearch = NO;
    self.searchBar.showsCancelButton = NO;
    [self.searchBar resignFirstResponder];
    self.searchBar.text = @"";
    self.displayGroups = [self.groups copy];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.displayGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDForwardSelectedCell *cell = [tableView dequeueReusableCellWithIdentifier:selectGroupCellIdentifier];
    if (!cell) {
        cell = [[RCDForwardSelectedCell alloc] init];
    }
    RCDGroupInfo *group = self.displayGroups[indexPath.row];
    [cell setGroupInfo:group];

    if (self.isMultiSelectModel) {
        cell.selectStatus = RCDForwardSelectedStatusMultiUnSelected;
        if ([[RCDForwardManager sharedInstance] modelIsContains:group.groupId]) {
            cell.selectStatus = RCDForwardSelectedStatusMultiSelected;
        }
    } else {
        cell.selectStatus = RCDForwardSelectedStatusSingleSelect;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDGroupInfo *groupInfo = self.displayGroups[indexPath.row];
    if (self.isMultiSelectModel) {
        RCDForwardSelectedCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        RCDForwardCellModel *forwardCellmodel = [[RCDForwardCellModel alloc] init];
        forwardCellmodel.targetId = groupInfo.groupId;
        forwardCellmodel.conversationType = ConversationType_GROUP;

        if (cell.selectStatus == RCDForwardSelectedStatusMultiUnSelected) {
            [[RCDForwardManager sharedInstance] addForwardModel:forwardCellmodel];
            cell.selectStatus = RCDForwardSelectedStatusMultiSelected;
        } else {
            [[RCDForwardManager sharedInstance] removeForwardModel:forwardCellmodel];
            cell.selectStatus = RCDForwardSelectedStatusMultiUnSelected;
        }
        [self updateSelectedResult];
    } else {
        RCConversation *conver = [[RCConversation alloc] init];
        conver.targetId = groupInfo.groupId;
        conver.conversationType = ConversationType_GROUP;
        [RCDForwardManager sharedInstance].toConversation = conver;
        [[RCDForwardManager sharedInstance] showForwardAlertViewInViewController:self];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

#pragma mark - UISearchBarDelegate
//  执行 delegate 搜索好友
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length <= 0) {
        self.displayGroups = self.groups;
    } else {
        NSMutableArray *matchArray = [NSMutableArray array];
        for (RCDGroupInfo *group in self.displayGroups) {
            if ([group.groupName rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound ||
                [[RCDUtilities hanZiToPinYinWithString:group.groupName] rangeOfString:searchText
                                                                              options:NSCaseInsensitiveSearch]
                        .location != NSNotFound) {
                [matchArray addObject:group];
            }
        }
        self.displayGroups = [matchArray copy];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self resetSearchBarAndMatchFriendList];
    [self.tableView reloadData];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if (self.isBeginSearch == NO) {
        self.isBeginSearch = YES;
        [self.tableView reloadData];
    }
    self.searchBar.showsCancelButton = YES;
    for (UIView *view in [[[self.searchBar subviews] objectAtIndex:0] subviews]) {
        if ([view isKindOfClass:[NSClassFromString(@"UINavigationButton") class]]) {
            UIButton *cancel = (UIButton *)view;
            [cancel setTitle:RCDLocalizedString(@"cancel") forState:UIControlStateNormal];
            break;
        }
    }
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)updateSelectedResult {
    [self.bottomResultView updateSelectResult];
}

#pragma mark - Target Action
- (void)clickBackBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Getter & Setter
- (RCDSearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[RCDSearchBar alloc] init];
        _searchBar.delegate = self;
        _searchBar.keyboardType = UIKeyboardTypeDefault;
    }
    return _searchBar;
}

- (RCDTableView *)tableView {
    if (!_tableView) {
        _tableView = [[RCDTableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView =
            [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _tableView.bounds.size.width, 0.01f)];
        //设置右侧索引
        _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        _tableView.sectionIndexColor = HEXCOLOR(0x555555);
    }
    return _tableView;
}

- (RCDBottomResultView *)bottomResultView {
    if (!_bottomResultView) {
        _bottomResultView = [[RCDBottomResultView alloc] init];
    }
    return _bottomResultView;
}

@end
