//
//  RCDDebugReceiptDetailsController.m
//  SealTalk
//
//  Created by 张改红 on 2021/2/24.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "RCDDebugReceiptDetailsController.h"
#import <RongIMLibCore/RongIMLibCore.h>
#import "RCDGroupMemberCell.h"
#import <RongIMKit/RongIMKit.h>
#import "NormalAlertView.h"
#import <MBProgressHUD/MBProgressHUD.h>
@interface RCDGroupMemberCell ()
@property (nonatomic, strong) UILabel *rightLabel;
@end

@interface RCDReceiptDetailsTableViewController()
- (void)handleData;
- (NSArray *)getUnreadUserList;
- (NSArray *)sortForHasReadList:(NSDictionary *)readReceiptUserDic;
@end

@interface RCDDebugReceiptDetailsController ()
@property (nonatomic, strong) NSArray *displayUserList;
@property (nonatomic, strong) NSArray *hasReadUserList;
@property (nonatomic, strong) NSArray *unreadUserList;
@property (nonatomic, strong) RCMessage *msg;
@property (nonatomic, strong) NSDictionary *readerDic;
@end

@implementation RCDDebugReceiptDetailsController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    RCMessage *message = [[RCCoreClient sharedCoreClient] getMessageByUId:weakSelf.message.messageUId];
    [[RCGroupReadReceiptV2Manager sharedManager] getGroupMessageReaderList:message success:^(NSArray<RCGroupMessageReaderV2 *> *readerList, int totalCount) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            weakSelf.msg = [[RCCoreClient sharedCoreClient] getMessageByUId:weakSelf.message.messageUId];
            [weakSelf handleData];
        });
        } error:^(RCErrorCode nErrorCode) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                [NormalAlertView showAlertWithTitle:nil
                                            message:[NSString stringWithFormat:@"error code : %ld",nErrorCode]
                                      describeTitle:nil
                                       confirmTitle:RCDLocalizedString(@"confirm")
                                            confirm:^{
                                            }];
            });
        }];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDGroupMemberCell *cell = [RCDGroupMemberCell cellWithTableView:tableView];
    [cell setDataModel:self.displayUserList[indexPath.row] groupId:self.message.targetId];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.rightLabel.text = [NSString stringWithFormat:@"%lld",[self.readerDic[self.displayUserList[indexPath.row]] longLongValue]];
    return cell;
}

- (void)handleData {
    NSArray *readerList = self.msg.groupReadReceiptInfoV2.readerList;
    NSMutableDictionary *readerJson = [NSMutableDictionary new];
    for (RCGroupMessageReaderV2 *reader in readerList) {
        [readerJson setValue:@(reader.readTime) forKey:reader.userId];
    }
    self.readerDic = [readerJson copy];
    NSArray *hasReadUserList = [readerJson allKeys];
    if (hasReadUserList.count > 1) {
        hasReadUserList = [self sortForHasReadList:readerJson];
    }
    self.hasReadUserList = hasReadUserList;
    self.unreadUserList = [self getUnreadUserList];
    self.displayUserList = self.unreadUserList;
    [self.tableView reloadData];
}
@end
