//
//  RCEResumeableDownloader.h
//  RongEnterpriseApp
//
//  Created by zhaobingdong on 2018/5/15.
//  Copyright © 2018年 rongcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCDownloadItem.h"

NS_ASSUME_NONNULL_BEGIN
@interface RCResumeableDownloader : NSObject

/**
 创建 RCResumeableDownloader 实例

 @return 返回 RCResumeableDownloader 实例
 */
+ (instancetype)defaultInstance;


/**
 销毁 RCResumeableDownloader 实例
 @discussion 切换用户时调用，退出登录时调用。
 */
+ (void)free;


/**
 根据消息id 获取 RCDownloadItem 实例

 @param msgId 消息id
 @return 返回 RCDownloadItem 实例
 */
- (RCDownloadItem*)itemWithMessageId:(long)msgId;

@end

NS_ASSUME_NONNULL_END

