/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCImageMessage.h
//  Created by Heq.Shinoda on 14-6-13.

#import "RCMessageContent.h"
#import <UIKit/UIKit.h>

/*!
 图片消息的类型名
 */
#define RCImageMessageTypeIdentifier @"RC:ImgMsg"

/*!
 图片消息类

 @discussion 图片消息类，此消息会进行存储并计入未读消息数。
 */
@interface RCImageMessage : RCMessageContent <NSCoding>

/*!
 图片消息的URL地址

 @discussion 发送方此字段为图片的本地路径，接收方此字段为网络URL地址。
 */
@property(nonatomic, strong) NSString *imageUrl;

/*!
 图片的本地路径
 */
@property(nonatomic, strong) NSString *localPath;

/*!
 图片消息的缩略图
 */
@property(nonatomic, strong) UIImage *thumbnailImage;

/*!
 是否发送原图

 @discussion 在发送图片的时候，是否发送原图，默认值为NO。
 */
@property(nonatomic, getter=isFull) BOOL full;

/*!
 图片消息的附加信息
 */
@property(nonatomic, strong) NSString *extra;

/*!
 图片消息的原始图片信息
 */
@property(nonatomic, strong) UIImage *originalImage;

/*!
 初始化图片消息

 @param image   原始图片
 @return        图片消息对象
 */
+ (instancetype)messageWithImage:(UIImage *)image;

/*!
 初始化图片消息

 @param imageURI    图片的本地路径
 @return            图片消息对象
 */
+ (instancetype)messageWithImageURI:(NSString *)imageURI;

@end
