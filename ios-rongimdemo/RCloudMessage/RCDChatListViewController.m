//
//  FirstViewController.m
//  RongCloud
//
//  Created by Liv on 14/10/31.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCDChatListViewController.h"
#import "KxMenu.h"
#import "RCDAddressBookViewController.h"
#import "RCDChatListCell.h"
#import "RCDChatViewController.h"
#import "RCDCommonDefine.h"
#import "RCDContactSelectedTableViewController.h"
#import "RCDHttpTool.h"
#import "RCDPublicServiceListViewController.h"
#import "RCDSearchBar.h"
#import "RCDSearchViewController.h"
#import "RCDUIBarButtonItem.h"
#import "UIColor+RCColor.h"
#import "UIImageView+WebCache.h"
#import "UITabBar+badge.h"
#import "RCDSearchFriendController.h"
@interface RCDChatListViewController () <UISearchBarDelegate, RCDSearchViewDelegate>
@property(nonatomic, strong) UINavigationController *searchNavigationController;
@property(nonatomic, strong) UIView *headerView;
@property(nonatomic, strong) RCDSearchBar *searchBar;
//@property (nonatomic,strong) NSMutableArray *myDataSource;
@property(nonatomic, strong) RCConversationModel *tempModel;

@property(nonatomic, assign) NSUInteger index;

@property(nonatomic, assign) BOOL isClick;
- (void)updateBadgeValueForTabBarItem;

@end

@implementation RCDChatListViewController
- (RCDSearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar =
            [[RCDSearchBar alloc] initWithFrame:CGRectMake(0, 0, self.conversationListTableView.frame.size.width, 44)];
    }
    return _searchBar;
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView =
            [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.conversationListTableView.frame.size.width, 44)];
    }
    return _headerView;
}

/**
 *  此处使用storyboard初始化，代码初始化当前类时*****必须要设置会话类型和聚合类型*****
 *
 *  @param aDecoder aDecoder description
 *
 *  @return return value description
 */
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        //设置要显示的会话类型
        [self setDisplayConversationTypes:@[
            @(ConversationType_PRIVATE), @(ConversationType_DISCUSSION), @(ConversationType_APPSERVICE),
            @(ConversationType_PUBLICSERVICE), @(ConversationType_GROUP), @(ConversationType_SYSTEM)
        ]];

        //聚合会话类型
        [self setCollectionConversationType:@[ @(ConversationType_SYSTEM) ]];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        //设置要显示的会话类型
        [self setDisplayConversationTypes:@[
            @(ConversationType_PRIVATE), @(ConversationType_DISCUSSION), @(ConversationType_APPSERVICE),
            @(ConversationType_PUBLICSERVICE), @(ConversationType_GROUP), @(ConversationType_SYSTEM)
        ]];

        //聚合会话类型
        [self setCollectionConversationType:@[ @(ConversationType_SYSTEM) ]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.translucent = NO;
    self.searchBar.delegate = self;
    [self.headerView addSubview:self.searchBar];
    self.conversationListTableView.tableHeaderView = self.headerView;

    //设置tableView样式
    self.conversationListTableView.separatorColor = [UIColor colorWithHexString:@"dfdfdf" alpha:1.0f];
    self.conversationListTableView.tableFooterView = [UIView new];

    // 设置在NavigatorBar中显示连接中的提示
    self.showConnectingStatusOnNavigatorBar = YES;

    //修改tabbar的背景色
    UIView *tabBarBG = [UIView new];
    tabBarBG.backgroundColor = HEXCOLOR(0xf9f9f9);
    tabBarBG.frame = self.tabBarController.tabBar.bounds;
    [[UITabBar appearance] insertSubview:tabBarBG atIndex:0];

    [[UITabBarItem appearance]
        setTitleTextAttributes:[NSDictionary
                                   dictionaryWithObjectsAndKeys:HEXCOLOR(0x999999), UITextAttributeTextColor, nil]
                      forState:UIControlStateNormal];

    [[UITabBarItem appearance]
        setTitleTextAttributes:[NSDictionary
                                   dictionaryWithObjectsAndKeys:HEXCOLOR(0x0099ff), UITextAttributeTextColor, nil]
                      forState:UIControlStateSelected];

    //定位未读数会话
    self.index = 0;
    //接收定位到未读数会话的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(GotoNextCoversation)
                                                 name:@"GotoNextCoversation"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateForSharedMessageInsertSuccess)
                                                 name:@"RCDSharedMessageInsertSuccess"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshCell:)
                                                 name:@"RefreshConversationList"
                                               object:nil];

    [self checkVersion];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.searchBar.frame = CGRectMake(0, 0, self.conversationListTableView.frame.size.width, 44);
    [self updateBadgeValueForTabBarItem];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;

    _isClick = YES;
    //自定义rightBarButtonItem
    RCDUIBarButtonItem *rightBtn = [[RCDUIBarButtonItem alloc] initContainImage:[UIImage imageNamed:@"add"]
                                                                 imageViewFrame:CGRectMake(0, 0, 17, 17)
                                                                    buttonTitle:nil
                                                                     titleColor:nil
                                                                     titleFrame:CGRectZero
                                                                    buttonFrame:CGRectMake(0, 0, 17, 17)
                                                                         target:self
                                                                         action:@selector(showMenu:)];
    self.tabBarController.navigationItem.rightBarButtonItems = @[rightBtn];
    self.tabBarController.navigationItem.title = RCDLocalizedString(@"conversation");

    //  [self notifyUpdateUnreadMessageCount];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNeedRefreshNotification:)
                                                 name:@"kRCNeedReloadDiscussionListNotification"
                                               object:nil];
    RCUserInfo *groupNotify = [[RCUserInfo alloc] initWithUserId:@"__system__" name:@"" portrait:nil];
    [[RCIM sharedRCIM] refreshUserInfoCache:groupNotify withUserId:@"__system__"];
}

