//
//  RCDGroupMemberSelectController.m
//  SealTalk
//
//  Created by 张改红 on 2019/6/18.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDGroupSelectNewOwnerController.h"
#import "RCDUIBarButtonItem.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDUserInfoManager.h"
#import "RCDGroupMemberCell.h"
#import "RCDGroupManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NormalAlertView.h"
#import "RCDUtilities.h"
#import "UIColor+RCColor.h"
#import "UIView+MBProgressHUD.h"
@interface RCDGroupSelectNewOwnerController () <UISearchControllerDelegate, UISearchResultsUpdating>
@property (nonatomic, strong) NSArray *allMembers;
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) NSArray *resultKeys;
@property (nonatomic, strong) NSDictionary *resultSectionDict;
@property (nonatomic, strong) NSMutableArray *searchKeys;
@property (nonatomic, strong) NSMutableDictionary *searchResultDic;
@property (nonatomic, retain) UISearchController *searchController;

@end

@implementation RCDGroupSelectNewOwnerController
#pragma mark - life cycle
- (instancetype)initWithGroupId:(NSString *)groupId {
    if (self = [super init]) {
        self.groupId = groupId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = RCDLocalizedString(@"GroupSelectNewOwner");
    self.definesPresentationContext = YES;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    if ([self.tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }

    RCDUIBarButtonItem *leftBtn = [[RCDUIBarButtonItem alloc] initWithLeftBarButton:RCDLocalizedString(@"back")
                                                                             target:self
                                                                             action:@selector(clickBackBtn)];
    self.navigationItem.leftBarButtonItem = leftBtn;

    [self getData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.resultKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = self.resultKeys[section];
    NSArray *array = self.resultSectionDict[key];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDGroupMemberCell *cell = [RCDGroupMemberCell cellWithTableView:tableView];
    NSString *key = self.resultKeys[indexPath.section];
    NSArray *array = self.resultSectionDict[key];
    RCUserInfo *user = array[indexPath.row];
    [cell setDataModel:user.userId groupId:self.groupId];
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.frame = CGRectMake(0, 0, self.view.frame.size.width, 30);
    view.backgroundColor = [UIColor clearColor];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.frame = CGRectMake(12, 8, 15, 15);
    title.font = [UIFont systemFontOfSize:15.f];
    title.textColor = RCDDYCOLOR(0x999999, 0x666666);
    [view addSubview:title];
    title.text = self.resultKeys[section];
    return view;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.resultKeys;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = self.resultKeys[indexPath.section];
    NSArray *array = self.resultSectionDict[key];
    RCUserInfo *user = array[indexPath.row];
    [NormalAlertView
        showAlertWithMessage:[NSString stringWithFormat:RCDLocalizedString(@"GroupSelectNewOwnerTitle"), user.name]
        highlightText:user.name
        leftTitle:RCDLocalizedString(@"cancel")
        rightTitle:RCDLocalizedString(@"confirm")
        cancel:^{

        }
        confirm:^{
            [self setNewGroupOwer:user.userId];
        }];
}

#pragma mark - UISearchController Delegate -
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    //谓词搜索过滤
    NSString *searchString = [self.searchController.searchBar text];
    self.resultKeys = nil;
    self.resultSectionDict = nil;
    if ([searchString isEqualToString:@""]) {
        [self sortAndRefreshWithList:self.allMembers];
        return;
    } else {
        NSMutableArray *array = [NSMutableArray array];
        for (RCUserInfo *userInfo in self.allMembers) {
            RCUserInfo *user = [RCDUserInfoManager getUserInfo:userInfo.userId];
            RCDFriendInfo *friend = [RCDUserInfoManager getFriendInfo:userInfo.userId];
            RCDGroupMember *member = [RCDGroupManager getGroupMember:userInfo.userId groupId:self.groupId];
            if ([user.name containsString:searchString] || [friend.displayName containsString:searchString] ||
                [member.groupNickname containsString:searchString]) {
                [array addObject:userInfo];
            }
        }
        [self sortAndRefreshWithList:array.copy];
    }
}

#pragma mark - target action
- (void)clickBackBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - helper
- (void)getData {
    NSMutableArray *array = [RCDGroupManager getGroupMembers:self.groupId].mutableCopy;
    [array removeObject:[RCIM sharedRCIM].currentUserInfo.userId];
    NSMutableArray *list = [NSMutableArray array];
    for (NSString *userId in array) {
        RCUserInfo *user = [RCDUserInfoManager getUserInfo:userId];
        RCDFriendInfo *friend = [RCDUserInfoManager getFriendInfo:userId];
        if (friend.displayName.length > 0) {
            user.name = friend.displayName;
        }
        [list addObject:user];
    }
    self.allMembers = list.copy;
    [self sortAndRefreshWithList:list.copy];
}

- (void)setNewGroupOwer:(NSString *)userId {

    RCNetworkStatus status = [[RCIMClient sharedRCIMClient] getCurrentNetworkStatus];
    if (RC_NotReachable == status) {
        [self.view showHUDMessage:RCDLocalizedString(@"network_can_not_use_please_check")];
        return;
    }

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [RCDGroupManager
        transferGroupOwner:userId
                   groupId:self.groupId
                  complete:^(BOOL success) {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                          if (success) {
                              NSArray *array = self.navigationController.viewControllers;
                              [self.navigationController popToViewController:array[array.count - 1 - 2] animated:YES];
                          } else {
                              [self.view showHUDMessage:RCDLocalizedString(@"Failed")];
                          }
                      });
                  }];
}

- (void)sortAndRefreshWithList:(NSArray *)friendList {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSDictionary *resultDic = [[RCDUtilities sortedArrayWithPinYinDic:friendList] copy];
        self.resultKeys = resultDic[@"allKeys"];
        self.resultSectionDict = resultDic[@"infoDic"];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

#pragma mark - getter
- (UISearchController *)searchController {
    if (!_searchController) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchController.delegate = self;
        _searchController.searchResultsUpdater = self;
        //提醒字眼
        _searchController.searchBar.placeholder = NSLocalizedStringFromTable(@"ToSearch", @"RongCloudKit", nil);
        if (@available(iOS 13.0, *)) {
            _searchController.searchBar.searchTextField.backgroundColor =
                [RCDUtilities generateDynamicColor:HEXCOLOR(0xffffff)
                                         darkColor:[HEXCOLOR(0x1c1c1e) colorWithAlphaComponent:0.6]];
        }
        //设置顶部搜索栏的背景色
        _searchController.searchBar.barTintColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
        _searchController.dimsBackgroundDuringPresentation = NO;
    }
    return _searchController;
}
@end
