//
//  RPSendRedPacketItem.h
//  RedpacketLib
//
//  Created by 都基鹏 on 16/8/2.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RPUntility.h"
#import "RedpacketViewControl.h"
#import "RedpacketMessageModel.h"

@interface RPSendRedPacketItem : NSObject
@property (nonatomic,copy)NSArray<RedpacketUserInfo *> * memberList;            //专属红包可领取的人
@property (nonatomic,strong)NSDecimalNumber * packetCount;                      //红包个数
@property (nonatomic,assign)NSInteger memberCount;                              //群人数
@property (nonatomic,strong)NSDecimalNumber * inputMoney;                       //输入金额(分)
@property (nonatomic,assign)RedpacketType redPacketType;                        //红包类型
@property (nonatomic,copy)NSString * congratulateTittle;                        //祝福语

@property (nonatomic,assign)BOOL checkChangeWarningTitle;                       //是否校验金额是否输入错误
@property (nonatomic,strong ,readonly)NSDecimalNumber * totalMoney;             //计算后总金额（分）
@property (nonatomic,strong ,readonly)NSDecimalNumber * price;                  //计算后单个红包金额
@property (nonatomic,strong ,readonly)NSNumber * maxTotalMoney;                 //最大输入金额（元）
@property (nonatomic,strong ,readonly)NSNumber * minTotalMoney;                 //最小输入金额（元）
@property (nonatomic,assign ,readonly)RedpacketType cacheRedPacketType;         //切换专属红包需要缓存当前红包状态
@property (nonatomic,assign ,readonly)BOOL submitEnable;                        //提交按钮是否可用
@property (nonatomic,strong ,readonly)RedpacketMessageModel * messageModel;
@property (nonatomic,copy ,readonly)NSString * warningTittle;                   //警告语


- (void)alterRedpacketPlayType;

@end
