//
//  RCDContactSelectedTableViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/3/17.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDContactSelectedTableViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "RCDChatViewController.h"
#import "RCDContactSelectedCollectionViewCell.h"
#import "RCDContactSelectedTableViewCell.h"
#import "RCDCreateGroupViewController.h"
#import "RCDNoFriendView.h"
#import "RCDRCIMDataSource.h"
#import "RCDUIBarButtonItem.h"
#import "RCDUserInfoManager.h"
#import "RCDGroupManager.h"
#import "RCDUtilities.h"
#import "UIColor+RCColor.h"
#import "RCDForwardManager.h"
#import "UIView+MBProgressHUD.h"
#import "RCDSearchBar.h"
#import "RCDTableView.h"
@interface RCDContactSelectedTableViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,
                                                     UICollectionViewDelegate, UITableViewDelegate,
                                                     UITableViewDataSource, UISearchBarDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSMutableDictionary *allFriendsDict;
@property (nonatomic, strong) NSArray *allKeys;

@property (strong, nonatomic) NSMutableArray *friendArray;
@property (nonatomic, strong) NSMutableArray *collectionViewResource;
//进入页面以后选中的userId的集合
@property (nonatomic, strong) NSMutableArray *selectUserList;
//搜索出的结果数据集合
@property (nonatomic, strong) NSMutableArray *matchSearchList;

@property (nonatomic, strong) NSString *searchContent;

//是否是显示搜索的结果
@property (nonatomic, assign) BOOL isSearchResult;
//判断当前操作是否是删除操作
@property (nonatomic, assign) BOOL isDeleteUser;
@property (nonatomic, assign) BOOL isAllowsMultipleSelection;
// collectionView展示的最大数量
@property (nonatomic, assign) NSInteger maxCount;
@property (nonatomic, strong) NSIndexPath *selectIndexPath;

@property (nonatomic, strong) RCDNoFriendView *noFriendView;
@property (nonatomic, strong) RCDUIBarButtonItem *rightBtn;
@property (nonatomic, strong) UICollectionView *selectedUsersCollectionView;
@property (nonatomic, strong) RCDTableView *tableView;
@property (nonatomic, strong) RCDSearchBar *searchBar;
@property (nonatomic, strong) UITextField *searchField;
@property (nonatomic, strong) UIView *searchFieldLeftView;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation RCDContactSelectedTableViewController

#pragma mark - Life Cycle

- (instancetype)initWithTitle:(NSString *)title isAllowsMultipleSelection:(BOOL)isAllowsMultipleSelection {
    if (self = [super init]) {
        self.navigationItem.title = title;
        self.isAllowsMultipleSelection = isAllowsMultipleSelection;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavi];
    [self initData];
    [self setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.allFriendsDict count] <= 0) {
        [self getAllData];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.rightBtn buttonIsCanClick:YES buttonColor:RCDDYCOLOR(0xffffff, 0xA8A8A8) barButtonItem:self.rightBtn];
    [self.hud hide:YES];
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
    self.noFriendView.frame = CGRectMake(0, 0, RCDScreenWidth, RCDScreenHeight - 64);
    self.tableView.frame =
        CGRectMake(0, 54, RCDScreenWidth, RCDScreenHeight - 64 - 54 - RCDExtraTopHeight - RCDExtraBottomHeight);
}

#pragma mark - Private Method
- (void)setupNavi {
    self.navigationItem.leftBarButtonItem =
        [[RCDUIBarButtonItem alloc] initWithLeftBarButton:RCDLocalizedString(@"back")
                                                   target:self
                                                   action:@selector(clickBackBtn)];
    self.navigationItem.rightBarButtonItems = [self.rightBtn setTranslation:self.rightBtn translation:-11];
}

- (void)setupSubviews {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.selectedUsersCollectionView];
    [self.view addSubview:self.searchBar];
}

