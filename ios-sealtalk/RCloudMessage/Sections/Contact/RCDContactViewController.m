//
//  RCDContactViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/3/16.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDContactViewController.h"
#import "RCDAddressBookViewController.h"
#import "RCDCommonDefine.h"
#import "RCDContactTableViewCell.h"
#import "RCDGroupViewController.h"
#import "RCDPersonDetailViewController.h"
#import "RCDPublicServiceListViewController.h"
#import "RCDRCIMDataSource.h"
#import "RCDAddFriendListViewController.h"
#import "RCDUIBarButtonItem.h"
#import "RCDUserInfoManager.h"
#import "RCDUtilities.h"
#import <Masonry/Masonry.h>
#import "UITabBar+badge.h"
#import "RCDCommonString.h"
#import "RCDSelectContactViewController.h"
#import "RCDSearchBar.h"
@interface RCDContactViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,
                                        UISearchControllerDelegate>
@property (nonatomic, strong) RCDTableView *friendsTabelView;
@property (nonatomic, strong) RCDSearchBar *searchFriendsBar;
@property (nonatomic, strong) UILabel *emptyLabel;

@property (nonatomic, strong) NSArray *allFriendArray;
@property (nonatomic, strong) NSArray *resultKeys;
@property (nonatomic, strong) NSDictionary *resultSectionDict;
@property (nonatomic, strong) NSMutableArray *matchFriendList;

@property (nonatomic, strong) NSArray *defaultCellsTitle;
@property (nonatomic, strong) NSArray *defaultCellsPortrait;
@property (nonatomic, assign) BOOL hasSyncFriendList;
@property (nonatomic, assign) BOOL isBeginSearch;
@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation RCDContactViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupView];
    [self initData];
    [self addObserver];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupNavi];
    [self.searchFriendsBar resignFirstResponder];
    [self sortAndRefreshWithList:[self getAllFriendList]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_isBeginSearch == YES) {
        [self sortAndRefreshWithList:self.allFriendArray];
        [self resetSearchBarAndMatchFriendList];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {

    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self layoutSubview:size];
    }
        completion:^(id<UIViewControllerTransitionCoordinatorContext> context){

        }];
}

- (void)layoutSubview:(CGSize)size {
    self.searchFriendsBar.frame = CGRectMake(0, 0, size.width, 44);
    self.friendsTabelView.frame = CGRectMake(0, CGRectGetMaxY(self.searchFriendsBar.frame), size.width,
                                             size.height - CGRectGetMaxY(self.searchFriendsBar.frame));
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    if (section == 0) {
        if (_isBeginSearch == YES) {
            rows = 0;
        } else {
            rows = 4;
        }
    } else {
        NSString *letter = self.resultKeys[section - 1];
        rows = [self.resultSectionDict[letter] count];
    }
    return rows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.resultKeys.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGFLOAT_MIN;
    }
    return 32.f;
}

