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
@class RCMessage;
@protocol RCResumeableDownloaderDelegate <NSObject>


/**
 下载完成后调用

 @param item 下载任务实例
 @param path 下载任务完成后的文件路径
 @discussion 通过 itemWithMessageId: 方法获取到写下载项，不会调用该方法
 */
- (void)downloadItem:(RCDownloadItem*)item filePath:(NSString*)path;

@end


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


@property(nonatomic,weak)id <RCResumeableDownloaderDelegate> delegate;

/**
 根据消息id 获取 RCDownloadItem 实例

 @param msgId 消息id
 @return 返回 RCDownloadItem 实例
 @discussion 仅支持文件消息,文件消息下载完成后，会自动更新消息的 content
 */
- (RCDownloadItem*)itemWithMessageId:(long)msgId;


/**
 根据开发者指定的标识符来获取 RCDownloadItem 实例

 @param identify 标识符
 @param url 下载地址
 @param name 文件名
 @return 返回 RCDownloadItem 的实例
 @discussion 开发者需要保证该标识符 identify 的唯一性,确保每一个存活的下载任务的标识符是不同的
             实际下载后文件名可能会与不一致，如果存储下载文件目录下已有该文件，会在文件名后添加(1)。
             例如 a.txt 最终下载的文件名会变为 a(1).txt 或者 a(2).txt
 */
- (RCDownloadItem*)itemWithIdentify:(NSString*)identify
                                url:(NSString*)url
                           fileName:(NSString*)name;

@end

NS_ASSUME_NONNULL_END