- (void)initData {
    self.isDeleteUser = NO;
    self.matchSearchList = [NSMutableArray new];
    self.selectUserList = [NSMutableArray new];
    self.collectionViewResource = [NSMutableArray new];
    self.allFriendsDict = [NSMutableDictionary new];
    self.allKeys = [NSMutableArray new];
    self.friendArray = [NSMutableArray new];
    self.searchContent = @"";

    if (RCDScreenWidth < 375) {
        self.maxCount = 5;
    } else if (RCDScreenWidth >= 375 && RCDScreenWidth < 414) {
        self.maxCount = 6;
    } else {
        self.maxCount = 7;
    }

    if (self.groupOptionType == RCDContactSelectedGroupOptionTypeCreate && self.orignalGroupMembers.count > 0) {
        [self.collectionViewResource addObjectsFromArray:self.orignalGroupMembers];
        [self setCollectonViewAndSearchBarFrame:self.collectionViewResource.count];
        [self.selectedUsersCollectionView reloadData];
    }
}

// 获取好友并且排序
- (void)getAllData {
    NSMutableArray *friends = [NSMutableArray arrayWithArray:[RCDUserInfoManager getAllFriends]];
    if (friends == nil || friends.count < 1) {
        [self getUserInfoFromServer];
    } else {
        [self dealWithFriendList:friends];
    }
}

- (void)getUserInfoFromServer {
    [RCDUserInfoManager getFriendListFromServer:^(NSArray<RCDFriendInfo *> *friendList) {
        NSMutableArray *friends;
        if (friendList.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.noFriendView != nil) {
                    [self.noFriendView removeFromSuperview];
                }
            });
            friends = [[RCDUserInfoManager getAllFriends] mutableCopy];
        }
        [self dealWithFriendList:friends];
    }];
}

- (void)dealWithFriendList:(NSMutableArray *)friends {
    self.friendArray = friends;
    if (self.friendArray.count < 1 && self.groupOptionType != RCDContactSelectedGroupOptionTypeDelete) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view addSubview:self.noFriendView];
            [self.view bringSubviewToFront:self.noFriendView];
        });
    } else {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self deleteGroupMembers];
            NSMutableDictionary *resultDic = [RCDUtilities sortedArrayWithPinYinDic:self.friendArray];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.allFriendsDict = resultDic[@"infoDic"];
                self.allKeys = resultDic[@"allKeys"];
                [self.tableView reloadData];
            });
        });
    }
}

- (void)deleteGroupMembers {
    if (self.groupOptionType == RCDContactSelectedGroupOptionTypeDelete) {
        self.friendArray = self.orignalGroupMembers;
    }
}

- (BOOL)isContain:(NSString *)userId {
    BOOL contain = NO;
    NSArray *userList;
    if (self.orignalGroupMembers.count > 0 && self.groupOptionType != RCDContactSelectedGroupOptionTypeDelete) {
        userList = self.orignalGroupMembers;
    }
    for (id member in userList) {
        NSString *memberId;
        if ([member isKindOfClass:[RCUserInfo class]]) {
            RCUserInfo *user = (RCUserInfo *)member;
            memberId = user.userId;
        } else {
            memberId = member;
        }
        if ([userId isEqualToString:memberId]) {
            contain = YES;
            break;
        }
    }
    return contain;
}

//设置collectionView和searchBar实时显示的frame效果
- (void)setCollectonViewAndSearchBarFrame:(NSInteger)count {
    CGRect frame = CGRectZero;
    if (count == 0) {
        //只显示searchBar
        frame = CGRectMake(0, 0, 0, 54);
        self.selectedUsersCollectionView.frame = frame;
        self.searchBar.frame = [self getSearchBarFrame:frame];
        self.searchField.leftView = self.searchFieldLeftView;
        self.searchBar.placeholder = RCDLocalizedString(@"search");
    } else if (count == 1) {
        frame = CGRectMake(0, 0, 46, 54);
        self.selectedUsersCollectionView.frame = frame;
        self.searchBar.frame = [self getSearchBarFrame:frame];
        self.searchField.leftView = nil;
    } else if (count > 1 && count <= self.maxCount) {
        if (self.isDeleteUser == NO) {
            //如果是删除选中的联系人时候的处理
            frame = CGRectMake(0, 0, 46 + (count - 1) * 46, 54);
            self.selectedUsersCollectionView.frame = frame;
            self.searchBar.frame = [self getSearchBarFrame:frame];
        } else {
            if (count < self.maxCount) {
                //判断如果当前collectionView的显示数量小于最大展示数量的时候，collectionView和searchBar的frame都会改变
                frame = CGRectMake(0, 0, 61 + (count - 1) * 46, 54);
                self.selectedUsersCollectionView.frame = frame;
                self.searchBar.frame = [self getSearchBarFrame:frame];
            }
        }
    }
}

