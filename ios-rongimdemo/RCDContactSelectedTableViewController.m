//
//  RCDContactSelectedTableViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/3/17.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDContactSelectedTableViewController.h"
#import "DefaultPortraitView.h"
#import "MBProgressHUD.h"
#import "RCDChatViewController.h"
#import "RCDCommonDefine.h"
#import "RCDContactSelectedCollectionViewCell.h"
#import "RCDContactSelectedTableViewCell.h"
#import "RCDCreateGroupViewController.h"
#import "RCDHttpTool.h"
#import "RCDNoFriendView.h"
#import "RCDRCIMDataSource.h"
#import "RCDUIBarButtonItem.h"
#import "RCDUserInfo.h"
#import "RCDUserInfoManager.h"
#import "RCDUtilities.h"
#import "RCDataBaseManager.h"
#import "UIColor+RCColor.h"
#import "UIImageView+WebCache.h"
#import "pinyin.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width

@interface RCDContactSelectedTableViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate,
                                                     UITextFieldDelegate>
@property(nonatomic, strong) NSMutableArray *friends;

@property(strong, nonatomic) NSMutableArray *friendsArr;

@property(nonatomic, strong) NSMutableArray *tempOtherArr;

@property(nonatomic, strong) RCDUIBarButtonItem *rightBtn;

@property(nonatomic, strong) NSIndexPath *selectIndexPath;

@property(nonatomic, strong) NSMutableArray *discussionGroupMemberIdList;

@property(nonatomic, strong) RCDNoFriendView *noFriendView;

@property(nonatomic, strong) UICollectionView *selectedUsersCollectionView;

@property(nonatomic, strong) NSMutableArray *collectionViewResource;

@property(nonatomic, strong) UITableView *tableView;

//进入页面以后选中的userId的集合
@property(nonatomic, strong) NSMutableArray *selecteUserIdList;

// collectionView展示的最大数量
@property(nonatomic, assign) NSInteger maxCount;

//判断当前操作是否是删除操作
@property(nonatomic, assign) BOOL isDeleteUser;

//搜索出的结果数据集合
@property(nonatomic, strong) NSMutableArray *matchSearchList;

//是否是显示搜索的结果
@property(nonatomic, assign) BOOL isSearchResult;

// tableView中indexPath和userId的对应关系字典
@property(nonatomic, strong) NSMutableDictionary *indexPathDic;

@property(nonatomic, strong) UITextField *searchField;

@property(nonatomic, strong) UIView *searchBarLeftView;

@property(nonatomic, strong) NSString *searchContent;

@end

@implementation RCDContactSelectedTableViewController
MBProgressHUD *hud;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = _titleStr;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    self.isDeleteUser = NO;

    self.view.backgroundColor = [UIColor whiteColor];

    [self createTableView];

    [self createCollectionView];

    [self createSearchBar];
    self.matchSearchList = [NSMutableArray new];

    //自定义rightBarButtonItem
    self.rightBtn = [[RCDUIBarButtonItem alloc] initWithbuttonTitle:@"确定"
                                                         titleColor:[UIColor colorWithHexString:@"000000" alpha:1.0]
                                                        buttonFrame:CGRectMake(0, 0, 90, 30)
                                                             target:self
                                                             action:@selector(clickedDone:)];
    self.rightBtn.button.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.rightBtn.button setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, -10)];
    [self.rightBtn buttonIsCanClick:NO
                        buttonColor:[UIColor colorWithHexString:@"9fcdfd" alpha:1.0]
                      barButtonItem:self.rightBtn];
    self.navigationItem.rightBarButtonItems = [self.rightBtn setTranslation:self.rightBtn translation:-11];
    //当是讨论组加人的情况，先生成讨论组用户的ID列表
    if (_addDiscussionGroupMembers.count > 0) {
        self.discussionGroupMemberIdList = [NSMutableArray new];
        for (RCUserInfo *memberInfo in _addDiscussionGroupMembers) {
            [self.discussionGroupMemberIdList addObject:memberInfo.userId];
        }
    }

    self.selecteUserIdList = [NSMutableArray new];
    self.indexPathDic = [NSMutableDictionary new];

    [self setMaxCountForDevice];

    self.searchContent = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([_allFriends count] <= 0) {
        [self getAllData];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.rightBtn buttonIsCanClick:YES buttonColor:[UIColor whiteColor] barButtonItem:self.rightBtn];
    [hud hide:YES];
}

