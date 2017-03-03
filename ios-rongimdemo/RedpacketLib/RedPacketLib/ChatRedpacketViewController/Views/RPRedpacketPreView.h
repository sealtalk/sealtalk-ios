//
//  RPRedpacketPreView.h
//  RedpacketLib
//
//  Created by 都基鹏 on 16/10/24.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RedpacketMessageModel.h"

typedef NS_ENUM(NSInteger, RedpacketBoxStatusType) {
    RedpacketBoxStatusTypeOverdue = 0,          /*** 红包已过期*/
    RedpacketBoxStatusTypePoint,                /*** 点对红包，拆红包页面*/
    RedpacketBoxStatusTypeAvgRobbing,           /*** 普通红包拆而未抢到的界面*/
    RedpacketBoxStatusTypeAvgRobbed,            /*** 普通红包未抢到界面*/
    RedpacketBoxStatusTypeRobbing,              /*** 群红包拆红包界面*/
    RedpacketBoxStatusTypeRandRobbing,          /*** 拼手气红包拆而未抢到的界面 也是拼手气红包未抢到界面*/
    RedpacketBoxStatusTypeMember,               /*** 专属红包*/
    RedpacketBoxStatusTypeSendAmount,           /*** 发送小额度随机红包*/
    RedpacketBoxStatusTypeReceiveAmount,        /*** 接收小额度随机红包*/
};

@interface RPRedpacketPreView : UIView

//UI
@property (nonatomic, strong) UIImageView   *backgroundImageView;
@property (nonatomic, strong) UIImageView   *avatarImageView;
@property (nonatomic, strong) UIButton      *closeButton;
@property (nonatomic, strong) UIButton      *submitButton;

//resources
@property (nonatomic, strong)   RedpacketMessageModel *messageModel;
@property (nonatomic, assign)   RedpacketBoxStatusType boxStatusType;

//action
@property (nonatomic, copy) void(^closeButtonBlock)(RPRedpacketPreView *packetView);
@property (nonatomic, copy) void(^submitButtonBlock)(RedpacketBoxStatusType boxStatusType,RPRedpacketPreView * packetView);

- (instancetype)initWithRedpacketBoxStatusType:(RedpacketBoxStatusType)boxStatusType;
+ (instancetype)preViewWithBoxStatusType:(RedpacketBoxStatusType)boxStatusType;

- (void)closeAction:(id)sender;
- (void)submitAction:(id)sender;
@end