- (CGRect)getSearchBarFrame:(CGRect)frame {
    CGRect searchBarFrame = CGRectZero;
    frame.origin.x = frame.size.width;
    CGFloat searchBarWidth = RCDScreenWidth - frame.size.width;
    frame.size.width = searchBarWidth;
    searchBarFrame = frame;
    return searchBarFrame;
}

- (void)setDefaultDisplay {
    self.isSearchResult = NO;
    [self.tableView reloadData];
    if (self.collectionViewResource.count < 1) {
        self.searchField.leftView = self.searchFieldLeftView;
    }
    self.searchBar.placeholder = RCDLocalizedString(@"search");
    self.searchBar.text = @"";
    self.searchContent = @"";
    [self.searchBar resignFirstResponder];
}

- (void)setRightButton {
    NSString *titleStr;
    if (self.selectUserList.count > 0) {
        titleStr = [NSString stringWithFormat:@"%@(%zd)", RCDLocalizedString(@"confirm"), [self.selectUserList count]];
        [self.rightBtn buttonIsCanClick:YES buttonColor:RCDDYCOLOR(0xffffff, 0xA8A8A8) barButtonItem:self.rightBtn];
    } else {
        titleStr = RCDLocalizedString(@"confirm");

        [self.rightBtn
            buttonIsCanClick:NO
                 buttonColor:[RCDUtilities generateDynamicColor:HEXCOLOR(0x9fcdfd)
                                                      darkColor:[HEXCOLOR(0xA8A8A8) colorWithAlphaComponent:0.4]]
               barButtonItem:self.rightBtn];
    }
    [self.rightBtn.button setTitle:titleStr forState:UIControlStateNormal];
}

- (void)dealWithSelectUserIdListWithUser:(RCDFriendInfo *)user {
    if (self.selectUserList.count > 0) {
        RCDFriendInfo *friendInfo = self.selectUserList[0];
        if ([friendInfo.userId isEqualToString:user.userId]) {
            [self.selectUserList removeAllObjects];
        } else {
            [self.selectUserList removeAllObjects];
            [self.selectUserList addObject:user];
        }
    } else {
        [self.selectUserList addObject:user];
    }
}

- (void)showAlertViewWithMessage:(NSString *)message {
    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:RCDLocalizedString(@"confirm")
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)pushChatVCWithUserInfo:(RCDFriendInfo *)userInfo {
    RCDChatViewController *chat = [[RCDChatViewController alloc] init];
    chat.targetId = userInfo.userId;
    chat.userName = userInfo.name;
    chat.conversationType = ConversationType_PRIVATE;
    chat.title = userInfo.name;
    chat.needPopToRootView = YES;
    chat.displayUserNameInCell = NO;
    [self.navigationController pushViewController:chat animated:YES];
}

- (void)closeKeyboard {
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
    if (self.collectionViewResource.count < 1) {
        self.searchField.leftView = self.searchFieldLeftView;
    }
    if (self.searchContent.length < 1) {
        self.searchBar.placeholder = RCDLocalizedString(@"search");
    }
    if (self.isSearchResult == YES) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setDefaultDisplay];
        });
    }
}