- (void)createTableView {
    self.tableView = [UITableView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.frame =
        CGRectMake(0, 54, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64 - 54 - RCDExtraTopHeight - RCDExtraBottomHeight);
    [self.view addSubview:self.tableView];

    //控制多选
    self.tableView.allowsMultipleSelection = YES;
    if (_isAllowsMultipleSelection == NO) {
        self.tableView.allowsMultipleSelection = NO;
    }

    UIView *separatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
    separatorLine.backgroundColor = [UIColor colorWithRed:230 / 255.0 green:230 / 255.0 blue:230 / 255.0 alpha:1];
    self.tableView.tableHeaderView = separatorLine;

    self.tableView.tableFooterView = [UIView new];
}

- (void)createCollectionView {
    self.collectionViewResource = [NSMutableArray new];
    CGRect tempRect = CGRectMake(0, 0, 0, 54);
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.selectedUsersCollectionView =
        [[UICollectionView alloc] initWithFrame:tempRect collectionViewLayout:flowLayout];
    self.selectedUsersCollectionView.delegate = self;
    self.selectedUsersCollectionView.dataSource = self;
    self.selectedUsersCollectionView.scrollEnabled = YES;
    self.selectedUsersCollectionView.backgroundColor = [UIColor whiteColor];
    [self.selectedUsersCollectionView registerClass:[RCDContactSelectedCollectionViewCell class]
                         forCellWithReuseIdentifier:@"RCDContactSelectedCollectionViewCell"];
    [self.view addSubview:self.selectedUsersCollectionView];
    self.selectedUsersCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)createSearchBar {
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 54)];
    [self.searchBar setText:NSLocalizedStringFromTable(@"ToSearch", @"RongCloudKit", nil)];
    self.searchField = [self.searchBar valueForKey:@"_searchField"];
    self.searchField.clearButtonMode = UITextFieldViewModeNever;
    self.searchField.textColor = [UIColor colorWithHexString:@"999999" alpha:1.0];
    self.searchBarLeftView = self.searchField.leftView;

    [self.searchBar setDelegate:self];
    [self.searchBar setKeyboardType:UIKeyboardTypeDefault];

    for (UIView *subview in [[self.searchBar.subviews firstObject] subviews]) {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [subview removeFromSuperview];
        }
    }
    [self.view addSubview:self.searchBar];
}

- (UIImage *)GetImageWithColor:(UIColor *)color andHeight:(CGFloat)height {
    CGRect r = CGRectMake(0.0f, 0.0f, 1.0f, height);
    UIGraphicsBeginImageContext(r.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, r);

    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return img;
}

- (CGRect)getSearchBarFrame:(CGRect)frame {
    CGRect searchBarFrame = CGRectZero;
    frame.origin.x = frame.size.width;
    CGFloat searchBarWidth = [UIScreen mainScreen].bounds.size.width - frame.size.width;
    frame.size.width = searchBarWidth;
    searchBarFrame = frame;
    return searchBarFrame;
}

//设置collectionView和searchBar实时显示的frame效果
- (void)setCollectonViewAndSearchBarFrame:(NSInteger)count {
    CGRect frame = CGRectZero;
    if (count == 0) {
        //只显示searchBar
        frame = CGRectMake(0, 0, 0, 54);
        self.selectedUsersCollectionView.frame = frame;
        self.searchBar.frame = [self getSearchBarFrame:frame];
        self.searchField.leftView = self.searchBarLeftView;
        self.searchBar.text = @"搜索";
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
        } else if (self.isDeleteUser == YES) {
            if (count < self.maxCount) {
                //判断如果当前collectionView的显示数量小于最大展示数量的时候，collectionView和searchBar的frame都会改变
                frame = CGRectMake(0, 0, 61 + (count - 1) * 46, 54);
                self.selectedUsersCollectionView.frame = frame;
                self.searchBar.frame = [self getSearchBarFrame:frame];
            }
        }
    }
}

