/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCFileUtility.h

#ifndef __RCFileUtility
#define __RCFileUtility

#import "RCStatusDefine.h"

@interface RCFileUtility : NSObject

/*!
 设置文件媒体类型

 @return    文件类型
 */
+ (NSString *)getMimeType:(RCMediaType)fileType;

/*!
 获取上传文件名称

 @return    文件媒体类型
 */
+ (NSString *)generateKey:(NSString *)mimeType;

/*!
 生成下载的文件路径

 @return    文件名称
 */
+ (NSString *)getFileName:(NSString *)imgUrl
         conversationType:(RCConversationType)conversationType
                mediaType:(RCMediaType)mediaType
                 targetId:(NSString *)targetId;

+ (NSString *)getFileKey:(NSString *)fileUri;

+ (NSString *)getMediaDir:(RCMediaType)fileType;

+ (NSString *)getCateDir:(RCConversationType)categoryId;

+ (BOOL)isFileExist:(NSString *)fileName;

+ (BOOL)saveFile:(NSString *)filePath content:(NSData *)content;

+ (NSString *)getUniqueFileName:(NSString *)baseFileName;

@end
#endif