#pragma mark - Target Action
- (void)clickedDone:(id)sender {

    if (self.searchBar.isFirstResponder) {
        [self.searchBar resignFirstResponder];
    }

    [self.rightBtn buttonIsCanClick:NO
                        buttonColor:[RCDUtilities generateDynamicColor:HEXCOLOR(0x9fcdfd)
                                                             darkColor:[HEXCOLOR(0xA8A8A8) colorWithAlphaComponent:0.4]]
                      barButtonItem:self.rightBtn];
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.color = [UIColor colorWithHexString:@"343637" alpha:0.5];
    [self.hud show:YES];

    if (self.isAllowsMultipleSelection == NO) {
        RCDFriendInfo *user = self.selectUserList[0];
        [self pushChatVCWithUserInfo:user];
    } else {
        // get seleted users
        NSMutableArray *seletedUsersId = [NSMutableArray new];
        for (RCDFriendInfo *user in self.collectionViewResource) {
            [seletedUsersId addObject:user.userId];
        }

        if (seletedUsersId.count > 0 && self.groupOptionType == RCDContactSelectedGroupOptionTypeAdd) {
            [RCDGroupManager
                addUsers:seletedUsersId
                 groupId:self.groupId
                complete:^(BOOL success, RCDGroupAddMemberStatus status){
                    rcd_dispatch_main_async_safe(^{
                        [self.hud hide:YES];
                        if (success == YES) {
                            [self.navigationController popViewControllerAnimated:YES];
                        } else {
                            [self showAlertViewWithMessage:RCDLocalizedString(@"add_member_fail")];
                            [self.rightBtn buttonIsCanClick:YES
                                                buttonColor:RCDDYCOLOR(0xffffff, 0xA8A8A8)
                                              barButtonItem:self.rightBtn];
                        }
                        if (status == RCDGroupAddMemberStatusInviteeApproving) {
                            [self.view showHUDMessage:RCDLocalizedString(@"MemberInviteNeedConfirm")];
                        } else if (status == RCDGroupAddMemberStatusOnlyManagerApproving) {
                            [self.view showHUDMessage:RCDLocalizedString(@"MemberInviteNeedManagerConfirm")];
                        }
                    })}];
            return;
        }
        if (seletedUsersId.count > 0 && self.groupOptionType == RCDContactSelectedGroupOptionTypeDelete) {
            [RCDGroupManager kickUsers:seletedUsersId
                               groupId:self.groupId
                              complete:^(BOOL success){
                                  rcd_dispatch_main_async_safe(^{
                                      [self.hud hide:YES];
                                      if (success == YES) {
                                          [self.navigationController popViewControllerAnimated:YES];
                                      } else {
                                          [self showAlertViewWithMessage:RCDLocalizedString(@"delete_member_fail")];
                                          [self.rightBtn buttonIsCanClick:YES
                                                              buttonColor:RCDDYCOLOR(0xffffff, 0xA8A8A8)
                                                            barButtonItem:self.rightBtn];
                                      }
                                  })}];
            return;
        }
        if (self.groupOptionType == RCDContactSelectedGroupOptionTypeCreate) {
            [self.hud hide:YES];
            if (self.orignalGroupMembers.count > 0) {
                for (RCDFriendInfo *friend in self.orignalGroupMembers) {
                    if (![seletedUsersId containsObject:friend.userId]) {
                        [seletedUsersId addObject:friend.userId];
                    }
                }
            }

            if (seletedUsersId.count == 1 && [RCDForwardManager sharedInstance].isForward) {
                [self.rightBtn buttonIsCanClick:YES
                                    buttonColor:RCDDYCOLOR(0xffffff, 0xA8A8A8)
                                  barButtonItem:self.rightBtn];
                RCConversation *conversation = [[RCConversation alloc] init];
                conversation.targetId = seletedUsersId[0];
                conversation.conversationType = ConversationType_PRIVATE;
                if ([RCDForwardManager sharedInstance].selectConversationCompleted) {
                    [RCDForwardManager sharedInstance].selectConversationCompleted([@[ conversation ] copy]);
                    [[RCDForwardManager sharedInstance] forwardEnd];
                } else {
                    [self.rightBtn buttonIsCanClick:YES buttonColor:[UIColor whiteColor] barButtonItem:self.rightBtn];
                    [RCDForwardManager sharedInstance].toConversation = conversation;
                    [[RCDForwardManager sharedInstance] showForwardAlertViewInViewController:self];
                }
            } else {
                RCDCreateGroupViewController *createGroupVC = [[RCDCreateGroupViewController alloc] init];
                createGroupVC.groupMemberIdList = seletedUsersId;
                [self.navigationController pushViewController:createGroupVC animated:YES];
            }
        }
    }
}

- (void)clickBackBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isSearchResult == NO) {
        return [self.allKeys count];
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearchResult == NO) {
        NSString *key = [self.allKeys objectAtIndex:section];
        NSArray *arr = [self.allFriendsDict objectForKey:key];
        return [arr count];
    }
    return self.matchSearchList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [RCDContactSelectedTableViewCell cellHeight];
}

