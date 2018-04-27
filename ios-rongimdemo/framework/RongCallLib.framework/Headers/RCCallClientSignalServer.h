//
//  RCCallClientSignalServer.h
//  RongCallLib
//
//  Created by Tao Li on 2017/7/25.
//  Copyright © 2017年 Rong Cloud. All rights reserved.
//

#ifndef RCCallClientSignalServer_h
#define RCCallClientSignalServer_h
#import <RongCallLib/RongCallLib.h>
#import "RCCallSummaryMessage.h"

/*!
 信令服务代理
 */
@protocol RCCallSignalServerDelegate <NSObject>

/*!
 获取通话参与者的唯一媒体ID，必须保证每次电话会议的每个人的媒体ID都是全局唯一的。

 @param successBlock  为当前用户分配的媒体Id成功的回调
 @param errorBlcok    获取媒体Id失败的回调
 */
- (void)getUniqueMediaId:(void (^)(NSString *mediaId))successBlock error:(void (^)(int errorCode))errorBlcok;

/*!
 发送voip信令消息。

 @param messageContent  消息内容
 @param toUserIdList    接收者的Id
 @param pushContent     pushContent
 @param pushData        pushData
 @param successBlock    成功的回调
 @param errorBlcok      失败的回调
 */
- (void)sendVoipSignalMessage:(RCMessageContent *)messageContent
                 toUserIdList:(NSArray<NSString *> *)toUserIdList
                  pushContent:(NSString *)pushContent
                     pushData:(NSString *)pushData
                      success:(void (^)(void))successBlock
                        error:(void (^)(int errorCode))errorBlcok;

/*!
 Voip通话结束返回的统计信息

 @param summary  通话统计
 */
- (void)onVoipCallSummary:(RCCallSummaryMessage *)summary;
@end

#endif /* RCCallClientSignalServer_h */
