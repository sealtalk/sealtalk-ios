//
//  RCSightMessage.h
//  RongIMLib
//
//  Created by LiFei on 2016/12/1.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>
#import <UIKit/UIKit.h>

/*!
 小视频消息的类型名
 */
#define RCSightMessageTypeIdentifier @"RC:SightMsg"
@class AVAsset;
/**
 小视频消息类

 @discussion 小视频消息类，此消息会进行存储并计入未读消息数。
 */
@interface RCSightMessage : RCMediaMessageContent <NSCoding>

/*!
 本地URL地址
 */
@property(nonatomic, copy) NSString *localPath;

/*!
 网络URL地址
 */
@property(nonatomic, readonly) NSString *sightUrl;

/**
 视频时长，以秒为单位
 */
@property(nonatomic, assign, readonly) NSUInteger duration;

/**
 小视频文件名
 */
@property(nonatomic, copy) NSString *name;

/**
 文件大小
 */
@property(nonatomic, assign, readonly) long long size;

/*!
 缩略图
 */
@property(nonatomic, strong, readonly) UIImage *thumbnailImage;

/**
 开发者使用的扩展字段
 */
@property(nonatomic, copy) NSString *extra;

/**
 创建小视频消息的便利构造方法

 @param path 视频文件本地路径
 @param image 视频首帧缩略图
 @param duration 视频时长， 单位秒
 @return 视频消息实例变量
 */
+ (instancetype)messageWithLocalPath:(NSString *)path
                           thumbnail:(UIImage *)image
                            duration:(NSUInteger)duration;

@end