// pinyin index
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (self.isSearchResult == NO) {
        return self.allKeys;
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.isSearchResult == NO) {
        NSString *key = [self.allKeys objectAtIndex:section];
        return key;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 15)];
    view.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
    if (self.isSearchResult == NO) {
        NSString *key = [self.allKeys objectAtIndex:section];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 8, [UIScreen mainScreen].bounds.size.width, 15)];
        label.textColor = RCDDYCOLOR(0x000000, 0x9f9f9f);
        label.font = [UIFont boldSystemFontOfSize:17];
        label.text = key;
        [view addSubview:label];
    }
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellReuseIdentifier = @"RCDContactSelectedTableViewCell";
    RCDContactSelectedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (!cell) {
        cell = [[RCDContactSelectedTableViewCell alloc] init];
    }

    RCDFriendInfo *user;
    if (self.isSearchResult == NO) {
        if (self.allKeys.count > indexPath.section) {
            NSString *key = [self.allKeys objectAtIndex:indexPath.section];
            NSArray *arrayForKey = [self.allFriendsDict objectForKey:key];
            if (arrayForKey.count > indexPath.row) {
                user = arrayForKey[indexPath.row];
            }
        }
    } else {
        if (self.matchSearchList.count > indexPath.row) {
            user = [self.matchSearchList objectAtIndex:indexPath.row];
        }
    }

    cell.groupId = self.groupId;

    //给控件填充数据
    [cell setModel:user];

    //设置选中状态
    BOOL isSelected = NO;
    for (RCDFriendInfo *friendInfo in self.selectUserList) {
        if ([user.userId isEqualToString:friendInfo.userId]) {
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            isSelected = YES;
        }
    }
    if (isSelected == NO) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    if ([self isContain:user.userId] == YES) {
        [cell setUserInteractionEnabled:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.selectedImageView.image = [UIImage imageNamed:@"disable_select"];
        });
    }
    return cell;
}

// override delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDContactSelectedTableViewCell *cell =
        (RCDContactSelectedTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (self.isAllowsMultipleSelection == NO) {
        if (self.isSearchResult == YES) {
            RCDFriendInfo *user = [self.matchSearchList objectAtIndex:indexPath.row];
            [self dealWithSelectUserIdListWithUser:user];
        } else {
            NSString *key = [self.allKeys objectAtIndex:indexPath.section];
            NSArray *arrayForKey = [self.allFriendsDict objectForKey:key];
            RCDFriendInfo *user = arrayForKey[indexPath.row];
            [self dealWithSelectUserIdListWithUser:user];
        }
        [self setRightButton];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } else {
        [cell setSelected:YES];
        if (self.selectIndexPath && [self.selectIndexPath compare:indexPath] == NSOrderedSame) {
            [cell setSelected:NO];
            self.selectIndexPath = nil;
        } else {
            RCDFriendInfo *user;
            if (self.isSearchResult == YES) {
                user = [self.matchSearchList objectAtIndex:indexPath.row];
            } else {
                self.selectIndexPath = indexPath;
                NSString *key = [self.allKeys objectAtIndex:indexPath.section];
                NSArray *arrayForKey = [self.allFriendsDict objectForKey:key];
                user = arrayForKey[indexPath.row];
            }
            [self.collectionViewResource addObject:user];
            NSInteger count = self.collectionViewResource.count;
            self.isDeleteUser = NO;
            [self setCollectonViewAndSearchBarFrame:count];
            [self.selectedUsersCollectionView reloadData];
            [self scrollToBottomAnimated:YES];
            [self.selectUserList addObject:user];
            [self setRightButton];
        }
        if (self.isSearchResult == YES) {
            [self setDefaultDisplay];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDContactSelectedTableViewCell *cell =
        (RCDContactSelectedTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (self.isAllowsMultipleSelection == YES) {
        if (self.isSearchResult == YES) {
            [self setDefaultDisplay];
            return;
        }
        [cell setSelected:NO];
        self.selectIndexPath = nil;
        NSString *key = [self.allKeys objectAtIndex:indexPath.section];
        NSArray *arrayForKey = [self.allFriendsDict objectForKey:key];
        RCDFriendInfo *user = arrayForKey[indexPath.row];
        [self.collectionViewResource removeObject:user];
        [self.selectUserList removeObject:user];
        [self.selectedUsersCollectionView reloadData];
        NSInteger count = self.collectionViewResource.count;
        self.isDeleteUser = YES;
        [self setCollectonViewAndSearchBarFrame:count];
        [self setRightButton];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.isAllowsMultipleSelection == NO) {
        if ([self.searchBar isFirstResponder]) {
            [self.searchBar resignFirstResponder];
        }
    } else {
        if (self.searchField.text.length == 0 && self.searchContent.length < 1) {
            [self setDefaultDisplay];
        }
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(36, 36);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                                 layout:(UICollectionViewLayout *)collectionViewLayout
    minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.minimumLineSpacing = 10;
    return UIEdgeInsetsMake(10, 10, 10, 0);
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.collectionViewResource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCDContactSelectedCollectionViewCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:@"RCDContactSelectedCollectionViewCell"
                                                  forIndexPath:indexPath];

    if (self.collectionViewResource.count > 0) {
        RCDFriendInfo *user = self.collectionViewResource[indexPath.row];
        [cell setUserModel:user];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self closeKeyboard];
    RCDFriendInfo *user = [self.collectionViewResource objectAtIndex:indexPath.row];
    [self.collectionViewResource removeObjectAtIndex:indexPath.row];
    [self.selectUserList removeObject:user];
    NSInteger count = self.collectionViewResource.count;
    self.isDeleteUser = YES;
    [self setCollectonViewAndSearchBarFrame:count];
    [self.selectedUsersCollectionView reloadData];
    for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
        RCDContactSelectedTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        NSString *name = user.displayName.length > 0 ? user.displayName : user.name;
        if ([cell.nicknameLabel.text isEqualToString:name]) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil]
                                      withRowAnimation:UITableViewRowAnimationNone];
            });
        }
    }
    if (self.isAllowsMultipleSelection) {
        [self setRightButton];
    }
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    NSUInteger finalRow = MAX(0, [self.selectedUsersCollectionView numberOfItemsInSection:0] - 1);

    if (0 == finalRow) {
        return;
    }

    NSIndexPath *finalIndexPath = [NSIndexPath indexPathForItem:finalRow inSection:0];
    [self.selectedUsersCollectionView scrollToItemAtIndexPath:finalIndexPath
                                             atScrollPosition:UICollectionViewScrollPositionRight
                                                     animated:animated];
}

