//
//  RCCustomerServiceConfig.h
//  RongIMLib
//
//  Created by litao on 16/2/25.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCStatusDefine.h"
#import "RCCSLeaveMessageItem.h"
// onResult:(void(^)(int isSuccess, NSString *errMsg))resultBlock
// onBlocked:(void(^)(void))blockedBlock
// onCompanyInfo:(void(^)(NSString *companyName, NSString
// *companyUrl))companyInfoBlockInfo
// onKeyboardType:(void(^)(RCCSInputType keyboardType))keyboardTypeBlock
// onQuit:(void(^)(NSString *quitMsg))quitBlock;

@interface RCCustomerServiceConfig : NSObject
/*!
 * 是否被客服加为黑名单
 */
@property(nonatomic) BOOL isBlack;

/*!
 * 公司名称
 */
@property(nonatomic, strong) NSString *companyName;

/*!
 * 公司的Url
 */
@property(nonatomic, strong) NSString *companyUrl;

/*!
 * 机器人会话是否不需要评价
 */
@property(nonatomic, assign) BOOL robotSessionNoEva;

/*!
 * 人工服务会话是否不需要评价
 */
@property(nonatomic, assign) BOOL humanSessionNoEva;

/*!
 * 人工服务的评价选项，array的数据是RCEvaluateItem类型
 */
@property(nonatomic, strong) NSArray *humanEvaluateItems;

@property(nonatomic) int adminTipTime;
@property(nonatomic, strong) NSString *adminTipWord;

@property(nonatomic) int userTipTime;
@property(nonatomic, strong) NSString *userTipWord;
/*!
 * 评价时机
 */
@property(nonatomic, assign) RCCSEvaEntryPoint evaEntryPoint;

/*!
 * 评价类型
 如果 evaType 为 RCCSEvaSeparately，发送机器人评价消息调用RCIMClient中evaluateCustomerService: knownledgeId: robotValue: suggest:
 发送人工评价消息调用RCIMClient中
 evaluateCustomerService: dialogId: humanValue: suggest:
 
 如果 evaType 为 EVA_UNIFIED，发送评价消息调用RCIMClient中
 evaluateCustomerService: dialogId: starValue: suggest: resolveStatus:
 */
@property(nonatomic, assign) RCCSEvaType evaType;

/*!
 * 是否显示解决状态:0.不显示；1显示
 */
@property(nonatomic, assign) int reportResolveStatus;

/*!
 * 留言样式:0.默认跳转留言界面；1.跳转url留言
 */
@property(nonatomic, assign) RCCSLMType  leaveMessageType;

/*!
 * 是否支持地图发送：0.支持；1.不支持
 */
@property(nonatomic, assign) int disableLocation;

/*!
 * 自定义留言
 */
@property(nonatomic, copy) NSString *leaveMessageWebUrl;

/*!
 * 默认留言样式
 */
@property(nonatomic, copy) NSArray<RCCSLeaveMessageItem *> *leaveMessageNativeInfo;
@end
