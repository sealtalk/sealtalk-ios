//
//  RCDGroupMemberSelectController.m
//  SealTalk
//
//  Created by 张改红 on 2019/6/18.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDGroupMemberSelectController.h"
#import "RCDContactTableViewCell.h"
#import "RCDPersonDetailViewController.h"
#import "RCDUIBarButtonItem.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDUserInfoManager.h"
#import "RCDGroupMemberSelectCell.h"
#import "RCDGroupManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NormalAlertView.h"
#import "RCDUtilities.h"
#import "UIColor+RCColor.h"
#import "UIView+MBProgressHUD.h"
@interface RCDGroupMemberSelectController () <UISearchControllerDelegate, UISearchResultsUpdating>
@property (nonatomic, strong) NSArray *allMembers;
@property (nonatomic, strong) NSMutableArray *selectUsers;
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) NSArray *resultKeys;
@property (nonatomic, strong) NSDictionary *resultSectionDict;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) RCDUIBarButtonItem *rightBtn;
@property (nonatomic, strong) NSArray *managers;
@property (nonatomic, assign) RCDGroupMemberSelectType type;
@end

@implementation RCDGroupMemberSelectController
#pragma mark - life cycle
- (instancetype)initWithGroupId:(NSString *)groupId type:(RCDGroupMemberSelectType)type {
    if (self = [super init]) {
        self.groupId = groupId;
        self.type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.definesPresentationContext = YES;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    if ([self.tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }

    [self setNaviItem];
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
    RCDGroupMemberSelectCell *cell = [RCDGroupMemberSelectCell cellWithTableView:tableView];
    NSString *key = self.resultKeys[indexPath.section];
    NSArray *array = self.resultSectionDict[key];
    RCUserInfo *user = array[indexPath.row];
    [cell setDataModel:user.userId groupId:self.groupId];
    if (self.type == RCDGroupMemberSelectTypePoke) {
        if ([user.userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
            [cell setCellSelectState:(RCDGroupMemberSelectCellStateDisable)];
        } else if ([self.selectUsers containsObject:user.userId]) {
            [cell setCellSelectState:(RCDGroupMemberSelectCellStateSelected)];
        } else {
            [cell setCellSelectState:(RCDGroupMemberSelectCellStateUnselected)];
        }
    } else if (self.type == RCDGroupMemberSelectTypeAddManager) {
        if ([user.userId isEqualToString:[RCDGroupManager getGroupOwner:self.groupId]] ||
            [self.managers containsObject:user.userId]) {
            [cell setCellSelectState:(RCDGroupMemberSelectCellStateDisable)];
        } else if ([self.selectUsers containsObject:user.userId]) {
            [cell setCellSelectState:(RCDGroupMemberSelectCellStateSelected)];
        } else {
            [cell setCellSelectState:(RCDGroupMemberSelectCellStateUnselected)];
        }
    }
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
    if (self.selectUsers.count + self.managers.count >= 5) {
        [self.view showHUDMessage:RCDLocalizedString(@"GroupManagerOverMax")];
        return;
    }
    NSString *key = self.resultKeys[indexPath.section];
    NSArray *array = self.resultSectionDict[key];
    RCUserInfo *user = array[indexPath.row];
    RCDGroupMemberSelectCell *cell = (RCDGroupMemberSelectCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ([self.selectUsers containsObject:user.userId]) {
        [self.selectUsers removeObject:user.userId];
        [cell setCellSelectState:(RCDGroupMemberSelectCellStateUnselected)];
    } else {
        [self.selectUsers addObject:user.userId];
        [cell setCellSelectState:(RCDGroupMemberSelectCellStateSelected)];
    }
    [self refreshNaviItem];
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

- (void)confirmAction {
    if (self.selectResult) {
        self.selectResult(self.selectUsers);
        [self.navigationController popViewControllerAnimated:YES];
    } else if (self.type == RCDGroupMemberSelectTypeAddManager) {
        NSString *names = [NSString string];
        for (NSString *userId in self.selectUsers) {
            RCUserInfo *user = [RCDUserInfoManager getUserInfo:userId];
            RCDFriendInfo *friend = [RCDUserInfoManager getFriendInfo:userId];
            if (friend.displayName.length > 0) {
                names = [names stringByAppendingString:friend.displayName];
            } else {
                names = [names stringByAppendingString:user.name];
            }
            if (![userId isEqualToString:self.selectUsers[self.selectUsers.count - 1]]) {
                names = [names stringByAppendingString:@"、"];
            }
        }
        [NormalAlertView
            showAlertWithMessage:[NSString stringWithFormat:RCDLocalizedString(@"GroupSetManagerTitle"), names]
            highlightText:names
            leftTitle:RCDLocalizedString(@"cancel")
            rightTitle:RCDLocalizedString(@"confirm")
            cancel:^{

            }
            confirm:^{
                [self setGroupManagers];
            }];
    }
}

#pragma mark - helper
- (void)getData {
    self.managers = [RCDGroupManager getGroupManagers:self.groupId];
    NSMutableArray *array = [RCDGroupManager getGroupMembers:self.groupId].mutableCopy;
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

- (void)setGroupManagers {
    RCNetworkStatus status = [[RCIMClient sharedRCIMClient] getCurrentNetworkStatus];
    if (RC_NotReachable == status) {
        [self.view showHUDMessage:RCDLocalizedString(@"network_can_not_use_please_check")];
        return;
    }

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [RCDGroupManager addGroupManagers:self.selectUsers
                              groupId:self.groupId
                             complete:^(BOOL success) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                     if (success) {
                                         [self.navigationController popViewControllerAnimated:YES];
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

- (void)setNaviItem {
    if (self.type == RCDGroupMemberSelectTypePoke) {
        self.title = RCDLocalizedString(@"SelectMember");
    } else if (self.type == RCDGroupMemberSelectTypeAddManager) {
        self.title = RCDLocalizedString(@"GroupManagerTitle");
    }
    RCDUIBarButtonItem *leftBtn = [[RCDUIBarButtonItem alloc] initWithLeftBarButton:RCDLocalizedString(@"back")
                                                                             target:self
                                                                             action:@selector(clickBackBtn)];
    self.navigationItem.leftBarButtonItem = leftBtn;

    self.rightBtn = [[RCDUIBarButtonItem alloc] initWithTitle:RCDLocalizedString(@"confirm")
                                                        style:(UIBarButtonItemStylePlain)
                                                       target:self
                                                       action:@selector(confirmAction)];
    self.navigationItem.rightBarButtonItem = self.rightBtn;
    self.rightBtn.enabled = NO;
}

- (void)refreshNaviItem {
    if (self.selectUsers.count > 0) {
        self.rightBtn.title =
            [NSString stringWithFormat:@"%@(%ld)", RCDLocalizedString(@"confirm"), self.selectUsers.count];
        self.rightBtn.enabled = YES;
    } else {
        self.rightBtn.title = RCDLocalizedString(@"confirm");
        self.rightBtn.enabled = NO;
    }
}

#pragma mark - getter
- (UISearchController *)searchController {
    if (!_searchController) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchController.delegate = self;
        _searchController.searchResultsUpdater = self;
        //提醒字眼
        _searchController.searchBar.placeholder = NSLocalizedStringFromTable(@"ToSearch", @"RongCloudKit", nil);
        //设置顶部搜索栏的背景色
        _searchController.searchBar.barTintColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
        _searchController.dimsBackgroundDuringPresentation = NO;
    }
    return _searchController;
}

- (NSMutableArray *)selectUsers {
    if (!_selectUsers) {
        _selectUsers = [NSMutableArray array];
    }
    return _selectUsers;
}
@end