//由于demo使用了tabbarcontroller，当切换到其它tab时，不能更改tabbarcontroller的标题。
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"kRCNeedReloadDiscussionListNotification"
                                                  object:nil];
}

- (void)updateBadgeValueForTabBarItem {
    __weak typeof(self) __weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        int count = [[RCIMClient sharedRCIMClient] getUnreadCount:__weakSelf.displayConversationTypeArray];
        if (count > 0) {
            //      __weakSelf.tabBarItem.badgeValue =
            //          [[NSString alloc] initWithFormat:@"%d", count];
            [__weakSelf.tabBarController.tabBar showBadgeOnItemIndex:0 badgeValue:count];

        } else {
            //      __weakSelf.tabBarItem.badgeValue = nil;
            [__weakSelf.tabBarController.tabBar hideBadgeOnItemIndex:0];
        }

    });
}

/**
 *  点击进入会话页面
 *
 *  @param conversationModelType 会话类型
 *  @param model                 会话数据
 *  @param indexPath             indexPath description
 */
- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType
         conversationModel:(RCConversationModel *)model
               atIndexPath:(NSIndexPath *)indexPath {

    if (_isClick) {
        _isClick = NO;
        if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_PUBLIC_SERVICE) {
            RCDChatViewController *_conversationVC = [[RCDChatViewController alloc] init];
            _conversationVC.conversationType = model.conversationType;
            _conversationVC.targetId = model.targetId;
            _conversationVC.userName = model.conversationTitle;
            _conversationVC.title = model.conversationTitle;
            _conversationVC.conversation = model;
            [self.navigationController pushViewController:_conversationVC animated:YES];
        }

        if (conversationModelType == RC_CONVERSATION_MODEL_TYPE_NORMAL) {
            RCDChatViewController *_conversationVC = [[RCDChatViewController alloc] init];
            _conversationVC.conversationType = model.conversationType;
            _conversationVC.targetId = model.targetId;
            _conversationVC.userName = model.conversationTitle;
            _conversationVC.title = model.conversationTitle;
            _conversationVC.conversation = model;
            _conversationVC.unReadMessage = model.unreadMessageCount;
            _conversationVC.enableNewComingMessageIcon = YES; //开启消息提醒
            _conversationVC.enableUnreadMessageIcon = YES;
            if (model.conversationType == ConversationType_SYSTEM) {
                _conversationVC.userName = RCDLocalizedString(@"de_actionbar_sub_system");
                _conversationVC.title = RCDLocalizedString(@"de_actionbar_sub_system");
            }
            if ([model.objectName isEqualToString:@"RC:ContactNtf"]) {
                RCDAddressBookViewController *addressBookVC = [RCDAddressBookViewController addressBookViewController];
                addressBookVC.needSyncFriendList = YES;

                [self.navigationController pushViewController:addressBookVC animated:YES];
                return;
            }
            //如果是单聊，不显示发送方昵称
            if (model.conversationType == ConversationType_PRIVATE) {
                _conversationVC.displayUserNameInCell = NO;
            }
            [self.navigationController pushViewController:_conversationVC animated:YES];
        }

        //聚合会话类型，此处自定设置。
        if (conversationModelType == RC_CONVERSATION_MODEL_TYPE_COLLECTION) {

            RCDChatListViewController *temp = [[RCDChatListViewController alloc] init];
            NSArray *array = [NSArray arrayWithObject:[NSNumber numberWithInt:model.conversationType]];
            [temp setDisplayConversationTypes:array];
            [temp setCollectionConversationType:nil];
            temp.isEnteredToCollectionViewController = YES;
            [self.navigationController pushViewController:temp animated:YES];
        }

        //自定义会话类型
        if (conversationModelType == RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION) {
            RCConversationModel *model = self.conversationListDataSource[indexPath.row];

            if ([model.objectName isEqualToString:@"RC:ContactNtf"]) {
                RCDAddressBookViewController *addressBookVC = [RCDAddressBookViewController addressBookViewController];
                [self.navigationController pushViewController:addressBookVC animated:YES];
            }
        }
    }
}

