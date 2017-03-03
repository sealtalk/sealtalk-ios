//
//  RPSendAmountPacketViewController.h
//  RedpacketLib
//
//  Created by 都基鹏 on 16/10/24.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "YZHBaseViewController.h"

@protocol RPSendAmountPacketViewControllerDelegate <NSObject>

- (void)convertRedpacketViewcontrollerFromViewController:(UIViewController *)fromController;

@end

@interface RPSendAmountPacketViewController : YZHBaseViewController

/**
 *  会话信息，可能是个人也可能是群组
 */
@property (nonatomic,weak)  RedpacketUserInfo *conversationInfo;
@property (nonatomic, weak) UIViewController *hostViewController;
/**
 *  发送红包回调
 */
@property (nonatomic,copy)  void(^sendRedPacketBlock)(RedpacketMessageModel *model);

@property (nonatomic,weak)  id<RPSendAmountPacketViewControllerDelegate> delegate;

@end
