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

/**
 设置是否显示远程推送的内容

 @param isShowPushContent 是否显示推送的具体内容（ YES显示 NO 不显示）
 @param successBlock      成功回调
 @param errorBlock        失败回调
 */
- (void)updateShowPushContentStatus:(BOOL)isShowPushContent
                            success:(void (^)(void))successBlock
                              error:(void (^)(RCErrorCode status))errorBlock;

@end