/**
 *  弹出层
 *
 *  @param sender sender description
 */
- (void)showMenu:(UIButton *)sender {
    NSArray *menuItems = @[

        [KxMenuItem menuItem:RCDLocalizedString(@"start_chatting")
                       image:[UIImage imageNamed:@"startchat_icon"]
                      target:self
                      action:@selector(pushChat:)],

        [KxMenuItem menuItem:RCDLocalizedString(@"create_groups")
                       image:[UIImage imageNamed:@"creategroup_icon"]
                      target:self
                      action:@selector(pushContactSelected:)],

        [KxMenuItem menuItem:RCDLocalizedString(@"add_contacts")

                       image:[UIImage imageNamed:@"addfriend_icon"]
                      target:self
                      action:@selector(pushAddFriend:)],
#if RCDDebugTestFunction
        [KxMenuItem menuItem:RCDLocalizedString(@"create_discussion_group")
                       image:[UIImage imageNamed:@"addfriend_icon"]
                      target:self
                      action:@selector(pushToCreateDiscussion:)],
#endif
    ];

    UIBarButtonItem *rightBarButton = self.tabBarController.navigationItem.rightBarButtonItems[0];
    CGRect targetFrame = rightBarButton.customView.frame;
    CGFloat offset = [UIApplication sharedApplication].statusBarFrame.size.height > 20 ?  54 : 15;
    targetFrame.origin.y = targetFrame.origin.y + offset;
    if (IOS_FSystenVersion >= 11.0) {
        targetFrame.origin.x = self.view.bounds.size.width - targetFrame.size.width - 17;
    }
    [KxMenu setTintColor:HEXCOLOR(0x000000)];
    [KxMenu setTitleFont:[UIFont systemFontOfSize:17]];
    [KxMenu showMenuInView:self.tabBarController.navigationController.navigationBar.superview
                  fromRect:targetFrame
                 menuItems:menuItems];
}

