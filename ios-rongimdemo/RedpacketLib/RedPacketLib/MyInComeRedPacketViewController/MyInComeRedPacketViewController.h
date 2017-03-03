//
//  MyInComeRedPacketViewController.h
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/2/28.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "YZHRefreshTableViewController.h"
#import "RedpacketMessageModel.h"

@interface MyInComeRedPacketViewController : YZHRefreshTableViewController

@property (nonatomic, strong) RedpacketMessageModel *messageModel;
@property (nonatomic,copy) NSDictionary * responseData;
@property (nonatomic, assign)   BOOL isSend;

- (void)closeBarButtonSender;
- (void)requestRedpacketGetDetailReplacer;
- (void)requestRedpacketGetDetail;

@end
