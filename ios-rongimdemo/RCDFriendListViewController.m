//
//  RCDFriendListViewController.m
//  RCloudMessage
//
//  Created by Sin on 16/8/19.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDFriendListViewController.h"
#import "DefaultPortraitView.h"
#import "RCDUserListTableViewCell.h"
#import "UIImageView+WebCache.h"
#import <RongIMKit/RongIMKit.h>

#define RCD_IOS_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)                                                             \
    ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface RCDFriendListViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate,
                                           UISearchDisplayDelegate> {
    NSMutableArray *_tempOtherArr;
    NSMutableDictionary *allUsers;
    NSArray *allKeys;
}

//@property (nonatomic,strong) UITableView *tableView;
@property(nonatomic, strong) NSArray *userListArr; //数据源
@property(nonatomic, strong) NSMutableArray *dataArr;
@property(nonatomic, strong) UISearchBar *searchBar;                             //搜索框
@property(nonatomic, strong) UISearchDisplayController *searchDisplayController; //搜索VC

@end

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
@implementation RCDFriendListViewController

{
    NSMutableArray *_searchResultArr; //搜索结果Arr
}

#pragma mark - dataArr(模拟从服务器获取到的数据)

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configTableView];
    allUsers = [NSMutableDictionary new];
    if (RCD_IOS_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    allKeys = [NSMutableArray new];
    self.dataArr = [NSMutableArray array];
    allUsers = nil; //[self sortedArrayWithPinYinDic:self.dataArr];
    [self.tableView reloadData];

    // configNav
    [self configNav];
    //布局View
    [self setUpView];

    _searchDisplayController =
        [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    [_searchDisplayController setDelegate:self];
    [_searchDisplayController setSearchResultsDataSource:self];
    [_searchDisplayController setSearchResultsDelegate:self];

    _searchResultArr = [NSMutableArray array];

    if (self.delegate) {
        __weak typeof(self) weakSelf = self;
        [self.delegate getFriendList:^(NSArray<NSString *> *friendList) {
            [weakSelf loadFriendsList:friendList];
        }];
    }
}

- (void)configTableView {

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, kScreenWidth, kScreenHeight)
                                                  style:UITableViewStylePlain];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    [self.tableView setSectionIndexColor:[UIColor darkGrayColor]];
    [self.tableView setBackgroundColor:[UIColor colorWithRed:240.0 / 255 green:240.0 / 255 blue:240.0 / 255 alpha:1]];
    self.tableView.tableHeaderView = self.searchBar;
    // cell无数据时，不显示间隔线
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setTableFooterView:v];
}

- (void)loadFriendsList:(NSArray *)friendsList {
    dispatch_queue_t queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        [self.dataArr removeAllObjects];
        for (NSString *friendId in friendsList) {
            if (!([RCIM sharedRCIM].currentUserInfo &&
                  [friendId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId])) {
                RCUserInfo *userInfo = [[RCIM sharedRCIM] getUserInfoCache:friendId];
                if (userInfo) {
                    [self.dataArr addObject:userInfo];
                }
            }
        }

        NSMutableDictionary *tmpDict = [self sortedArrayWithPinYinDic:self.dataArr];
        dispatch_async(dispatch_get_main_queue(), ^{
            allUsers = tmpDict;
            [self.tableView reloadData];
        });

    });
}