/**
 *  发起聊天
 *
 *  @param sender sender description
 */
- (void)pushChat:(id)sender {
    RCDContactSelectedTableViewController *contactSelectedVC = [[RCDContactSelectedTableViewController alloc] init];
    //    contactSelectedVC.forCreatingDiscussionGroup = YES;
    contactSelectedVC.isAllowsMultipleSelection = NO;
    contactSelectedVC.titleStr = RCDLocalizedString(@"start_chatting");
    [self.navigationController pushViewController:contactSelectedVC animated:YES];
}

/**
 *  创建群组
 *
 *  @param sender sender description
 */
- (void)pushContactSelected:(id)sender {
    RCDContactSelectedTableViewController *contactSelectedVC = [[RCDContactSelectedTableViewController alloc] init];
    contactSelectedVC.forCreatingGroup = YES;
    contactSelectedVC.isAllowsMultipleSelection = YES;
    contactSelectedVC.titleStr = RCDLocalizedString(@"select_contact");
    [self.navigationController pushViewController:contactSelectedVC animated:YES];
}

/**
 *  公众号会话
 *
 *  @param sender sender description
 */
- (void)pushPublicService:(id)sender {
    RCDPublicServiceListViewController *publicServiceVC = [[RCDPublicServiceListViewController alloc] init];
    [self.navigationController pushViewController:publicServiceVC animated:YES];
}

/**
 *  添加好友
 *
 *  @param sender sender description
 */
- (void)pushAddFriend:(id)sender {
    RCDSearchFriendController *searchFirendVC = [[RCDSearchFriendController alloc] init];
    [self.navigationController pushViewController:searchFirendVC animated:YES];
}

/**
 *  通讯录
 *
 *  @param sender sender description
 */
- (void)pushAddressBook:(id)sender {
    RCDAddressBookViewController *addressBookVC = [RCDAddressBookViewController addressBookViewController];
    [self.navigationController pushViewController:addressBookVC animated:YES];
}

/**
 *  添加公众号
 *
 *  @param sender sender description
 */
- (void)pushAddPublicService:(id)sender {
    RCPublicServiceSearchViewController *searchFirendVC = [[RCPublicServiceSearchViewController alloc] init];
    [self.navigationController pushViewController:searchFirendVC animated:YES];
}

//*********************插入自定义Cell*********************//

