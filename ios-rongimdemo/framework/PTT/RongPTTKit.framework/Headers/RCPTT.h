//
//  RCPTT.h
//  RongPTTKit
//
//  Created by Sin on 16/12/29.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
#import <RongPTTLib/RongPTTLib.h>
#import <UIKit/UIKit.h>

/*
 通知的object为@{@"action":isEnd?@"end":@"start"}
 */

FOUNDATION_EXPORT NSString *const RCPTTSessionStatusChangeNotification;

@class RCPTT;

/**
 RCPTTKit的代理，注：所有的代理方法全部是在异步线程中，不在主线程
 */
@protocol RCPTTKitDelegate <NSObject>

/**
 ptt会话开始

 @param ptt ptt
 @param session 当前ptt会话对象
 */
- (void)ptt:(RCPTT *)ptt sessionDidStart:(RCPTTSession *)session;

/**
 ptt会话的参与者发生变化

 @param ptt ptt
 @param userIds 当前ptt的所有参与者
 @param session 当前ptt会话对象
 */
- (void)ptt:(RCPTT *)ptt participantsDidChange:(NSArray *)userIds inPTTSession:(RCPTTSession *)session;

/**
 麦克风持有者发生变化

 @param ptt ptt
 @param userId 当前麦克风持有者id，如果没有人持有麦克风，那么为@"null"
 @param session 当前ptt会话对象
 */
- (void)ptt:(RCPTT *)ptt micHolderDidChange:(NSString *)userId inPTTSession:(RCPTTSession *)session;

/**
 ptt会话结束

 @param ptt ptt
 @param session 当前ptt会话对象
 */
- (void)ptt:(RCPTT *)ptt sessionDidTerminate:(RCPTTSession *)session;

/**
 说话的时间限制到了

 @param ptt ptt
 @param session 当前ptt会话对象
 */
- (void)ptt:(RCPTT *)ptt speakTimeDidExpire:(RCPTTSession *)session;

@end

/**
 PTT功能核心单例类
 */
@interface RCPTT : NSObject

/**
 单例方法

 @return RCPTT单例对象
 */
+ (instancetype)sharedRCPTT;

#pragma mark - UI
/**
 当前登录用户的id
 */
@property(nonatomic, copy) NSString *currentUserId;

/**
 RCPTTStatusView的背景色
 */
@property(nonatomic, strong) UIColor *statusViewColor;

/**
 RCPTTTalkViewController上面头像所在view的颜色
 */
@property(nonatomic, strong) UIColor *headerViewColor;

#pragma mark - -

@property(nonatomic, weak) id<RCPTTKitDelegate> delegate;

@property(nonatomic, assign, readonly) RCConversationType conversationType;

@property(nonatomic, copy, readonly) NSString *targetId;

@property(nonatomic, assign, readonly) BOOL isInSession;

@property(nonatomic, strong, readonly) RCPTTSession *currentSession;

@property(nonatomic, strong, readonly) RCPTTSession *lastSession;

- (void)joinSession:(RCConversationType)conversationType
           targetId:(NSString *)targetId
            success:(void (^)(NSArray *participants))successBlock
              error:(void (^)(void))errorBlock;

- (void)leaveSession:(RCConversationType)conversationType
            targetId:(NSString *)targetId
             success:(void (^)(void))successBlock
               error:(void (^)(void))errorBlock;

- (void)startSpeak:(RCConversationType)conversationType
          targetId:(NSString *)targetId
           success:(void (^)(long))successBlock
             error:(void (^)(RCPTTErrorCode))errorBlock;

- (void)stopSpeak:(RCConversationType)conversationType
         targetId:(NSString *)targetId
          success:(void (^)(void))successBlock
            error:(void (^)(RCPTTErrorCode))errorBlock;

@end