- (void)configNav {
    self.navigationItem.title = self.navigationTitle;
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 6, 72, 23);
    UILabel *backText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 22)];
    backText.text = NSLocalizedStringFromTable(@"Cancel", @"RongCloudKit", nil);
    [backText setBackgroundColor:[UIColor clearColor]];
    [backText setTextColor:[UIColor whiteColor]];
    [backBtn addSubview:backText];
    [backBtn addTarget:self action:@selector(leftBarButtonItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    [self.navigationItem setLeftBarButtonItem:leftButton];
}

- (void)leftBarButtonItemPressed:(id)sender {
    if (_cancelBlock) {
        _cancelBlock(nil);
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - setUpView
- (void)setUpView {
    [self.tableView setBackgroundColor:[UIColor colorWithRed:235 / 255.0 green:235 / 255.0 blue:235 / 255.0 alpha:1]];
}
- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
        [_searchBar sizeToFit];
        [_searchBar setPlaceholder:NSLocalizedStringFromTable(@"ToSearch", @"RongCloudKit", nil)];
        [_searchBar.layer setBorderWidth:0.5];
        [_searchBar.layer
            setBorderColor:[UIColor colorWithRed:229.0 / 255 green:229.0 / 255 blue:229.0 / 255 alpha:1].CGColor];
        [_searchBar setDelegate:self];
        [_searchBar setKeyboardType:UIKeyboardTypeDefault];
    }
    return _searchBar;
}

#pragma mark - UITableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // section
    if (tableView == _searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
        return allKeys.count;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // row
    if (tableView == _searchDisplayController.searchResultsTableView) {
        return _searchResultArr.count;
    } else {
        NSString *key = [allKeys objectAtIndex:section];
        NSArray *arr = [allUsers objectForKey:key];
        return [arr count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [RCIM sharedRCIM].globalMessagePortraitSize.height + 5 + 5;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView != _searchDisplayController.searchResultsTableView) {
        return allKeys;
    } else {
        return nil;
    }
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index - 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == _searchDisplayController.searchResultsTableView) {
        return 0;
    } else {
        return 22.0;
    }
}

#pragma mark - UITableView dataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIde = @"cellIde";
    RCDUserListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
    if (cell == nil) {
        cell = [[RCDUserListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIde];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (tableView == _searchDisplayController.searchResultsTableView) {
        RCUserInfo *user = _searchResultArr[indexPath.row];
        if ([user.portraitUri hasPrefix:@"file"]) {
            cell.headImageView.image = [UIImage imageWithContentsOfFile:user.portraitUri];
        } else if ([user.portraitUri isEqualToString:@""]) {
            DefaultPortraitView *defaultPortrait =
                [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
            [defaultPortrait setColorAndLabel:user.userId Nickname:user.name];
            UIImage *portrait = [defaultPortrait imageFromView];
            cell.headImageView.image = portrait;
        } else {
            [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:user.portraitUri]
                                  placeholderImage:[UIImage imageNamed:@"icon_person"]];
        }

        [cell.nameLabel setText:user.name];
    } else {
        NSString *key = [allKeys objectAtIndex:indexPath.section];
        NSArray *arrayForKey = [allUsers objectForKey:key];
        RCUserInfo *user = arrayForKey[indexPath.row];
        if ([user.portraitUri hasPrefix:@"file"] || [user.portraitUri isEqualToString:@""]) {
            DefaultPortraitView *defaultPortrait =
                [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
            [defaultPortrait setColorAndLabel:user.userId Nickname:user.name];
            UIImage *portrait = [defaultPortrait imageFromView];
            cell.headImageView.image = portrait;
        } else {
            [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:user.portraitUri]
                                  placeholderImage:[UIImage imageNamed:@"icon_person"]];
        }
        [cell.nameLabel setText:user.name];
    }

    return cell;
}
/*
if (indexPath.section == 0) {
    if ([portraitUrl isEqualToString:@""]) {
        DefaultPortraitView *defaultPortrait = [[DefaultPortraitView alloc]
                                                initWithFrame:CGRectMake(0, 0, 100, 100)];
        [defaultPortrait setColorAndLabel:self.userId Nickname:nickname];
        UIImage *portrait = [defaultPortrait imageFromView];
        infoCell.PortraitImageView.image = portrait;
    } else {
        [infoCell.PortraitImageView
         sd_setImageWithURL:[NSURL URLWithString:portraitUrl]
         placeholderImage:[UIImage imageNamed:@"icon_person"]];
    }
    infoCell.PortraitImageView.layer.masksToBounds = YES;
    infoCell.PortraitImageView.layer.cornerRadius = 5.f;
    infoCell.PortraitImageView.contentMode = UIViewContentModeScaleAspectFill;
    infoCell.NickNameLabel.text = nickname;
 */

#pragma mark searchBar delegate
// searchBar开始编辑时改变取消按钮的文字
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    NSArray *subViews;
    subViews = [(searchBar.subviews[0])subviews];
    for (id view in subViews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *cancelbutton = (UIButton *)view;
            [cancelbutton setTitle:NSLocalizedStringFromTable(@"Cancel", @"RongCloudKit", nil)
                          forState:UIControlStateNormal];
            break;
        }
    }
    searchBar.showsCancelButton = YES;
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return YES;
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    //取消
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *key = [allKeys objectAtIndex:section];
    return key;
}

