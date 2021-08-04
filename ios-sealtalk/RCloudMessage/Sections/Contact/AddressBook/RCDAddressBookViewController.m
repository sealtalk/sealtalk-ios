//
//  RCDAddressBookViewController.m
//  RongCloud
//
//  Created by Liv on 14/11/11.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCDAddressBookViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "RCDAddressBookTableViewCell.h"
#import "RCDChatViewController.h"
#import "RCDCommonDefine.h"
#import "RCDNoFriendView.h"
#import "RCDRCIMDataSource.h"
#import "UIColor+RCColor.h"
#import "RCDUserInfoManager.h"
#import "RCDCommonString.h"

@interface RCDAddressBookViewController ()

//#字符索引对应的user object
@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) RCDNoFriendView *noFriendView;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, assign) BOOL isSyncFriends;

@end

@implementation RCDAddressBookViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self setupNavi];
    [self getAllData];
}

- (void)viewDidLayoutSubviews {
    self.noFriendView.frame = self.view.bounds;
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reusableCellWithIdentifier = @"RCDAddressBookCell";
    RCDAddressBookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    if (!cell) {
        cell = [[RCDAddressBookTableViewCell alloc] init];
    }
    __weak typeof(self) weakSelf = self;
    cell.acceptBlock = ^(NSString *userId) {
        [weakSelf acceptInvite:userId];
    };

    cell.ignoreBlock = ^(NSString *userId) {
        [weakSelf ignoreInvite:userId];
    };

    RCDFriendInfo *user = self.friends[indexPath.row];
    [cell setModel:user];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.friends count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [RCDAddressBookTableViewCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDFriendInfo *user = self.friends[indexPath.row];
    if (user.status == RCDFriendStatusRequest || user.status == RCDFriendStatusRequested ||
        user.status == RCDFriendStatusDelete || user.status == RCDFriendStatusIgnore) {
        return;
    }

    RCDChatViewController *chatViewController = [[RCDChatViewController alloc] init];
    chatViewController.conversationType = ConversationType_PRIVATE;
    chatViewController.targetId = user.userId;
    chatViewController.title = user.name;
    chatViewController.displayUserNameInCell = NO;
    chatViewController.needPopToRootView = YES;
    [self.navigationController pushViewController:chatViewController animated:YES];
}

#pragma mark - Private Method
- (void)setupViews {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if ([self.tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [self.tableView addSubview:self.noFriendView];
}

- (void)setupNavi {
    self.navigationItem.title = RCDLocalizedString(@"new_friend");
}

- (void)getAllData {
    self.friends = [NSMutableArray arrayWithArray:[RCDUserInfoManager getAllFriendRequests]];
    if (self.friends.count > 0) {
        self.noFriendView.hidden = YES;
        [self.tableView reloadData];
    } else {
        self.noFriendView.hidden = NO;
    }
    if (self.isSyncFriends == NO) {
        [RCDUserInfoManager getFriendListFromServer:^(NSArray<RCDFriendInfo *> *friendList) {
            self.isSyncFriends = YES;
            if (friendList > 0) {
                rcd_dispatch_main_async_safe(^{
                    self.noFriendView.hidden = YES;
                    [self getAllData];
                });
            }
        }];
    }
}

- (void)acceptInvite:(NSString *)userId {
    self.hud.labelText = RCDLocalizedString(@"adding_friend");
    [self.hud show:YES];
    [RCDUserInfoManager acceptFriendRequest:userId
                                   complete:^(BOOL success) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           if (success) {
                                               [[NSNotificationCenter defaultCenter]
                                                   postNotificationName:RCDContactsRequestKey
                                                                 object:nil];
                                               self.friends = [RCDUserInfoManager getAllFriendRequests];
                                               [self.tableView reloadData];
                                               [self.hud hide:YES];
                                           } else {
                                               [self.hud hide:YES];
                                               [self showAlertController:RCDLocalizedString(@"add_fail")
                                                             cancenTitle:RCDLocalizedString(@"confirm")];
                                           }
                                       });
                                   }];
}

- (void)ignoreInvite:(NSString *)userId {
    self.hud.labelText = RCDLocalizedString(@"IgnoreFriendRequest");
    [self.hud show:YES];
    [RCDUserInfoManager ignoreFriendRequest:userId
                                   complete:^(BOOL success) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [self.hud hide:YES];
                                           if (success) {
                                               [[NSNotificationCenter defaultCenter]
                                                   postNotificationName:RCDContactsRequestKey
                                                                 object:nil];
                                               self.friends = [RCDUserInfoManager getAllFriendRequests];
                                               [self.tableView reloadData];
                                           } else {
                                               [self showAlertController:RCDLocalizedString(@"IgnoreFailure")
                                                             cancenTitle:RCDLocalizedString(@"confirm")];
                                           }
                                       });
                                   }];
}

- (void)showAlertController:(NSString *)title cancenTitle:(NSString *)cancelTitle {
    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Setter && Getter
- (RCDNoFriendView *)noFriendView {
    if (!_noFriendView) {
        CGRect frame = CGRectMake(0, 0, RCDScreenWidth, RCDScreenHeight - 64);
        _noFriendView = [[RCDNoFriendView alloc] initWithFrame:frame];
        _noFriendView.displayLabel.text = RCDLocalizedString(@"no_invite");
    }
    return _noFriendView;
}

- (MBProgressHUD *)hud {
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.color = [UIColor colorWithHexString:@"343637" alpha:0.5];
    }
    return _hud;
}
@end