#pragma mark - UISearchBarDelegate
/**
 *  执行delegate联系人
 *
 *  @param searchBar  searchBar description
 *  @param searchText searchText description
 */
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.matchSearchList removeAllObjects];
    if ([searchText isEqualToString:@""]) {
        self.isSearchResult = NO;
        [self.tableView reloadData];
        return;
    } else {
        for (RCDFriendInfo *userInfo in [self.friendArray copy]) {
            //忽略大小写去判断是否包含
            NSString *name = userInfo.name;
            if ([userInfo isMemberOfClass:[RCDFriendInfo class]] && userInfo.displayName.length > 0) {
                name = userInfo.displayName;
            }

            RCDGroupMember *member;
            if (self.groupId.length > 0) {
                member = [RCDGroupManager getGroupMember:userInfo.userId groupId:self.groupId];
            }

            if ([name rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound ||
                [[RCDUtilities hanZiToPinYinWithString:name] rangeOfString:searchText options:NSCaseInsensitiveSearch]
                        .location != NSNotFound ||
                [member.groupNickname containsString:searchText]) {
                [self.matchSearchList addObject:userInfo];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isSearchResult = YES;
            [self.tableView reloadData];
        });
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if ([self.searchField.text isEqualToString:RCDLocalizedString(@"search")] ||
        [self.searchField.text isEqualToString:@"Search"]) {
        self.searchField.leftView = nil;
        self.searchField.text = @"";
    }
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    if (self.collectionViewResource.count > 0) {
        self.searchField.leftView = nil;
    }
    return YES;
}
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    if ([text isEqualToString:@""] && self.searchContent.length > 1) {
        self.searchContent = [self.searchContent substringWithRange:NSMakeRange(0, self.searchContent.length - 1)];
    } else if ([text isEqualToString:@""] && self.searchContent.length == 1) {
        self.searchContent = @"";
        self.isSearchResult = NO;
        [self.tableView reloadData];
        return YES;
    } else if ([text isEqualToString:@"\n"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchBar resignFirstResponder];
        });
        return YES;
    } else {
        self.searchContent = [NSString stringWithFormat:@"%@%@", self.searchContent, text];
    }
    [self.matchSearchList removeAllObjects];
    NSString *temp = [self.searchContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (temp.length <= 0) {
        self.matchSearchList = [self.friendArray mutableCopy];
    } else {
        for (RCDFriendInfo *userInfo in [self.friendArray copy]) {
            NSString *name = userInfo.name;
            if ([userInfo isMemberOfClass:[RCDFriendInfo class]] && userInfo.displayName.length > 0) {
                name = userInfo.displayName;
            }
            //忽略大小写去判断是否包含
            if ([name rangeOfString:temp options:NSCaseInsensitiveSearch].location != NSNotFound ||
                [[RCDUtilities hanZiToPinYinWithString:name] rangeOfString:temp options:NSCaseInsensitiveSearch]
                        .location != NSNotFound) {
                [self.matchSearchList addObject:userInfo];
            }
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isSearchResult = YES;
        [self.tableView reloadData];
    });
    return YES;
}