#pragma mark searchDisplayController delegate
- (void)searchDisplayController:(UISearchDisplayController *)controller
    willShowSearchResultsTableView:(UITableView *)tableView {
    // cell无数据时，不显示间隔线
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [tableView setTableFooterView:v];
}
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
    shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString
                               scope:[self.searchBar scopeButtonTitles][self.searchBar.selectedScopeButtonIndex]];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
    shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self filterContentForSearchText:self.searchBar.text scope:self.searchBar.scopeButtonTitles[searchOption]];
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RCUserInfo *user;
    if (tableView == _searchDisplayController.searchResultsTableView) {
        user = _searchResultArr[indexPath.row];
    } else {
        NSString *key = [allKeys objectAtIndex:indexPath.section];
        NSArray *arrayForKey = [allUsers objectForKey:key];
        user = arrayForKey[indexPath.row];
    }
    if (self.selectedBlock) {
        self.selectedBlock(user);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 源字符串内容是否包含或等于要搜索的字符串内容
- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope {
    NSMutableArray *tempResults = [NSMutableArray array];
    NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;

    for (int i = 0; i < self.dataArr.count; i++) {
        NSString *storeString = [(RCUserInfo *)self.dataArr[i] name];
        NSString *storeImageString =
            [(RCUserInfo *)self.dataArr[i] portraitUri] ? [(RCUserInfo *)self.dataArr[i] portraitUri] : @"";

        NSRange storeRange = NSMakeRange(0, storeString.length);

        NSRange foundRange = [storeString rangeOfString:searchText options:searchOptions range:storeRange];
        if (foundRange.length) {
            NSDictionary *dic = @{@"name" : storeString, @"portrait" : storeImageString};

            [tempResults addObject:self.dataArr[i]];
        }
    }
    [_searchResultArr removeAllObjects];
    [_searchResultArr addObjectsFromArray:tempResults];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  根据转换拼音后的字典排序
 *
 *  @param pinyinDic 转换后的字典
 *
 *  @return 对应排序的字典
 */
- (NSMutableDictionary *)sortedArrayWithPinYinDic:(NSArray *)friends {
    if (!friends)
        return nil;
    NSArray *_keys = @[
        @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N",
        @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"#"
    ];

    NSMutableDictionary *returnDic = [NSMutableDictionary new];
    _tempOtherArr = [NSMutableArray new];
    BOOL isReturn = NO;

    for (NSString *key in _keys) {

        if ([_tempOtherArr count]) {
            isReturn = YES;
        }

        NSMutableArray *tempArr = [NSMutableArray new];
        for (RCUserInfo *user in friends) {

            NSString *pyResult = [self hanZiToPinYinWithString:user.name];
            NSString *firstLetter = [pyResult substringToIndex:1];
            if ([firstLetter isEqualToString:key]) {
                [tempArr addObject:user];
            }

            if (isReturn)
                continue;
            char c = [pyResult characterAtIndex:0];
            if (isalpha(c) == 0) {
                [_tempOtherArr addObject:user];
            }
        }
        if (![tempArr count])
            continue;
        [returnDic setObject:tempArr forKey:key];
    }
    if ([_tempOtherArr count])
        [returnDic setObject:_tempOtherArr forKey:@"#"];

    allKeys = [[returnDic allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {

        return [obj1 compare:obj2 options:NSNumericSearch];
    }];

    return returnDic;
}

/**
 *  汉字转拼音
 *
 *  @param hanZi 汉字
 *
 *  @return 转换后的拼音
 */
- (NSString *)hanZiToPinYinWithString:(NSString *)hanZi {
    if (!hanZi)
        return nil;

    return [self firstCharactor:hanZi];
}
//获取拼音首字母(传入汉字字符串, 返回大写拼音首字母)
- (NSString *)firstCharactor:(NSString *)aString {
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:aString];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformMandarinLatin, NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformStripDiacritics, NO);
    //转化为大写拼音
    NSString *pinYin = [str capitalizedString];
    //获取并返回首字母
    return [pinYin substringToIndex:1];
}
@end
