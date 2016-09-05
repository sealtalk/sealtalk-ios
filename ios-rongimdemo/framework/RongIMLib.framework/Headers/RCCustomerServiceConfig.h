//
//  RCCustomerServiceConfig.h
//  RongIMLib
//
//  Created by litao on 16/2/25.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

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
@end
