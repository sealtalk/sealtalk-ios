//
//  RCPushProfile.h
//  RongIMLib
//
//  Created by 杜立召 on 16/12/26.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCStatusDefine.h"
#import <Foundation/Foundation.h>

@interface RCPushProfile : NSObject

//是否显示远程推送的内容
@property(nonatomic, assign, readonly) BOOL isShowPushContent;

//远程推送的语言
@property(nonatomic, assign, readonly) RCPushLauguage pushLauguage;

//其他端在线时，手机是否接收远程推送(多个手机端登录，最后一个会接收)
@property(nonatomic, assign, readonly) BOOL receiveStatus;

/**
 设置是否显示远程推送的内容

 @param isShowPushContent 是否显示推送的具体内容（ YES显示 NO 不显示）
 @param successBlock      成功回调
 @param errorBlock        失败回调
 */
- (void)updateShowPushContentStatus:(BOOL)isShowPushContent
                            success:(void (^)(void))successBlock
                              error:(void (^)(RCErrorCode status))errorBlock;

/**
 设置推送内容的自然语言
 
 @param pushLauguage      设置推送内容的自然语言 （目前只支持中文和英文）
 @param successBlock      成功回调
 @param errorBlock        失败回调
 */
- (void)setPushLauguage:(RCPushLauguage)pushLauguage
                success:(void (^)(void))successBlock
                  error:(void (^)(RCErrorCode status))errorBlock;


/**
 设置 Web 端在线时，手机端是否接收推送
 
 @param receiveStatus     是否接收推送（ YES 接收 NO 不接收）
 @param successBlock      成功回调
 @param errorBlock        失败回调
 */
- (void)setPushReceiveStatus:(BOOL)receiveStatus
                     success:(void (^)(void))successBlock
                       error:(void (^)(RCErrorCode status))errorBlock;

@end
