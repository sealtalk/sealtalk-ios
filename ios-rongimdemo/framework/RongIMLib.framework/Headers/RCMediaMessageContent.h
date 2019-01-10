//
//  RCMediaMessageContent.h
//  RongIMLib
//
//  Created by lichenfeng on 2018/11/22.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "RCMessageContent.h"

/**
 媒体类型消息的父类
 
 @discussion SDK中所有媒体类型消息（图片、文件等）均继承此类，开发者如需将自定义的媒体类型消息上传到融云默认的服务器时必须继承此类(SDK负责媒体消息的上传及上传成功后的发送，开发者自行处理消息接收后的展示)。
 以下属性需要子类在encode、decode方法中和扩展的属性一同进行处理
 */
@interface RCMediaMessageContent : RCMessageContent

/**
 媒体内容的本地路径（此属性必须有值）
 */
@property(nonatomic, copy) NSString *localPath;

/**
 媒体内容上传服务器后的网络地址（上传成功后SDK会为该属性赋值）
 */
@property(nonatomic, copy) NSString *remoteUrl;

/**
 媒体内容的文件名（如不传使用SDK中downloadMediaMessage方法下载后会默认生成一个名称）
 */
@property(nonatomic, copy) NSString *name;
@end