//如果没有该方法，tableView会默认显示footerView，其高度与headerView等高
//另外如果return 0或者0.0f是没有效果的
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.frame = CGRectMake(0, 0, self.view.frame.size.width, 32);
    view.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x111111);
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.frame = CGRectMake(13, 8, 15, 16);
    title.font = [UIFont systemFontOfSize:14.f];
    title.textColor = RCDDYCOLOR(0x3b3b3b, 0x878787);
    [view addSubview:title];

    if (section == 0) {
        title.text = nil;
    } else {
        title.text = self.resultKeys[section - 1];
    }
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reusableCellWithIdentifier = @"RCDContactTableViewCell";
    RCDContactTableViewCell *cell =
        [self.friendsTabelView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    if (cell == nil) {
        cell = [[RCDContactTableViewCell alloc] init];
    }
    if (indexPath.section == 0) {
        if (indexPath.row == 3) {
            [cell setModel:[RCIM sharedRCIM].currentUserInfo];
        } else {
            cell.nicknameLabel.text = [_defaultCellsTitle objectAtIndex:indexPath.row];
            [cell.portraitView
                setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", [_defaultCellsPortrait
                                                                                   objectAtIndex:indexPath.row]]]];
            if (indexPath.row == 0) {
                int allRequesteds = [RCDUserInfoManager getFriendRequesteds];
                if (allRequesteds > 0) {
                    [cell showNoticeLabel:allRequesteds];
                }
            }
        }
    } else {
        NSString *letter = self.resultKeys[indexPath.section - 1];
        NSArray *sectionUserInfoList = self.resultSectionDict[letter];
        RCDFriendInfo *userInfo = sectionUserInfoList[indexPath.row];
        if (userInfo) {
            [cell setModel:userInfo];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    __weak typeof(self) weakSelf = self;
    cell.longPressBlock = ^(NSString *userId) {
        RCDSelectContactViewController *selectContactVC =
            [[RCDSelectContactViewController alloc] initWithContactSelectType:RCDContactSelectTypeDelete];
        [weakSelf.navigationController pushViewController:selectContactVC animated:YES];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.resultKeys;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.friendsTabelView deselectRowAtIndexPath:indexPath animated:YES];
    RCDFriendInfo *user = nil;
    if (indexPath.section == 0) {
        switch (indexPath.row) {
        case 0: {
            RCDAddressBookViewController *addressBookVC = [[RCDAddressBookViewController alloc] init];
            [self.navigationController pushViewController:addressBookVC animated:YES];
        } break;
        case 1: {
            RCDGroupViewController *groupVC = [[RCDGroupViewController alloc] init];
            [self.navigationController pushViewController:groupVC animated:YES];
        } break;
        case 2: {
            RCDPublicServiceListViewController *publicServiceVC = [[RCDPublicServiceListViewController alloc] init];
            [self.navigationController pushViewController:publicServiceVC animated:YES];
        } break;
        case 3: {
            [self pushUserDetailVC:[RCIM sharedRCIM].currentUserInfo.userId];
        } break;
        default:
            break;
        }
    } else {
        NSString *letter = self.resultKeys[indexPath.section - 1];
        NSArray *sectionUserInfoList = self.resultSectionDict[letter];
        user = sectionUserInfoList[indexPath.row];
        if (user == nil) {
            return;
        }
        [self pushUserDetailVC:user.userId];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchFriendsBar resignFirstResponder];
}

#pragma mark - UISearchBarDelegate
//  执行 delegate 搜索好友
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.matchFriendList removeAllObjects];
    if (searchText.length <= 0) {
        [self sortAndRefreshWithList:self.allFriendArray];
    } else {
        for (RCDFriendInfo *userInfo in self.allFriendArray) {
            NSString *name = [RCKitUtility getDisplayName:userInfo];
            // //忽略大小写去判断是否包含
            if ([name rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound ||
                [[RCDUtilities hanZiToPinYinWithString:name] rangeOfString:searchText options:NSCaseInsensitiveSearch]
                        .location != NSNotFound) {
                [self.matchFriendList addObject:userInfo];
            }
        }
        [self sortAndRefreshWithList:self.matchFriendList];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self resetSearchBarAndMatchFriendList];
    [self sortAndRefreshWithList:self.allFriendArray];
    [self reloadView];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if (_isBeginSearch == NO) {
        _isBeginSearch = YES;
        [self reloadView];
    }
    self.searchFriendsBar.showsCancelButton = YES;
    for (UIView *view in [[[self.searchFriendsBar subviews] objectAtIndex:0] subviews]) {
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

#pragma mark - Private Method
- (void)setupView {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
    [self.view addSubview:self.friendsTabelView];
    [self.view addSubview:self.searchFriendsBar];
    [self.friendsTabelView addSubview:self.emptyLabel];
    [self.friendsTabelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchFriendsBar.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];

    [self.emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.width.height.equalTo(self.friendsTabelView);
        make.centerY.equalTo(self.friendsTabelView).offset(-30);
    }];

    [self.searchFriendsBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
    }];
    [self updateBadgeForTabBarItem];
}

- (void)setupNavi {
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.navigationItem.title = RCDLocalizedString(@"contacts");
    RCDUIBarButtonItem *rightBtn = [[RCDUIBarButtonItem alloc] initContainImage:[UIImage imageNamed:@"add_friend"] target:self action:@selector(pushAddFriendVC:)];
    self.tabBarController.navigationItem.rightBarButtonItems = [rightBtn setTranslation:rightBtn translation:-6];
}

- (void)initData {
    self.matchFriendList = [[NSMutableArray alloc] init];
    self.resultSectionDict = [[NSDictionary alloc] init];
    self.defaultCellsTitle = [NSArray arrayWithObjects:RCDLocalizedString(@"new_friend"), RCDLocalizedString(@"group"),
                                                       RCDLocalizedString(@"public_account"), nil];
    self.defaultCellsPortrait = [NSArray arrayWithObjects:@"newFriend", @"defaultGroup", @"publicNumber", nil];
    self.isBeginSearch = NO;
    self.queue = dispatch_queue_create("sealtalksearch", DISPATCH_QUEUE_SERIAL);
    self.allFriendArray = [self getAllFriendList];
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBadgeForTabBarItem)
                                                 name:RCDContactsRequestKey
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadContents)
                                                 name:RCDContactsUpdateUIKey
                                               object:nil];
}

