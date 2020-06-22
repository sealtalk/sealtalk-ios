//
//  RCDAddressBookFriendsViewController.m
//  SealTalk
//
//  Created by 孙浩 on 2019/7/15.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDAddressBookFriendsViewController.h"
#import "RCDSearchBar.h"
#import <RongIMKit/RongIMKit.h>
#import <Masonry/Masonry.h>
#import "RCDAddressBookManager.h"
#import "RCDUnableGetContactsView.h"
#import "RCDCommonString.h"
#import "UIView+MBProgressHUD.h"
#import "RCDUtilities.h"
#import "UIColor+RCColor.h"
#import "RCDAddressBookFriendCell.h"
#import "RCDUserInfoManager.h"
#import "RCDAddFriendViewController.h"
#import "RCDTableView.h"
@interface RCDAddressBookFriendsViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) RCDSearchBar *searchBar;
@property (nonatomic, strong) RCDTableView *tableView;
@property (nonatomic, strong) RCDUnableGetContactsView *withoutPermissionView;

@property (nonatomic, strong) NSArray *contactsArray;

@property (nonatomic, strong) NSArray *resultKeys;
@property (nonatomic, strong) NSDictionary *resultSectionDict;
@property (nonatomic, strong) NSMutableArray *matchFriendList;
@property (nonatomic, assign) BOOL isBeginSearch;

@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UILabel *friendCountLabel;

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation RCDAddressBookFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupNavi];
    [self setupUI];
    [self setupData];
    [self addObserver];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isBeginSearch == YES) {
        [self resetSearchBarAndMatchFriendList];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.resultKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    if ([RCDAddressBookManager sharedManager].state == RCDContactsAuthStateApprove) {
        NSString *letter = self.resultKeys[section];
        rows = [self.resultSectionDict[letter] count];
    }
    return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellReuseIdentifier = @"RCDAddressBookFriendCell";
    RCDAddressBookFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (!cell) {
        cell = [[RCDAddressBookFriendCell alloc] init];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *letter = self.resultKeys[indexPath.section];
    NSArray *sectionUserInfoList = self.resultSectionDict[letter];
    RCDContactsInfo *contacts = sectionUserInfoList[indexPath.row];
    [cell setModel:contacts];
    __weak typeof(self) weakSelf = self;
    cell.addBlock = ^(NSString *_Nonnull userId) {
        RCDAddFriendViewController *addViewController = [[RCDAddFriendViewController alloc] init];
        addViewController.targetUserId = userId;
        [weakSelf.navigationController pushViewController:addViewController animated:YES];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.frame = CGRectMake(0, 0, self.view.frame.size.width, 15);
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.frame = CGRectMake(13, 0, 15, 15);
    title.font = [UIFont systemFontOfSize:12.f];
    title.textColor = RCDDYCOLOR(0x262626, 0x9f9f9f);
    [view addSubview:title];

    title.text = self.resultKeys[section];
    return view;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.resultKeys;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.matchFriendList removeAllObjects];
    if (searchText.length <= 0) {
        [self sortAndRefreshWithList:self.contactsArray];
    } else {
        for (RCDContactsInfo *contacts in self.contactsArray) {
            NSString *name = contacts.name;
            NSString *displayName = contacts.nickname;
            if ([name rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound ||
                [[RCDUtilities hanZiToPinYinWithString:name] rangeOfString:searchText options:NSCaseInsensitiveSearch]
                        .location != NSNotFound ||
                [displayName rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound ||
                [[RCDUtilities hanZiToPinYinWithString:displayName] rangeOfString:searchText
                                                                          options:NSCaseInsensitiveSearch]
                        .location != NSNotFound) {
                [self.matchFriendList addObject:contacts];
            }
        }
        [self sortAndRefreshWithList:self.matchFriendList];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self resetSearchBarAndMatchFriendList];
    [self sortAndRefreshWithList:self.contactsArray];
    [self.tableView reloadData];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if (_isBeginSearch == NO) {
        _isBeginSearch = YES;
        self.friendCountLabel.hidden = YES;
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

#pragma mark - Target Action
- (void)contactsAuthStateChange {
    [self setupNavi];
    [self setupData];
}

- (void)pushToSetting {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - Private Method
- (void)setupNavi {
    RCDAddressBookManager *manager = [RCDAddressBookManager sharedManager];
    [manager getContactsAuthState];
}

- (void)setupUI {
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.withoutPermissionView];

    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.offset(44);
    }];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.searchBar.mas_bottom);
        make.bottom.equalTo(self.view).offset(-RCDExtraBottomHeight);
    }];

    [self.withoutPermissionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(self.view);
    }];

    [self setupFooterView];
}

