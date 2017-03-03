//
//  RPSendRedPacketViewController.h
//  RedpacketLib
//
//  Created by 都基鹏 on 16/8/1.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPBaseTableViewController.h"
#import "RedpacketViewControl.h"

typedef NS_ENUM(NSInteger,RPSendRedPacketViewControllerType){
    RPSendRedPacketViewControllerSingle, //点对点红包
    RPSendRedPacketViewControllerGroup,  //普通群红包
    RPSendRedPacketViewControllerMember, //专属红包（包含普通群红包功能）
};


@interface RPSendRedPacketViewController : RPBaseTableViewController

- (instancetype)initWithControllerType:(RPSendRedPacketViewControllerType)type;

@property (nonatomic, weak) UIViewController *hostController;

@property (nonatomic,copy) RedpacketMemberListBlock fetchBlock;

/**
 *  会话信息，可能是个人也可能是群组
 */
@property (nonatomic, weak) RedpacketUserInfo *conversationInfo;
/**
 *  发送红包回调
 */
@property (nonatomic, copy) void(^sendRedPacketBlock)(RedpacketMessageModel *model);
/**
 *  设置群红包人数
 */
- (void)setMemberCount:(NSInteger)memberCount;


@end