#pragma mark - Setter && Getter
- (RCDUIBarButtonItem *)rightBtn {
    if (!_rightBtn) {
        _rightBtn = [[RCDUIBarButtonItem alloc] initWithbuttonTitle:RCDLocalizedString(@"confirm")
                                                         titleColor:[UIColor colorWithHexString:@"000000" alpha:1.0]
                                                        buttonFrame:CGRectMake(0, 0, 90, 30)
                                                             target:self
                                                             action:@selector(clickedDone:)];
        _rightBtn.button.titleLabel.font = [UIFont systemFontOfSize:16];
        [_rightBtn.button setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, -10)];
        [_rightBtn buttonIsCanClick:NO
                        buttonColor:[RCDUtilities generateDynamicColor:HEXCOLOR(0x9fcdfd)
                                                             darkColor:[HEXCOLOR(0xA8A8A8) colorWithAlphaComponent:0.4]]
                      barButtonItem:_rightBtn];
    }
    return _rightBtn;
}

- (RCDTableView *)tableView {
    if (!_tableView) {
        _tableView = [[RCDTableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.frame =
            CGRectMake(0, 54, RCDScreenWidth, RCDScreenHeight - 64 - 54 - RCDExtraTopHeight - RCDExtraBottomHeight);
        if ([_tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
            _tableView.cellLayoutMarginsFollowReadableWidth = NO;
        }
        UIView *separatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, RCDScreenWidth, 1)];
        separatorLine.backgroundColor = [RCKitUtility
            generateDynamicColor:[UIColor colorWithRed:230 / 255.0 green:230 / 255.0 blue:230 / 255.0 alpha:1]
                       darkColor:HEXCOLOR(0x1a1a1a)];
        _tableView.tableHeaderView = separatorLine;
        _tableView.allowsMultipleSelection = _isAllowsMultipleSelection;
    }
    return _tableView;
}

- (UICollectionView *)selectedUsersCollectionView {
    if (!_selectedUsersCollectionView) {
        CGRect tempRect = CGRectMake(0, 0, 0, 54);
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _selectedUsersCollectionView =
            [[UICollectionView alloc] initWithFrame:tempRect collectionViewLayout:flowLayout];
        _selectedUsersCollectionView.delegate = self;
        _selectedUsersCollectionView.dataSource = self;
        _selectedUsersCollectionView.scrollEnabled = YES;
        _selectedUsersCollectionView.backgroundColor = RCDDYCOLOR(0xffffff, 0x000000);
        [_selectedUsersCollectionView registerClass:[RCDContactSelectedCollectionViewCell class]
                         forCellWithReuseIdentifier:@"RCDContactSelectedCollectionViewCell"];
        _selectedUsersCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _selectedUsersCollectionView;
}

- (RCDSearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[RCDSearchBar alloc] initWithFrame:CGRectMake(0, 0, RCDScreenWidth, 54)];
        _searchBar.placeholder = NSLocalizedStringFromTable(@"ToSearch", @"RongCloudKit", nil);
        [_searchBar setDelegate:self];
        [_searchBar setKeyboardType:UIKeyboardTypeDefault];
    }
    return _searchBar;
}

- (RCDNoFriendView *)noFriendView {
    if (!_noFriendView) {
        _noFriendView = [[RCDNoFriendView alloc] initWithFrame:CGRectMake(0, 0, RCDScreenWidth, RCDScreenHeight - 64)];
        _noFriendView.displayLabel.text = RCDLocalizedString(@"no_friend");
    }
    return _noFriendView;
}
@end
