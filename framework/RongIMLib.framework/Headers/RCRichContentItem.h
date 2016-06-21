/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCRichContentItem.h
//  Created by Dulizhao on 15/4/21.

#import <Foundation/Foundation.h>

/*!
 公众服务图文信息条目类
 
 @discussion 图文消息类，此消息会进行存储并计入未读消息数。
 */
@interface RCRichContentItem : NSObject

/*!
 图文信息条目的标题
 */
@property(nonatomic, strong) NSString *title;

/*!
 图文信息条目的内容摘要
 */
@property(nonatomic, strong) NSString *digest;

/*!
 图文信息条目的图片URL
 */
@property(nonatomic, strong) NSString *imageURL;

/*!
 图文信息条目中包含的需要跳转到的URL
 */
@property(nonatomic, strong) NSString *url;

/*!
 图文信息条目的扩展信息
 */
@property(nonatomic, strong) NSString *extra;

/*!
 初始化公众服务图文信息条目
 
 @param title       图文信息条目的标题
 @param digest      图文信息条目的内容摘要
 @param imageURL    图文信息条目的图片URL
 @param extra       图文信息条目的扩展信息
 @return            图文信息条目对象
 */
+ (instancetype)messageWithTitle:(NSString *)title
                          digest:(NSString *)digest
                        imageURL:(NSString *)imageURL
                           extra:(NSString *)extra;

/*!
 初始化公众服务图文信息条目
 
 @param title       图文信息条目的标题
 @param digest      图文信息条目的内容摘要
 @param imageURL    图文信息条目的图片URL
 @param url         图文信息条目中包含的需要跳转到的URL
 @param extra       图文信息条目的扩展信息
 @return            图文信息条目对象
 */
+ (instancetype)messageWithTitle:(NSString *)title
                          digest:(NSString *)digest
                        imageURL:(NSString *)imageURL
                             url:(NSString *)url
                           extra:(NSString *)extra;

@end
