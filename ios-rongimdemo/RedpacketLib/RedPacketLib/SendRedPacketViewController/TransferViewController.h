//
//  TransferViewController.h
//  RedpacketLib
//
//  Created by Mr.Yan on 16/8/24.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "YZHRefreshTableViewController.h"
#import "RedpacketMessageModel.h"
#import "RedpacketViewControl.h"

@interface TransferViewController : YZHRefreshTableViewController

@property (nonatomic, strong)   RedpacketUserInfo *userInfo;

@property (nonatomic, copy) void(^sendRedPacketBlock)(RedpacketMessageModel *model);

@end