// clicked done
- (void)clickedDone:(id)sender {
    [self.rightBtn buttonIsCanClick:NO
                        buttonColor:[UIColor colorWithHexString:@"9fcdfd" alpha:1.0]
                      barButtonItem:self.rightBtn];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.color = [UIColor colorWithHexString:@"343637" alpha:0.5];
    //    hud.labelText = @"";
    [hud show:YES];

    if (self.isAllowsMultipleSelection == NO) {
        RCUserInfo *user = [[RCDataBaseManager shareInstance] getUserByUserId:self.selecteUserIdList[0]];
        RCDChatViewController *chat = [[RCDChatViewController alloc] init];
        chat.targetId = user.userId;
        chat.userName = user.name;
        chat.conversationType = ConversationType_PRIVATE;
        chat.title = user.name;
        chat.needPopToRootView = YES;
        chat.displayUserNameInCell = NO;
        //跳转到会话页面
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:chat animated:YES];
        });
    } else {
        // get seleted users
        NSMutableArray *seletedUsers = [NSMutableArray new];
        NSMutableArray *seletedUsersId = [NSMutableArray new];
        for (RCUserInfo *user in self.collectionViewResource) {
            [seletedUsersId addObject:user.userId];
        }
        seletedUsers = [self.collectionViewResource mutableCopy];
        if (_selectUserList) {
            NSArray<RCUserInfo *> *userList = [NSArray arrayWithArray:seletedUsers];
            _selectUserList(userList);
            return;
        }

        if (_addGroupMembers.count > 0) {
            [RCDHTTPTOOL addUsersIntoGroup:_groupId
                                   usersId:seletedUsersId
                                  complete:^(BOOL result) {
                                      if (result == YES) {
                                          [self.navigationController popViewControllerAnimated:YES];
                                      } else {
                                          [hud hide:YES];
                                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"添加成员失败"
                                                                                          message:nil
                                                                                         delegate:self
                                                                                cancelButtonTitle:@"确定"
                                                                                otherButtonTitles:nil, nil];
                                          [alert show];
                                          [self.rightBtn buttonIsCanClick:YES
                                                              buttonColor:[UIColor whiteColor]
                                                            barButtonItem:self.rightBtn];
                                      }
                                  }];
            return;
        }
        if (_delGroupMembers.count > 0) {
            [RCDHTTPTOOL kickUsersOutOfGroup:_groupId
                                     usersId:seletedUsersId
                                    complete:^(BOOL result) {
                                        if (result == YES) {
                                            [self.navigationController popViewControllerAnimated:YES];
                                        } else {
                                            [hud hide:YES];
                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"删除成员失败"
                                                                                            message:nil
                                                                                           delegate:self
                                                                                  cancelButtonTitle:@"确定"
                                                                                  otherButtonTitles:nil, nil];
                                            [alert show];
                                            [self.rightBtn buttonIsCanClick:YES
                                                                buttonColor:[UIColor whiteColor]
                                                              barButtonItem:self.rightBtn];
                                        }
                                    }];
            return;
        }
        if (_addDiscussionGroupMembers.count > 0) {
            if (_discussiongroupId.length > 0) {
                [[RCIMClient sharedRCIMClient]
                    addMemberToDiscussion:_discussiongroupId
                               userIdList:seletedUsersId
                                  success:^(RCDiscussion *discussion) {
                                      NSLog(@"成功");
                                      [[NSNotificationCenter defaultCenter]
                                          postNotificationName:@"addDiscussiongroupMember"
                                                        object:seletedUsers];
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [self.navigationController popViewControllerAnimated:YES];
                                      });
                                  }
                                    error:^(RCErrorCode status){
                                    }];
                return;
            } else {
                NSMutableString *discussionTitle = [NSMutableString string];
                NSMutableArray *userIdList = [NSMutableArray new];
                RCUserInfo *member = _addDiscussionGroupMembers[0];
                [seletedUsers addObject:member];
                for (RCUserInfo *user in seletedUsers) {
                    [discussionTitle appendString:[NSString stringWithFormat:@"%@%@", user.name, @","]];
                    [userIdList addObject:user.userId];
                }
                [discussionTitle deleteCharactersInRange:NSMakeRange(discussionTitle.length - 1, 1)];

                [[RCIMClient sharedRCIMClient] createDiscussion:discussionTitle
                    userIdList:userIdList
                    success:^(RCDiscussion *discussion) {
                        NSLog(@"create discussion succeed!");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            RCDChatViewController *chat = [[RCDChatViewController alloc] init];
                            chat.targetId = discussion.discussionId;
                            chat.userName = discussion.discussionName;
                            chat.conversationType = ConversationType_DISCUSSION;
                            chat.title = @"讨论组";
                            chat.needPopToRootView = YES;
                            [self.navigationController pushViewController:chat animated:YES];
                        });
                    }
                    error:^(RCErrorCode status) {
                        NSLog(@"create discussion Failed > %ld!", (long)status);
                    }];
                return;
            }
        }
        if (self.forCreatingGroup) {
            RCDCreateGroupViewController *createGroupVC = [RCDCreateGroupViewController createGroupViewController];
            createGroupVC.GroupMemberIdList = seletedUsersId;
            [self.navigationController pushViewController:createGroupVC animated:YES];
            return;
        }
        //    if (self.forCreatingDiscussionGroup) {
        if (seletedUsers.count == 1) {
            RCUserInfo *user = seletedUsers[0];
            RCDChatViewController *chat = [[RCDChatViewController alloc] init];
            chat.targetId = user.userId;
            chat.userName = user.name;
            chat.conversationType = ConversationType_PRIVATE;
            chat.title = user.name;
            chat.needPopToRootView = YES;
            chat.displayUserNameInCell = NO;

            //跳转到会话页面
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController pushViewController:chat animated:YES];
            });
            return;
        }
        if (self.forCreatingDiscussionGroup) {
            NSMutableString *discussionTitle = [NSMutableString string];
            NSMutableArray *userIdList = [NSMutableArray new];
            for (RCUserInfo *user in seletedUsers) {
                [discussionTitle appendString:[NSString stringWithFormat:@"%@%@", user.name, @","]];
                [userIdList addObject:user.userId];
            }
            [discussionTitle deleteCharactersInRange:NSMakeRange(discussionTitle.length - 1, 1)];

            [[RCIMClient sharedRCIMClient] createDiscussion:discussionTitle
                userIdList:userIdList
                success:^(RCDiscussion *discussion) {
                    NSLog(@"create discussion ssucceed!");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        RCDChatViewController *chat = [[RCDChatViewController alloc] init];
                        chat.targetId = discussion.discussionId;
                        chat.userName = discussion.discussionName;
                        chat.conversationType = ConversationType_DISCUSSION;
                        chat.title = @"讨论组";
                        chat.needPopToRootView = YES;
                        [self.navigationController pushViewController:chat animated:YES];
                    });
                }
                error:^(RCErrorCode status) {
                    NSLog(@"create discussion Failed > %ld!", (long)status);
                }];
            return;
        }
    }
}

