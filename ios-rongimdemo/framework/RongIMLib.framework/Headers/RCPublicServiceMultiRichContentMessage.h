/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCPublicServiceMultiRichContentMessage.h
//  Created by litao on 15/4/13.

#import "RCMessageContent.h"

/*!
 公众服务的多图文消息的类型名
 */
#define RCPublicServiceRichContentTypeIdentifier @"RC:PSMultiImgTxtMsg"

/*!
 公众服务的多图文消息类

 @discussion 公众服务的多图文消息类，此消息会进行存储并计入未读消息数。
 */
@interface RCPublicServiceMultiRichContentMessage : RCMessageContent <NSCoding>

/*!
 多图文消息的内容RCRichContentItem数组
 */
@property(nonatomic, strong) NSArray *richConents;

/*!
 多图文消息的附加信息
 */
@property(nonatomic, strong) NSString *extra;

@end
