//
//  RCUploadImageStatusListener.h
//  RongIMLib
//
//  Created by litao on 15/8/28.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCMessage.h"

/*!
 图片上传进度更新的IMKit监听
 
 @discussion 此监听用于IMKit发送图片消息（上传到指定服务器）。
 App在上传图片时，需要在监听中调用updateBlock、successBlock与errorBlock，通知IMKit SDK当前上传图片的进度和状态，SDK会更新UI。
 */
@interface RCUploadImageStatusListener : NSObject

/*!
 上传的图片消息的消息实体
 */
@property (nonatomic, strong)RCMessage *currentMessage;

/*!
 更新上传进度需要调用的block [progress:当前上传的进度，0 <= progress < 100]
 */
@property (nonatomic, strong)void (^updateBlock)(int progress);

/*!
 上传成功需要调用的block [imageUrl:图片的网络URL]
 */
@property (nonatomic, strong)void (^successBlock)(NSString *imageUrl);

/*!
 上传成功需要调用的block [errorCode:上传失败的错误码，非0整数]
 */
@property (nonatomic, strong)void (^errorBlock)(RCErrorCode errorCode);

/*!
 初始化图片上传进度更新的IMKit监听
 
 @param message             图片消息的消息实体
 @param progressBlock       更新上传进度需要调用的block
 @param successBlock        上传成功需要调用的block
 @param errorBlock          上传失败需要调用的block
 
 @return                    图片上传进度更新的IMKit监听对象
 */
- (instancetype)initWithMessage:(RCMessage *)message
                 uploadProgress:(void (^)(int progress))progressBlock
                  uploadSuccess:(void (^)(NSString *imageUrl))successBlock
                    uploadError:(void (^)(RCErrorCode errorCode))errorBlock;

@end
