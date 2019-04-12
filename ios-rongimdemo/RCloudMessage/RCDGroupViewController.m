//
//  SecondViewController.m
//  RongCloud
//
//  Created by Liv on 14/10/31.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCDGroupViewController.h"
#import "RCDChatViewController.h"
#import "RCDGroupInfo.h"
#import "RCDGroupTableViewCell.h"
#import "RCDHttpTool.h"
#import "RCDataBaseManager.h"
#import "UIColor+RCColor.h"
#import "RCDForwardAlertView.h"
@interface RCDGroupViewController () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) NSMutableArray *groups;
//@property(nonatomic, strong) UILabel *noGroup;

@end

@implementation RCDGroupViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        //设置为不用默认渲染方式
        self.tabBarItem.image =
            [[UIImage imageNamed:@"icon_group"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.selectedImage =
            [[UIImage imageNamed:@"icon_group_hover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        //设置tableView样式
        self.tableView.separatorColor = [UIColor colorWithHexString:@"dfdfdf" alpha:1.0f];
        self.tableView.tableFooterView = [UIView new];
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;

        __weak RCDGroupViewController *weakSelf = self;

        _groups = [NSMutableArray arrayWithArray:[[RCDataBaseManager shareInstance] getAllGroup]];
        if ([_groups count] > 0) {
            [weakSelf.tableView reloadData];
        }

        [RCDHTTPTOOL getMyGroupsWithBlock:^(NSMutableArray *result) {

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSMutableArray *tempGroups =
                    [NSMutableArray arrayWithArray:[[RCDataBaseManager shareInstance] getAllGroup]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    _groups = tempGroups;
                    [weakSelf.tableView reloadData];
                });
            });
        }];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        //设置为不用默认渲染方式
        self.tabBarItem.image =
            [[UIImage imageNamed:@"icon_group"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.selectedImage =
            [[UIImage imageNamed:@"icon_group_hover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = RCDLocalizedString(@"group");
;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.tabBarController.navigationItem.rightBarButtonItem = nil;
}

- (void)viewDidLayoutSubviews {
    self.tableView.frame = self.view.frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _groups.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    RCDGroupInfo *groupInfo = _groups[indexPath.row];
    
    if ([RCDForwardMananer shareInstance].isForward) {
        RCConversation *conver = [[RCConversation alloc] init];
        conver.targetId = groupInfo.groupId;
        conver.conversationType = ConversationType_GROUP;
        [RCDForwardMananer shareInstance].toConversation = conver;
        [[RCDForwardMananer shareInstance] showForwardAlertViewInViewController:self];
        return;
    }
    RCDChatViewController *temp = [[RCDChatViewController alloc] init];
    temp.targetId = groupInfo.groupId;
    temp.conversationType = ConversationType_GROUP;
    temp.userName = groupInfo.groupName;
    temp.title = groupInfo.groupName;
    [self.navigationController pushViewController:temp animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isDisplayID = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDisplayID"];
    static NSString *CellIdentifier = @"RCDGroupCell";
    RCDGroupTableViewCell *cell = (RCDGroupTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[RCDGroupTableViewCell alloc] init];
    }

    RCDGroupInfo *group = _groups[indexPath.row];
    if (isDisplayID == YES) {
        cell.lblGroupId.text = group.groupId;
    }

    [cell setModel:group];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [RCDGroupTableViewCell cellHeight];
}

@end
