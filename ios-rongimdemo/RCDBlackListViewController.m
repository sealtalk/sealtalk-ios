//
//  RCDBlackListViewController.m
//  RCloudMessage
//
//  Created by 蔡建海 on 15/7/13.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDBlackListViewController.h"
#import "RCDBlackListCell.h"
#import "RCDUserInfoManager.h"
#import "RCDUtilities.h"
#import "RCDataBaseManager.h"

@interface RCDBlackListViewController ()

@property(nonatomic, strong) NSMutableDictionary *mDictData;
@property(nonatomic, strong) NSMutableArray *keys;
@end

@implementation RCDBlackListViewController

#pragma mark - Table view data source
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self getAllData];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self getAllData];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    self.tableView.tableFooterView = [UIView new];

    self.title = RCDLocalizedString(@"blacklist")
;
}

#pragma mark - private

//
- (void)getAllData {
    [[RCIMClient sharedRCIMClient] getBlacklist:^(NSArray *blockUserIds) {
        [[RCDataBaseManager shareInstance] clearBlackListData];
        NSMutableArray *blacklist = [[NSMutableArray alloc] initWithCapacity:5];
        for (NSString *userID in blockUserIds) {
            // 暂不取用户信息，界面展示的时候在获取
            RCUserInfo *userInfo = [[RCUserInfo alloc] init];
            userInfo.userId = userID;
            userInfo.portraitUri = nil;
            userInfo.name = nil;
            [blacklist addObject:userInfo];
        }
        [[RCDataBaseManager shareInstance] insertBlackListUsersToDB:blacklist
                                                           complete:^(BOOL result){
                                                           }];
        NSArray *resultList = [[RCDUserInfoManager shareInstance] getFriendInfoList:blacklist];
        blacklist = [[NSMutableArray alloc] initWithArray:resultList];
        NSMutableDictionary *resultDic = [RCDUtilities sortedArrayWithPinYinDic:blacklist];
        self.mDictData = resultDic[@"infoDic"];
        self.keys = resultDic[@"allKeys"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
        error:^(RCErrorCode status) {
            NSMutableArray *blacklist =
                [[NSMutableArray alloc] initWithArray:[[RCDataBaseManager shareInstance] getBlackList]];
            NSArray *resultList = [[RCDUserInfoManager shareInstance] getFriendInfoList:blacklist];
            blacklist = [[NSMutableArray alloc] initWithArray:resultList];
            NSMutableDictionary *resultDic = [RCDUtilities sortedArrayWithPinYinDic:blacklist];
            self.mDictData = resultDic[@"infoDic"];
            self.keys = resultDic[@"allKeys"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            NSLog(@"getAllData error ");
        }];
}

//
- (void)removeFromBlackList:(NSIndexPath *)indexPath {
    NSString *key = [self.keys objectAtIndex:indexPath.section];
    NSMutableArray *marray = [NSMutableArray arrayWithArray:[self.mDictData objectForKey:key]];
    [marray removeObjectAtIndex:indexPath.row];

    if (marray.count == 0) {
        [self.mDictData removeObjectForKey:key];
        [self.keys removeObject:key];

        [self.tableView reloadSectionIndexTitles];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]
                      withRowAnimation:UITableViewRowAnimationFade];
    } else {
        if (marray.count < 20) {
            [self.mDictData setObject:marray forKey:key];
            [self.tableView reloadData];

        } else {
            [self.mDictData setObject:marray forKey:key];
            [self.tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reusableCellWithIdentifier = @"CellWithIdentifier";
    RCDBlackListCell *cell =
        (RCDBlackListCell *)[tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];

    if (cell == nil) {
        cell = [[RCDBlackListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:reusableCellWithIdentifier];
    }

    NSString *key = [self.keys objectAtIndex:indexPath.section];
    RCUserInfo *info = [[self.mDictData objectForKey:key] objectAtIndex:indexPath.row];

    [cell setUserInfo:info];

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = [self.keys objectAtIndex:section];

    NSArray *arr = [self.mDictData objectForKey:key];
    return [arr count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.keys.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.f;
}

// pinyin index
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.keys;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.keys objectAtIndex:section];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        NSString *key = [self.keys objectAtIndex:indexPath.section];
        RCUserInfo *info = [[self.mDictData objectForKey:key] objectAtIndex:indexPath.row];

        __weak typeof(self) weakSelf = self;

        [[RCIMClient sharedRCIMClient] removeFromBlacklist:info.userId
            success:^{

                dispatch_async(dispatch_get_main_queue(), ^{

                    [weakSelf removeFromBlackList:indexPath];
                });

            }
            error:^(RCErrorCode status) {

                NSLog(@" ... 解除黑名单失败 ... ");
            }];

    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}

@end