- (void)setDefaultDisplay {
    self.isSearchResult = NO;
    [self.tableView reloadData];
    if (self.collectionViewResource.count < 1) {
        self.searchField.leftView = self.searchBarLeftView;
    }
    self.searchBar.text = @"搜索";
    self.searchContent = @"";
    [self.searchBar resignFirstResponder];
}

- (void)setMaxCountForDevice {
    if (kScreenWidth < 375) {
        self.maxCount = 5;
    } else if (kScreenWidth >= 375 && kScreenWidth < 414) {
        self.maxCount = 6;
    } else {
        self.maxCount = 7;
    }
}

- (void)setRightButton {
    NSString *titleStr;
    if (self.selecteUserIdList.count > 0) {
        titleStr = [NSString stringWithFormat:@"确定(%zd)", [self.selecteUserIdList count]];
    } else {
        titleStr = @"确定";
        [self.rightBtn buttonIsCanClick:NO
                            buttonColor:[UIColor colorWithHexString:@"9fcdfd" alpha:1.0]
                          barButtonItem:self.rightBtn];
    }
    [self.rightBtn.button setTitle:titleStr forState:UIControlStateNormal];
}

- (void)closeKeyboard {
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
    if (self.collectionViewResource.count < 1) {
        self.searchField.leftView = self.searchBarLeftView;
    }
    if (self.searchContent.length < 1) {
        self.searchBar.text = @"搜索";
    }
    if (self.isSearchResult == YES) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setDefaultDisplay];
        });
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isSearchResult == NO) {
        return [_allKeys count];
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearchResult == NO) {
        NSString *key = [_allKeys objectAtIndex:section];
        NSArray *arr = [_allFriends objectForKey:key];
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
        return _allKeys;
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.isSearchResult == NO) {
        NSString *key = [_allKeys objectAtIndex:section];
        return key;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellReuseIdentifier = @"RCDContactSelectedTableViewCell";

    RCDContactSelectedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (!cell) {
        cell = [[RCDContactSelectedTableViewCell alloc] init];
    }

    [cell setUserInteractionEnabled:YES];
    [cell.nicknameLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
    RCDUserInfo *user;
    if (self.isSearchResult == NO) {
        NSString *key = [self.allKeys objectAtIndex:indexPath.section];
        NSArray *arrayForKey = [self.allFriends objectForKey:key];

        user = arrayForKey[indexPath.row];
    } else {
        if (self.matchSearchList.count > 0) {
            user = [self.matchSearchList objectAtIndex:indexPath.row];
        }
    }

    //给控件填充数据
    [cell setModel:user];
    //设置选中状态
    BOOL isSelected = NO;
    for (NSString *userId in self.selecteUserIdList) {
        if ([user.userId isEqualToString:userId]) {
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            isSelected = YES;
        }
    }
    if (isSelected == NO) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    if (_isHideSelectedIcon) {
        cell.selectedImageView.hidden = YES;
    }
    if ([self isContain:user.userId] == YES) {
        [cell setUserInteractionEnabled:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.selectedImageView.image = [UIImage imageNamed:@"disable_select"];
        });
        cell.userInteractionEnabled = NO;
    }
    return cell;
}