- (void)setupFooterView {
    self.tableView.tableFooterView = self.footerView;
}

- (void)setupData {
    self.resultKeys = [[NSArray alloc] init];
    self.resultSectionDict = [[NSDictionary alloc] init];
    self.matchFriendList = [[NSMutableArray alloc] init];

    self.contactsArray = [[NSArray alloc] init];

    self.title = RCDLocalizedString(@"AddressBookFriends");
    RCDAddressBookManager *manager = [RCDAddressBookManager sharedManager];
    [manager getContactsAuthState];
    if (manager.state == RCDContactsAuthStateNotDetermine) {
        [manager requestAuth];
    } else if (manager.state == RCDContactsAuthStateApprove) {
        [self.hud showAnimated:YES];
        NSArray *phoneNumbers = [manager getAllContactPhoneNumber];
        [RCDAddressBookManager getContactsInfo:phoneNumbers
                                      complete:^(NSArray *_Nonnull contactsList) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [self.hud hideAnimated:YES];
                                              self.contactsArray = contactsList;
                                              self.friendCountLabel.text = [NSString
                                                  stringWithFormat:RCDLocalizedString(@"AddressBookFriendCount"),
                                                                   self.contactsArray.count];
                                              [self sortAndRefreshWithList:self.contactsArray];
                                              [self.tableView reloadData];
                                          });
                                      }];

    } else {
        self.withoutPermissionView.hidden = NO;
        self.title = RCDLocalizedString(@"AddressBookMatching");
    }
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contactsAuthStateChange)
                                                 name:RCDContactsAuthStateChangeKey
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setupData)
                                                 name:RCDContactsUpdateUIKey
                                               object:nil];
}

- (void)sortAndRefreshWithList:(NSArray *)friendList {
    dispatch_async(dispatch_queue_create("sealtalksort", DISPATCH_QUEUE_SERIAL), ^{
        NSDictionary *resultDic = [[RCDUtilities sortedArrayWithPinYinDic:friendList] copy];
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.resultKeys = resultDic[@"allKeys"];
            self.resultSectionDict = resultDic[@"infoDic"];
            [self.tableView reloadData];
        });
    });
}

- (void)resetSearchBarAndMatchFriendList {
    self.friendCountLabel.hidden = NO;
    self.isBeginSearch = NO;
    self.searchBar.showsCancelButton = NO;
    [self.searchBar resignFirstResponder];
    self.searchBar.text = @"";
    [self.matchFriendList removeAllObjects];
}

#pragma mark - Getter && Setter
- (RCDSearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[RCDSearchBar alloc] init];
        _searchBar.delegate = self;
    }
    return _searchBar;
}

- (RCDTableView *)tableView {
    if (!_tableView) {
        _tableView = [[RCDTableView alloc] init];
        [_tableView setSectionIndexColor:[UIColor darkGrayColor]];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        //设置右侧索引
        _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        _tableView.sectionIndexColor = HEXCOLOR(0x555555);
    }
    return _tableView;
}

- (RCDUnableGetContactsView *)withoutPermissionView {
    if (!_withoutPermissionView) {
        _withoutPermissionView = [[RCDUnableGetContactsView alloc] init];
        _withoutPermissionView.hidden = YES;
        [_withoutPermissionView.settingButton addTarget:self
                                                 action:@selector(pushToSetting)
                                       forControlEvents:UIControlEventTouchUpInside];
    }
    return _withoutPermissionView;
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 46)];
        [_footerView addSubview:self.friendCountLabel];
        self.friendCountLabel.center = _footerView.center;
    }
    return _footerView;
}

- (UILabel *)friendCountLabel {
    if (!_friendCountLabel) {
        _friendCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - 20, 17)];
        _friendCountLabel.textColor = [UIColor colorWithHexString:@"999999" alpha:1];
        _friendCountLabel.font = [UIFont systemFontOfSize:12];
        _friendCountLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _friendCountLabel;
}

- (MBProgressHUD *)hud {
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.color = [UIColor colorWithHexString:@"343637" alpha:0.8];
    }
    return _hud;
}

@end
