//
//  RCPTTClient.h
//  RongPTTLib
//
//  Created by LiFei on 2016/12/26.
//  Copyright © 2016年 Sin. All rights reserved.
//

#import "RCPTTLibCommonDefine.h"
#import "RCPTTLibDelegate.h"
#import "RCPTTSession.h"
#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>

@interface RCPTTClient : NSObject

+ (instancetype)sharedPTTClient;

/*!
 设置app server的URL
 */
- (void)setServerURL:(NSString *)url;

- (void)setDelegate:(id<RCPTTLibDelegate>)delegate;

/*!
 在某个会话中加入对讲。

 @param conversationType  会话类型
 @param targetId          目标会话Id
 @param successBlock      成功加入对讲的回调 [participants:当前参与对讲的用户id列表]
 @param errorBlock        对讲加入失败的回调

 @discussion 一个会话中只能存在一个对讲。一个用户同一时间只能加入一个对讲。
 */
- (void)joinSession:(RCConversationType)conversationType
           targetId:(NSString *)targetId
            success:(void (^)(NSArray *participants))successBlock
              error:(void (^)(RCPTTErrorCode code))errorBlock;

/*!
 在某个会话中退出对讲。

 @param conversationType  会话类型
 @param targetId          目标会话Id
 @param successBlock      成功退出对讲的回调
 @param errorBlock        退出对讲失败的回调
 */
- (void)leaveSession:(RCConversationType)conversationType
            targetId:(NSString *)targetId
             success:(void (^)(void))successBlock
               error:(void (^)(RCPTTErrorCode code))errorBlock;

/*!
 在对讲中抢麦

 @param conversationType  会话类型
 @param targetId          目标会话Id
 @param successBlock      成功抢麦的回调
 [speakExpireTime: 此次抢麦最长说话时间，到时后系统会自动收回说话权。以毫秒为单位。]
 @param errorBlock        抢麦失败的回调
 */
- (void)startSpeak:(RCConversationType)conversationType
          targetId:(NSString *)targetId
           success:(void (^)(long speakExpireTime))successBlock
             error:(void (^)(RCPTTErrorCode code))errorBlock;

/*!
 讲话结束。释放麦克风，对讲中其他人可以开始抢麦。

 @param conversationType  会话类型
 @param targetId          目标会话Id
 @param successBlock      成功结束讲话的回调
 @param errorBlock        结束讲话失败的回调
 */
- (void)stopSpeak:(RCConversationType)conversationType
         targetId:(NSString *)targetId
          success:(void (^)(void))successBlock
            error:(void (^)(RCPTTErrorCode code))errorBlock;

/*!
 在某个会话中获取对讲session，如果该会话没有对讲存在，则返回nil

 @param conversationType  会话类型
 @param targetId          目标会话Id

 @return                  对讲session

 */
- (RCPTTSession *)getSession:(RCConversationType)conversationType targetId:(NSString *)targetId;

@end