// override delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.rightBtn buttonIsCanClick:YES buttonColor:[UIColor whiteColor] barButtonItem:self.rightBtn];
    RCDContactSelectedTableViewCell *cell =
        (RCDContactSelectedTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (self.isAllowsMultipleSelection == NO) {
        if (self.isSearchResult == YES) {
            RCUserInfo *user = [self.matchSearchList objectAtIndex:indexPath.row];
            if (self.selecteUserIdList.count > 0) {
                if ([self.selecteUserIdList[0] isEqualToString:user.userId]) {
                    [self.selecteUserIdList removeAllObjects];
                } else {
                    [self.selecteUserIdList removeAllObjects];
                    [self.selecteUserIdList addObject:user.userId];
                }
            } else {
                [self.selecteUserIdList addObject:user.userId];
            }
        } else {
            NSString *key = [self.allKeys objectAtIndex:indexPath.section];
            NSArray *arrayForKey = [self.allFriends objectForKey:key];
            RCUserInfo *user = arrayForKey[indexPath.row];
            if (self.selecteUserIdList.count > 0) {
                if ([self.selecteUserIdList[0] isEqualToString:user.userId]) {
                    [self.selecteUserIdList removeAllObjects];
                } else {
                    [self.selecteUserIdList removeAllObjects];
                    [self.selecteUserIdList addObject:user.userId];
                }
            } else {
                [self.selecteUserIdList addObject:user.userId];
            }
        }
        [self setRightButton];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } else {
        [cell setSelected:YES];
        //  if (self.selectIndexPath && self.selectIndexPath.row == indexPath.row) {
        if (self.selectIndexPath && [self.selectIndexPath compare:indexPath] == NSOrderedSame) {
            [cell setSelected:NO];
            self.selectIndexPath = nil;
        } else {
            RCUserInfo *user;
            if (self.isSearchResult == YES) {
                user = [self.matchSearchList objectAtIndex:indexPath.row];
            } else {
                self.selectIndexPath = indexPath;
                NSString *key = [self.allKeys objectAtIndex:indexPath.section];
                NSArray *arrayForKey = [self.allFriends objectForKey:key];
                user = arrayForKey[indexPath.row];
            }
            [self.collectionViewResource addObject:user];
            NSInteger count = self.collectionViewResource.count;
            self.isDeleteUser = NO;
            [self setCollectonViewAndSearchBarFrame:count];
            [self.selectedUsersCollectionView reloadData];
            [self scrollToBottomAnimated:YES];
            [self.selecteUserIdList addObject:user.userId];
            [self setRightButton];
        }
        if (_selectUserList && self.isHideSelectedIcon) {
            NSMutableArray *seletedUsers = [NSMutableArray new];
            NSString *key = [self.allKeys objectAtIndex:indexPath.section];
            NSArray *arrayForKey = [self.allFriends objectForKey:key];
            RCDUserInfo *user = arrayForKey[indexPath.row];
            //转成RCDUserInfo
            RCUserInfo *userInfo = [RCUserInfo new];
            userInfo.userId = user.userId;
            userInfo.name = user.name;
            userInfo.portraitUri = user.portraitUri;
            [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:userInfo.userId];
            [seletedUsers addObject:userInfo];
            [self setRightButton];
            NSArray<RCUserInfo *> *userList = [NSArray arrayWithArray:seletedUsers];
            _selectUserList(userList);
            return;
        }
        if (self.isSearchResult == YES) {
            [self setDefaultDisplay];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDContactSelectedTableViewCell *cell =
        (RCDContactSelectedTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (self.isAllowsMultipleSelection == NO) {

    } else {
        if (self.isSearchResult == YES) {
            [self setDefaultDisplay];
            return;
        }
        [cell setSelected:NO];
        self.selectIndexPath = nil;
        NSString *key = [self.allKeys objectAtIndex:indexPath.section];
        NSArray *arrayForKey = [self.allFriends objectForKey:key];
        RCDUserInfo *user = arrayForKey[indexPath.row];
        [self.collectionViewResource removeObject:user];
        [self.selecteUserIdList removeObject:user.userId];
        [self.selectedUsersCollectionView reloadData];
        NSInteger count = self.collectionViewResource.count;
        self.isDeleteUser = YES;
        [self setCollectonViewAndSearchBarFrame:count];
        if (self.isAllowsMultipleSelection) {
            [self setRightButton];
        }
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

#pragma mark - 获取好友并且排序
/**
 *  initial data
 */
- (void)getAllData {

    _allFriends = [NSMutableDictionary new];
    _allKeys = [NSMutableArray new];
    _friendsArr = [NSMutableArray new];
    _friends = [NSMutableArray arrayWithArray:[[RCDataBaseManager shareInstance] getAllFriends]];
    if (_friends == nil || _friends.count < 1) {
        [RCDDataSource syncFriendList:[RCIM sharedRCIM].currentUserInfo.userId
                             complete:^(NSMutableArray *result) {
                                 if (result.count > 0) {
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         if (self.noFriendView != nil) {
                                             [self.noFriendView removeFromSuperview];
                                         }
                                     });
                                     _friends = result;
                                     [self dealWithFriendList];
                                 } else {
                                     _friends = nil;
                                     [self dealWithFriendList];
                                 }
                             }];
    } else {
        [self dealWithFriendList];
    }
}

- (void)dealWithFriendList {
    for (int i = 0; i < _friends.count; i++) {
        RCDUserInfo *user = _friends[i];
        if ([user.status isEqualToString:@"20"]) {
            RCUserInfo *friend = [[RCDUserInfoManager shareInstance] getFriendInfoFromDB:user.userId];
            if (friend == nil) {
                friend = [[RCDUserInfoManager shareInstance] generateDefaultUserInfo:user.userId];
            }
            [_friendsArr addObject:friend];
        }
    }
    if (_friendsArr.count < 1) {
        CGRect frame = CGRectMake(0, 0, RCDscreenWidth, RCDscreenHeight - 64);
        self.noFriendView = [[RCDNoFriendView alloc] initWithFrame:frame];
        self.noFriendView.displayLabel.text = @"暂无好友";
        [self.view addSubview:self.noFriendView];
        [self.view bringSubviewToFront:self.noFriendView];
    } else {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self deleteGroupMembers];
            NSMutableDictionary *resultDic = [RCDUtilities sortedArrayWithPinYinDic:_friendsArr];
            dispatch_async(dispatch_get_main_queue(), ^{
                _allFriends = resultDic[@"infoDic"];
                _allKeys = resultDic[@"allKeys"];
                [self.tableView reloadData];
            });
        });
    }
}

