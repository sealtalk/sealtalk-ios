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
#import "RCDDBManager.h"
#import <Masonry/Masonry.h>
#import "RCDCommonString.h"
#import "RCDRCIMDataSource.h"
@interface RCDBlackListViewController ()

@property (nonatomic, strong) NSMutableDictionary *mDictData;
@property (nonatomic, strong) NSMutableArray *keys;

@property (nonatomic, strong) UILabel *emptyLabel;
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

    self.title = RCDLocalizedString(@"blacklist");
    [self addEmptyLabel];
}

#pragma mark - private
- (void)getAllData {
    [RCDUserInfoManager getBlacklistFromServer:^(NSArray<NSString *> *blackUserIds) {
        if (!blackUserIds) {
            blackUserIds = [RCDUserInfoManager getBlacklist];
        }
        if (!blackUserIds) { //如果 APP 服务器和本地数据库都没有黑名单，直接返回
            return;
        }
        NSMutableArray *blacklist = [[NSMutableArray alloc] init];
        for (NSString *userId in blackUserIds) {
            RCUserInfo *userInfo = [RCDUserInfoManager getUserInfo:userId];
            if (userInfo) {
                [blacklist addObject:userInfo];
            }
        }
        NSMutableDictionary *resultDic = [RCDUtilities sortedArrayWithPinYinDic:blacklist];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mDictData = resultDic[@"infoDic"];
            self.keys = resultDic[@"allKeys"];
            [self reloadView];
        });
    }];
}

- (void)addEmptyLabel {
    [self.tableView addSubview:self.emptyLabel];
    [self.emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tableView).offset(-84);
        make.left.equalTo(self.tableView);
        make.bottom.offset([UIScreen mainScreen].bounds.size.height);
        make.right.offset([UIScreen mainScreen].bounds.size.width);
    }];
}

- (void)reloadView {
    self.emptyLabel.hidden = self.keys.count != 0;
    [self.tableView reloadData];
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
        [RCDUserInfoManager removeFromBlacklist:info.userId
                                       complete:^(BOOL success) {
                                           if (success) {
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   [RCDDataSource syncFriendList];
                                                   [weakSelf getAllData];
                                               });
                                           } else {
                                               NSLog(@" ... 解除黑名单失败 ... ");
                                           }
                                       }];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UILabel *)emptyLabel {
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc] init];
        _emptyLabel.text = RCDLocalizedString(@"Blacklist_empty");
        _emptyLabel.textColor = HEXCOLOR(0x939393);
        _emptyLabel.font = [UIFont systemFontOfSize:17];
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.hidden = YES;
    }
    return _emptyLabel;
}
@end