//插入自定义会话model
- (NSMutableArray *)willReloadTableData:(NSMutableArray *)dataSource {

    for (int i = 0; i < dataSource.count; i++) {
        RCConversationModel *model = dataSource[i];
        //筛选请求添加好友的系统消息，用于生成自定义会话类型的cell
        if (model.conversationType == ConversationType_SYSTEM &&
            [model.lastestMessage isMemberOfClass:[RCContactNotificationMessage class]]) {
            model.conversationModelType = RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION;
        }
        if ([model.lastestMessage isKindOfClass:[RCGroupNotificationMessage class]]) {
            RCGroupNotificationMessage *groupNotification = (RCGroupNotificationMessage *)model.lastestMessage;
            if ([groupNotification.operation isEqualToString:@"Quit"]) {
                NSData *jsonData = [groupNotification.data dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *dictionary =
                    [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
                NSDictionary *data =
                    [dictionary[@"data"] isKindOfClass:[NSDictionary class]] ? dictionary[@"data"] : nil;
                NSString *nickName =
                    [data[@"operatorNickname"] isKindOfClass:[NSString class]] ? data[@"operatorNickname"] : nil;
                if ([nickName isEqualToString:[RCIM sharedRCIM].currentUserInfo.name]) {
                    [[RCIMClient sharedRCIMClient] removeConversation:model.conversationType targetId:model.targetId];
                    [self refreshConversationTableViewIfNeeded];
                }
            }
        }
    }

    return dataSource;
}

//左滑删除
- (void)rcConversationListTableView:(UITableView *)tableView
                 commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                  forRowAtIndexPath:(NSIndexPath *)indexPath {
    //可以从数据库删除数据
    RCConversationModel *model = self.conversationListDataSource[indexPath.row];
    [[RCIMClient sharedRCIMClient] removeConversation:ConversationType_SYSTEM targetId:model.targetId];
    [self.conversationListDataSource removeObjectAtIndex:indexPath.row];
    [self.conversationListTableView reloadData];
}

//高度
- (CGFloat)rcConversationListTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 67.0f;
}

//自定义cell
- (RCConversationBaseCell *)rcConversationListTableView:(UITableView *)tableView
                                  cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCConversationModel *model = self.conversationListDataSource[indexPath.row];

    __block NSString *userName = nil;
    __block NSString *portraitUri = nil;
    RCContactNotificationMessage *_contactNotificationMsg = nil;

    __weak RCDChatListViewController *weakSelf = self;
    //此处需要添加根据userid来获取用户信息的逻辑，extend字段不存在于DB中，当数据来自db时没有extend字段内容，只有userid
    if (nil == model.extend) {
        // Not finished yet, To Be Continue...
        if (model.conversationType == ConversationType_SYSTEM &&
            [model.lastestMessage isMemberOfClass:[RCContactNotificationMessage class]]) {
            _contactNotificationMsg = (RCContactNotificationMessage *)model.lastestMessage;
            if (_contactNotificationMsg.sourceUserId == nil) {
                RCDChatListCell *cell =
                    [[RCDChatListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
                cell.lblDetail.text = RCDLocalizedString(@"friend_request");
                [cell.ivAva sd_setImageWithURL:[NSURL URLWithString:portraitUri]
                              placeholderImage:[UIImage imageNamed:@"system_notice"]];
                return cell;
            }
            NSDictionary *_cache_userinfo =
                [[NSUserDefaults standardUserDefaults] objectForKey:_contactNotificationMsg.sourceUserId];
            if (_cache_userinfo) {
                userName = _cache_userinfo[@"username"];
                portraitUri = _cache_userinfo[@"portraitUri"];
            } else {
                NSDictionary *emptyDic = @{};
                [[NSUserDefaults standardUserDefaults] setObject:emptyDic forKey:_contactNotificationMsg.sourceUserId];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [RCDHTTPTOOL
                    getUserInfoByUserID:_contactNotificationMsg.sourceUserId
                             completion:^(RCUserInfo *user) {
                                 if (user == nil) {
                                     return;
                                 }
                                 RCDUserInfo *rcduserinfo_ = [RCDUserInfo new];
                                 rcduserinfo_.name = user.name;
                                 rcduserinfo_.userId = user.userId;
                                 rcduserinfo_.portraitUri = user.portraitUri;

                                 model.extend = rcduserinfo_;

                                 // local cache for userInfo
                                 NSDictionary *userinfoDic =
                                     @{@"username" : rcduserinfo_.name, @"portraitUri" : rcduserinfo_.portraitUri};
                                 [[NSUserDefaults standardUserDefaults] setObject:userinfoDic
                                                                           forKey:_contactNotificationMsg.sourceUserId];
                                 [[NSUserDefaults standardUserDefaults] synchronize];

                                 [weakSelf.conversationListTableView
                                     reloadRowsAtIndexPaths:@[ indexPath ]
                                           withRowAnimation:UITableViewRowAnimationAutomatic];
                             }];
            }
        }

    } else {
        RCDUserInfo *user = (RCDUserInfo *)model.extend;
        userName = user.name;
        portraitUri = user.portraitUri;
    }

    RCDChatListCell *cell = [[RCDChatListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    NSString *operation = _contactNotificationMsg.operation;
    NSString *operationContent;
    if ([operation isEqualToString:@"Request"]) {
        operationContent = [NSString stringWithFormat:RCDLocalizedString(@"from_someone_friend_request"), userName];
    } else if ([operation isEqualToString:@"AcceptResponse"]) {
        operationContent = [NSString stringWithFormat:RCDLocalizedString(@"someone_accept_you_friend_request"), userName];
    }
    cell.lblDetail.text = operationContent;
    [cell.ivAva sd_setImageWithURL:[NSURL URLWithString:portraitUri]
                  placeholderImage:[UIImage imageNamed:@"system_notice"]];
    cell.labelTime.text = [RCKitUtility ConvertMessageTime:model.sentTime / 1000];
    cell.model = model;
    return cell;
}

//*********************插入自定义Cell*********************//

#pragma mark - 收到消息监听
- (void)didReceiveMessageNotification:(NSNotification *)notification {
    __weak typeof(self) blockSelf_ = self;
    //处理好友请求
    RCMessage *message = notification.object;
    if ([message.content isMemberOfClass:[RCContactNotificationMessage class]]) {

        if (message.conversationType != ConversationType_SYSTEM) {
            NSLog(@"好友消息要发系统消息！！！");
#if DEBUG
            @throw [[NSException alloc] initWithName:@"error" reason:@"好友消息要发系统消息！！！" userInfo:nil];
#endif
        }
        RCContactNotificationMessage *_contactNotificationMsg = (RCContactNotificationMessage *)message.content;
        if (_contactNotificationMsg.sourceUserId == nil || _contactNotificationMsg.sourceUserId.length == 0) {
            return;
        }
        //该接口需要替换为从消息体获取好友请求的用户信息
        [RCDHTTPTOOL getUserInfoByUserID:_contactNotificationMsg.sourceUserId
                              completion:^(RCUserInfo *user) {
                                  RCDUserInfo *rcduserinfo_ = [RCDUserInfo new];
                                  rcduserinfo_.name = user.name;
                                  rcduserinfo_.userId = user.userId;
                                  rcduserinfo_.portraitUri = user.portraitUri;

                                  RCConversationModel *customModel = [RCConversationModel new];
                                  customModel.conversationModelType = RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION;
                                  customModel.extend = rcduserinfo_;
                                  customModel.conversationType = message.conversationType;
                                  customModel.targetId = message.targetId;
                                  customModel.sentTime = message.sentTime;
                                  customModel.receivedTime = message.receivedTime;
                                  customModel.senderUserId = message.senderUserId;
                                  customModel.lastestMessage = _contactNotificationMsg;
                                  //[_myDataSource insertObject:customModel atIndex:0];

                                  // local cache for userInfo
                                  NSDictionary *userinfoDic =
                                      @{@"username" : rcduserinfo_.name, @"portraitUri" : rcduserinfo_.portraitUri};
                                  [[NSUserDefaults standardUserDefaults]
                                      setObject:userinfoDic
                                         forKey:_contactNotificationMsg.sourceUserId];
                                  [[NSUserDefaults standardUserDefaults] synchronize];

                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      //调用父类刷新未读消息数
                                      [blockSelf_ refreshConversationTableViewWithConversationModel:customModel];
                                      [blockSelf_ notifyUpdateUnreadMessageCount];

                                      //当消息为RCContactNotificationMessage时，没有调用super，如果是最后一条消息，可能需要刷新一下整个列表。
                                      //原因请查看super didReceiveMessageNotification的注释。
                                      NSNumber *left = [notification.userInfo objectForKey:@"left"];
                                      if (0 == left.integerValue) {
                                          [super refreshConversationTableViewIfNeeded];
                                      }
                                  });
                              }];
    } else {
        //调用父类刷新未读消息数
        [super didReceiveMessageNotification:notification];
    }
}
- (void)didTapCellPortrait:(RCConversationModel *)model {
    if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_PUBLIC_SERVICE) {
        RCDChatViewController *_conversationVC = [[RCDChatViewController alloc] init];
        _conversationVC.conversationType = model.conversationType;
        _conversationVC.targetId = model.targetId;
        _conversationVC.userName = model.conversationTitle;
        _conversationVC.title = model.conversationTitle;
        _conversationVC.conversation = model;
        _conversationVC.unReadMessage = model.unreadMessageCount;
        [self.navigationController pushViewController:_conversationVC animated:YES];
    }

    if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_NORMAL) {
        RCDChatViewController *_conversationVC = [[RCDChatViewController alloc] init];
        _conversationVC.conversationType = model.conversationType;
        _conversationVC.targetId = model.targetId;
        _conversationVC.userName = model.conversationTitle;
        _conversationVC.title = model.conversationTitle;
        _conversationVC.conversation = model;
        _conversationVC.unReadMessage = model.unreadMessageCount;
        _conversationVC.enableNewComingMessageIcon = YES; //开启消息提醒
        _conversationVC.enableUnreadMessageIcon = YES;
        if (model.conversationType == ConversationType_SYSTEM) {
            _conversationVC.userName = RCDLocalizedString(@"de_actionbar_sub_system");
            _conversationVC.title = RCDLocalizedString(@"de_actionbar_sub_system");
        }
        if ([model.objectName isEqualToString:@"RC:ContactNtf"]) {
            RCDAddressBookViewController *addressBookVC = [RCDAddressBookViewController addressBookViewController];
            addressBookVC.needSyncFriendList = YES;
            [self.navigationController pushViewController:addressBookVC animated:YES];
            return;
        }
        //如果是单聊，不显示发送方昵称
        if (model.conversationType == ConversationType_PRIVATE) {
            _conversationVC.displayUserNameInCell = NO;
        }
        [self.navigationController pushViewController:_conversationVC animated:YES];
    }

    //聚合会话类型，此处自定设置。
    if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_COLLECTION) {

        RCDChatListViewController *temp = [[RCDChatListViewController alloc] init];
        NSArray *array = [NSArray arrayWithObject:[NSNumber numberWithInt:model.conversationType]];
        [temp setDisplayConversationTypes:array];
        [temp setCollectionConversationType:nil];
        temp.isEnteredToCollectionViewController = YES;
        [self.navigationController pushViewController:temp animated:YES];
    }

    //自定义会话类型
    if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION) {
        //        RCConversationModel *model =
        //        self.conversationListDataSource[indexPath.row];

        if ([model.objectName isEqualToString:@"RC:ContactNtf"]) {
            RCDAddressBookViewController *addressBookVC = [RCDAddressBookViewController addressBookViewController];
            [self.navigationController pushViewController:addressBookVC animated:YES];
        }
    }
}
/*
//会话有新消息通知的时候显示数字提醒，设置为NO,不显示数字只显示红点
-(void)willDisplayConversationTableCell:(RCConversationBaseCell *)cell
atIndexPath:(NSIndexPath *)indexPath
{
    RCConversationModel *model=
  self.conversationListDataSource[indexPath.row];
    if (model.conversationType == ConversationType_PRIVATE) {
        ((RCConversationCell *)cell).isShowNotificationNumber = NO;
    }
}
 */