- (void)deleteGroupMembers {
    if (_delGroupMembers.count > 0) {
        _friendsArr = _delGroupMembers;
    }
}

- (BOOL)isContain:(NSString *)userId {
    BOOL contain = NO;
    NSArray *userList;
    if (_addGroupMembers.count > 0) {
        userList = _addGroupMembers;
    }
    if (_addDiscussionGroupMembers.count > 0) {
        userList = self.discussionGroupMemberIdList;
    }
    for (NSString *memberId in userList) {
        if ([userId isEqualToString:memberId]) {
            contain = YES;
            break;
        }
    }
    return contain;
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
        RCUserInfo *user = self.collectionViewResource[indexPath.row];
        [cell setUserModel:user];
    }
    cell.ivAva.contentMode = UIViewContentModeScaleAspectFill;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self closeKeyboard];
    RCUserInfo *user = [self.collectionViewResource objectAtIndex:indexPath.row];
    [self.collectionViewResource removeObjectAtIndex:indexPath.row];
    [self.selecteUserIdList removeObject:user.userId];
    NSInteger count = self.collectionViewResource.count;
    self.isDeleteUser = YES;
    [self setCollectonViewAndSearchBarFrame:count];
    [self.selectedUsersCollectionView reloadData];
    for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
        RCDContactSelectedTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if ([cell.nicknameLabel.text isEqualToString:user.name]) {
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
        for (RCUserInfo *userInfo in [_friendsArr copy]) {
            //忽略大小写去判断是否包含
            if ([userInfo.name rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound ||
                [[RCDUtilities hanZiToPinYinWithString:userInfo.name] rangeOfString:searchText
                                                                            options:NSCaseInsensitiveSearch]
                        .location != NSNotFound) {
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
    if ([self.searchField.text isEqualToString:@"搜索"] || [self.searchField.text isEqualToString:@"Search"]) {
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
    ;
    if (temp.length <= 0) {
        self.matchSearchList = [_friendsArr mutableCopy];
    } else {
        for (RCUserInfo *userInfo in [_friendsArr copy]) {
            //忽略大小写去判断是否包含
            if ([userInfo.name rangeOfString:temp options:NSCaseInsensitiveSearch].location != NSNotFound ||
                [[RCDUtilities hanZiToPinYinWithString:userInfo.name] rangeOfString:temp
                                                                            options:NSCaseInsensitiveSearch]
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

@end
