//
//  RCDSelectAddressBookViewController.m
//  SealTalk
//
//  Created by 孙浩 on 2019/7/12.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDSelectAddressBookViewController.h"
#import "RCDSearchBar.h"
#import <RongIMKit/RongIMKit.h>
#import <Masonry/Masonry.h>
#import "RCDSelectAddressBookCell.h"
#import "RCDAddressBookManager.h"
#import "RCDUnableGetContactsView.h"
#import "RCDCommonString.h"
#import <MessageUI/MessageUI.h>
#import "UIView+MBProgressHUD.h"
#import "RCDUtilities.h"
#import "UIColor+RCColor.h"

@interface RCDSelectAddressBookViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource,
                                                  MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) RCDSearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) RCDUnableGetContactsView *withoutPermissionView;

@property (nonatomic, strong) NSArray *contactsArray;
@property (nonatomic, strong) NSMutableArray *selectContacts;

@property (nonatomic, strong) NSArray *resultKeys;
@property (nonatomic, strong) NSDictionary *resultSectionDict;
@property (nonatomic, strong) NSMutableArray *matchFriendList;
@property (nonatomic, assign) BOOL isBeginSearch;

@end

@implementation RCDSelectAddressBookViewController

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
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellReuseIdentifier = @"RCDSelectAddressBookCell";
    RCDSelectAddressBookCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (!cell) {
        cell = [[RCDSelectAddressBookCell alloc] init];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    NSString *letter = self.resultKeys[indexPath.section];
    NSArray *sectionUserInfoList = self.resultSectionDict[letter];
    RCDContactsInfo *contacts = sectionUserInfoList[indexPath.row];
    [cell setModel:contacts];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RCDSelectAddressBookCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectStatus == RCDSelectedStatusUnSelected) {
        cell.selectStatus = RCDSelectedStatusSelected;
    } else {
        cell.selectStatus = RCDSelectedStatusUnSelected;
    }

    NSString *letter = self.resultKeys[indexPath.section];
    NSArray *sectionUserInfoList = self.resultSectionDict[letter];
    RCDContactsInfo *contacts = sectionUserInfoList[indexPath.row];
    if (contacts.isSelected) {
        [self.selectContacts removeObject:contacts];
        contacts.isSelected = NO;
    } else {
        [self.selectContacts addObject:contacts];
        contacts.isSelected = YES;
    }
    if (self.selectContacts.count > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 21;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.frame = CGRectMake(0, 0, self.view.frame.size.width, 21);
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.frame = CGRectMake(13, 3, 15, 15);
    title.font = [UIFont systemFontOfSize:15.f];
    title.textColor = HEXCOLOR(0x999999);
    [view addSubview:title];

    title.text = self.resultKeys[section];
    return view;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.resultKeys;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

#pragma mark - UISearchBarDelegate
//  执行 delegate 搜索好友
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.matchFriendList removeAllObjects];
    if (searchText.length <= 0) {
        [self sortAndRefreshWithList:self.contactsArray];
    } else {
        for (RCDContactsInfo *contacts in self.contactsArray) {
            NSString *name = contacts.name;
            // //忽略大小写去判断是否包含
            if ([name rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound ||
                [[RCDUtilities hanZiToPinYinWithString:name] rangeOfString:searchText options:NSCaseInsensitiveSearch]
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

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    [controller dismissModalViewControllerAnimated:NO]; //关键的一句   不能为YES
    switch (result) {
    case MessageComposeResultCancelled: {
        // click cancel button
    } break;
    case MessageComposeResultFailed:
        // send failed

        break;
    case MessageComposeResultSent: {
        [self.navigationController popViewControllerAnimated:YES];
        [self.view showHUDMessage:RCDLocalizedString(@"send_success")];
        // do something
    } break;
    default:
        break;
    }
}

#pragma mark - Target Action
- (void)onRightButtonClick {
    [self sendMsg];
}

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
    if (manager.state == RCDContactsAuthStateApprove) {
        UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:RCDLocalizedString(@"send")
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(onRightButtonClick)];
        self.navigationItem.rightBarButtonItem = rightBarItem;
        rightBarItem.enabled = NO;
    } else if (manager.state == RCDContactsAuthStateRefuse) {
        self.navigationItem.rightBarButtonItem = nil;
    }
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
}

- (void)setupData {
    self.resultKeys = [[NSArray alloc] init];
    self.resultSectionDict = [[NSDictionary alloc] init];
    self.matchFriendList = [[NSMutableArray alloc] init];

    self.contactsArray = [[NSArray alloc] init];
    self.selectContacts = [[NSMutableArray alloc] init];

    self.title = RCDLocalizedString(@"Invite_Phonebook_Title");
    RCDAddressBookManager *manager = [RCDAddressBookManager sharedManager];
    [manager getContactsAuthState];
    if (manager.state == RCDContactsAuthStateNotDetermine) {
        [manager requestAuth];
    } else if (manager.state == RCDContactsAuthStateApprove) {
        self.contactsArray = [manager getAllContacts];
        [self sortAndRefreshWithList:self.contactsArray];
        [self.tableView reloadData];
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
}

- (void)sendMsg {
    if ([MFMessageComposeViewController canSendText]) {
        NSMutableArray *phoneNumbers = [NSMutableArray arrayWithCapacity:self.selectContacts.count];
        for (RCDContactsInfo *contacts in self.selectContacts) {
            if (contacts.phoneNumber.length > 0) {
                [phoneNumbers addObject:contacts.phoneNumber];
            }
        }
        MFMessageComposeViewController *vc = [[MFMessageComposeViewController alloc] init];
        vc.body = RCDLocalizedString(@"SMSBody");
        vc.recipients = [phoneNumbers copy];
        vc.messageComposeDelegate = self;
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController presentViewController:vc animated:YES completion:nil];
    } else {
        [self.view showHUDMessage:RCDLocalizedString(@"DeviceNotSupportedSMS")];
    }
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

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        [_tableView setSectionIndexColor:[UIColor darkGrayColor]];
        _tableView.allowsMultipleSelection = YES;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
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

@end