- (void)notifyUpdateUnreadMessageCount {
    [self updateBadgeValueForTabBarItem];
}

- (void)receiveNeedRefreshNotification:(NSNotification *)status {
    __weak typeof(self) __blockSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (__blockSelf.displayConversationTypeArray.count == 1 &&
            [__blockSelf.displayConversationTypeArray[0] integerValue] == ConversationType_DISCUSSION) {
            [__blockSelf refreshConversationTableViewIfNeeded];
        }

    });
}

- (void)checkVersion {
    [RCDHTTPTOOL getVersioncomplete:^(NSDictionary *versionInfo) {
        if (versionInfo) {
            NSString *isNeedUpdate = [versionInfo objectForKey:@"isNeedUpdate"];
            NSString *finalURL;
            if ([isNeedUpdate isEqualToString:@"YES"]) {
                __weak typeof(self) __weakSelf = self;
                [__weakSelf.tabBarController.tabBar showBadgeOnItemIndex:3];
                //获取系统当前的时间戳
                NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
                NSTimeInterval now = [dat timeIntervalSince1970] * 1000;
                NSString *timeString = [NSString stringWithFormat:@"%f", now];
                //为html增加随机数，避免缓存。
                NSString *applist = [versionInfo objectForKey:@"applist"];
                applist = [NSString stringWithFormat:@"%@?%@", applist, timeString];
                finalURL = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@", applist];
            }
            [[NSUserDefaults standardUserDefaults] setObject:finalURL forKey:@"applistURL"];
            [[NSUserDefaults standardUserDefaults] setObject:isNeedUpdate forKey:@"isNeedUpdate"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
}

- (void)pushToCreateDiscussion:(id)sender {
    RCDContactSelectedTableViewController *contactSelectedVC = [[RCDContactSelectedTableViewController alloc] init];
    contactSelectedVC.forCreatingDiscussionGroup = YES;
    contactSelectedVC.isAllowsMultipleSelection = YES;
    contactSelectedVC.titleStr = RCDLocalizedString(@"select_contact");
    [self.navigationController pushViewController:contactSelectedVC animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSIndexPath *indexPath = [self.conversationListTableView indexPathForRowAtPoint:scrollView.contentOffset];
    self.index = indexPath.row;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //恢复conversationListTableView的自动回滚功能。
    self.conversationListTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)GotoNextCoversation {
    NSUInteger i;
    //设置contentInset是为了滚动到底部的时候，避免conversationListTableView自动回滚。
    self.conversationListTableView.contentInset =
        UIEdgeInsetsMake(0, 0, self.conversationListTableView.frame.size.height, 0);
    for (i = self.index + 1; i < self.conversationListDataSource.count; i++) {
        RCConversationModel *model = self.conversationListDataSource[i];
        if (model.unreadMessageCount > 0) {
            NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            self.index = i;
            [self.conversationListTableView scrollToRowAtIndexPath:scrollIndexPath
                                                  atScrollPosition:UITableViewScrollPositionTop
                                                          animated:YES];
            break;
        }
    }
    //滚动到起始位置
    if (i >= self.conversationListDataSource.count) {
        //    self.conversationListTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        for (i = 0; i < self.conversationListDataSource.count; i++) {
            RCConversationModel *model = self.conversationListDataSource[i];
            if (model.unreadMessageCount > 0) {
                NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                self.index = i;
                [self.conversationListTableView scrollToRowAtIndexPath:scrollIndexPath
                                                      atScrollPosition:UITableViewScrollPositionTop
                                                              animated:YES];
                break;
            }
        }
    }
}

- (void)updateForSharedMessageInsertSuccess {
    [self refreshConversationTableViewIfNeeded];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    RCDSearchViewController *searchViewController = [[RCDSearchViewController alloc] init];
    self.searchNavigationController = [[UINavigationController alloc] initWithRootViewController:searchViewController];
    searchViewController.delegate = self;
    [self.navigationController.view addSubview:self.searchNavigationController.view];
}

- (void)onSearchCancelClick {
    [self.searchNavigationController.view removeFromSuperview];
    [self.searchNavigationController removeFromParentViewController];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self refreshConversationTableViewIfNeeded];
}

- (void)refreshCell:(NSNotification *)notify {
    /*
    NSString *row = [notify object];
    RCConversationModel *model = [self.conversationListDataSource objectAtIndex:[row intValue]];
    model.unreadMessageCount = 0;
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:[row integerValue] inSection:0];
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.conversationListTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil]
    withRowAnimation:UITableViewRowAnimationNone];
    });
     */
    [self refreshConversationTableViewIfNeeded];
}

@end
