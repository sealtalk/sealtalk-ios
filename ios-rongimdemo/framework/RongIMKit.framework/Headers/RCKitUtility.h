//
//  RCKitUtility.h
//  iOS-IMKit
//
//  Created by xugang on 7/7/14.
//  Copyright (c) 2014 Heq.Shinoda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <RongIMLib/RongIMLib.h>

/*!
 IMKit工具类
 */
@interface RCKitUtility : NSObject

/*!
 时间转换
 
 @param secs    Unix时间戳（秒）
 @return        可视化的时间字符串
 
 @discussion 如果该时间是今天的，则返回值为"HH:mm"格式的字符串；
 如果该时间是昨天的，则返回字符串资源中Yesterday对应语言的字符串；
 如果该时间是昨天之前或者今天之后的，则返回"yyyy-MM-dd"的字符串。
 */
+ (NSString *)ConvertMessageTime:(long long)secs;

/*!
 时间转换
 
 @param secs    Unix时间戳（秒）
 @return        可视化的时间字符串
 
 @discussion 如果该时间是今天的，则返回值为"HH:mm"格式的字符串；
 如果该时间是昨天的，则返回"Yesterday HH:mm"的字符串（其中，Yesterday为字符串资源中Yesterday对应语言的字符串）；
 如果该时间是昨天之前或者今天之后的，则返回"yyyy-MM-dd HH:mm"的字符串。
 */
+ (NSString *)ConvertChatMessageTime:(long long)secs;

/*!
 获取资源包中的图片
 
 @param name        图片名
 @param bundleName  图片所在的Bundle名
 @return            图片
 */
+ (UIImage *)imageNamed:(NSString *)name ofBundle:(NSString *)bundleName;

/*!
 获取指定颜色的图片
 
 @param color   颜色值
 @return        坐标为(0.0f, 0.0f, 1.0f, 1.0f)的纯色图片
 */
+ (UIImage *)createImageWithColor:(UIColor *)color;

/*!
 获取文字显示的尺寸
 
 @param text 文字
 @param font 字体
 @param size 文字显示的容器大小
 
 @return 文字显示的尺寸
 
 @discussion 该方法在计算iOS 7以下系统显示的时候默认使用NSLineBreakByTruncatingTail模式。
 */
+ (CGSize)getTextDrawingSize:(NSString *)text font:(UIFont *)font constrainedSize:(CGSize)constrainedSize;

/*!
 获取消息内容的摘要
 
 @param messageContent  消息内容
 @return                消息内容的摘要
 
 @discussion SDK默认的消息有内置的处理，
 自定义消息会调用RCMessageContent中RCMessageContentView协议的conversationDigest获取消息摘要。
 */
+ (NSString *)formatMessage:(RCMessageContent *)messageContent;

/*!
 以消息的类型名为Key值在字符串资源中查找对应语言的字符串
 
 @param messageContent  消息内容
 @return                对应语言的字符串
 */
+ (NSString *)localizedDescription:(RCMessageContent *)messageContent;

/*!
 获取消息对应的本地消息Dictionary
 
 @param message 消息实体
 @return 本地通知的Dictionary
 */
+ (NSDictionary *)getNotificationUserInfoDictionary:(RCMessage *)message;

/*!
 获取消息对应的本地消息Dictionary（已废弃，请勿使用）
 
 @param conversationType    会话类型
 @param fromUserId          发送者的用户ID
 @param targetId            消息的目标会话ID
 @param messageContent      消息内容
 @return                    本地通知的Dictionary
 
 @warning **已废弃，请勿使用。**
 */
+ (NSDictionary *)getNotificationUserInfoDictionary:(RCConversationType)conversationType fromUserId:(NSString *)fromUserId targetId:(NSString *)targetId messageContent:(RCMessageContent *)messageContent
__deprecated_msg("已废弃，请勿使用。");

/*!
 获取消息对应的本地消息Dictionary
 
 @param conversationType    会话类型
 @param fromUserId          发送者的用户ID
 @param targetId            消息的目标会话ID
 @param objectName          消息的类型名
 @return                    本地通知的Dictionary
 */
+ (NSDictionary *)getNotificationUserInfoDictionary:(RCConversationType)conversationType fromUserId:(NSString *)fromUserId targetId:(NSString *)targetId objectName:(NSString *)objectName;

/*!
 获取文件消息中消息类型对应的图片名称
 
 @param fileType    文件类型
 @return            图片名称
 */
+ (NSString *)getFileTypeIcon:(NSString *)fileType;

/*!
 获取文件大小的字符串，单位是k
 
 @param byteSize    文件大小，单位是byte
 @return 文件大小的字符串
 */
+ (NSString *)getReadableStringForFileSize:(long long)byteSize;

@end
