//
//  RCUploadMediaStatusListener.h
//  RongIMLib
//
//  Created by litao on 15/8/28.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCMessage.h"
#import <Foundation/Foundation.h>

/*!
 媒体文件上传进度更新的IMKit监听

 @discussion 此监听用于IMKit发送媒体文件消息（上传到指定服务器）。
 App在上传媒体文件时，需要在监听中调用updateBlock、successBlock与errorBlock，通知IMKit
 SDK当前上传媒体文件的进度和状态，SDK会更新UI。
 */
@interface RCUploadMediaStatusListener : NSObject

/*!
 上传的媒体文件消息的消息实体
 */
@property(nonatomic, strong) RCMessage *currentMessage;

/*!
 更新上传进度需要调用的block [progress:当前上传的进度，0 <= progress < 100]
 */
@property(nonatomic, strong) void (^updateBlock)(int progress);

/*!
 上传成功需要调用的block [remoteUrl:媒体文件的网络URL]
 */
@property(nonatomic, strong) void (^successBlock)(NSString *remoteUrl);

/*!
 上传成功需要调用的block [errorCode:上传失败的错误码，非0整数]
 */
@property(nonatomic, strong) void (^errorBlock)(RCErrorCode errorCode);

/*!
 初始化媒体文件上传进度更新的IMKit监听

 @param message             媒体文件消息的消息实体
 @param progressBlock       更新上传进度需要调用的block
 @param successBlock        上传成功需要调用的block
 @param errorBlock          上传失败需要调用的block

 @return                    媒体文件上传进度更新的IMKit监听对象
 */
- (instancetype)initWithMessage:(RCMessage *)message
                 uploadProgress:(void (^)(int progress))progressBlock
                  uploadSuccess:(void (^)(NSString *remoteUrl))successBlock
                    uploadError:(void (^)(RCErrorCode errorCode))errorBlock;

@end