- (void)extracted {
    [RCDUserInfoManager getFriendListFromServer:^(NSArray<RCDFriendInfo *> *friendList) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.hasSyncFriendList = YES;
            if (friendList) {
                self.allFriendArray = [self getAllFriendList];
                [self sortAndRefreshWithList:self.allFriendArray];
            }
        });
    }];
}

- (void)reloadContents {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.allFriendArray = [self getAllFriendList];
        [self sortAndRefreshWithList:self.allFriendArray];
    });
}

// 获取好友并且排序
- (NSArray *)getAllFriendList {
    NSMutableArray *userInfoList = [NSMutableArray arrayWithArray:[RCDUserInfoManager getAllFriends]];
    if (userInfoList.count <= 0 && !self.hasSyncFriendList) {
        [self extracted];
    }
    return userInfoList;
}

- (void)sortAndRefreshWithList:(NSArray *)friendList {
    dispatch_async(self.queue, ^{
        NSDictionary *resultDic = [[RCDUtilities sortedArrayWithPinYinDic:friendList] copy];
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.resultKeys = resultDic[@"allKeys"];
            self.resultSectionDict = resultDic[@"infoDic"];
            [self reloadView];
        });
    });
}

- (void)resetSearchBarAndMatchFriendList {
    _isBeginSearch = NO;
    self.searchFriendsBar.showsCancelButton = NO;
    [self.searchFriendsBar resignFirstResponder];
    self.searchFriendsBar.text = @"";
    [self.matchFriendList removeAllObjects];
}

- (void)pushUserDetailVC:(NSString *)userId {
    RCDPersonDetailViewController *personDetailVC = [[RCDPersonDetailViewController alloc] init];
    personDetailVC.userId = userId;
    [self.navigationController pushViewController:personDetailVC animated:YES];
}

- (void)updateBadgeForTabBarItem {
    __weak typeof(self) __weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [__weakSelf reloadView];
    });
}

- (void)reloadView {
    if (self.isBeginSearch) {
        self.emptyLabel.hidden = self.resultKeys.count != 0;
    } else {
        self.emptyLabel.hidden = YES;
    }
    [self.friendsTabelView reloadData];
}

#pragma mark - Target Action
- (void)pushAddFriendVC:(id)sender {
    RCDAddFriendListViewController *addFriendListVC = [[RCDAddFriendListViewController alloc] init];
    [self.navigationController pushViewController:addFriendListVC animated:YES];
}

- (void)forwardCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Getter & Setter
- (RCDSearchBar *)searchFriendsBar {
    if (!_searchFriendsBar) {
        _searchFriendsBar = [[RCDSearchBar alloc] init];
        _searchFriendsBar.delegate = self;
        _searchFriendsBar.keyboardType = UIKeyboardTypeDefault;
        _searchFriendsBar.placeholder = RCDLocalizedString(@"search");
    }
    return _searchFriendsBar;
}

- (RCDTableView *)friendsTabelView {
    if (!_friendsTabelView) {
        _friendsTabelView = [[RCDTableView alloc] initWithFrame:CGRectZero style:(UITableViewStyleGrouped)];
        _friendsTabelView.delegate = self;
        _friendsTabelView.dataSource = self;
        _friendsTabelView.tableFooterView = [UIView new];
        //设置右侧索引
        _friendsTabelView.sectionIndexBackgroundColor = [UIColor clearColor];
        _friendsTabelView.sectionIndexColor = HEXCOLOR(0x6f6f6f);
        if ([_friendsTabelView respondsToSelector:@selector(setSeparatorInset:)]) {
            _friendsTabelView.separatorInset = UIEdgeInsetsMake(0, 64, 0, 0);
        }
        if ([_friendsTabelView respondsToSelector:@selector(setLayoutMargins:)]) {
            _friendsTabelView.layoutMargins = UIEdgeInsetsMake(0, 64, 0, 0);
        }
    }
    return _friendsTabelView;
}

- (UILabel *)emptyLabel {
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc] init];
        _emptyLabel.text = RCDLocalizedString(@"NoFriendsWereFound");
        _emptyLabel.textColor = HEXCOLOR(0x939393);
        _emptyLabel.font = [UIFont systemFontOfSize:17];
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.hidden = YES;
    }
    return _emptyLabel;
}

@end
