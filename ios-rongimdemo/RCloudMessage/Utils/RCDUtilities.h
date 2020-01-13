//
//  RCDUtilities.h
//  RCloudMessage
//
//  Created by 杜立召 on 15/7/21.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>
#import <UIKit/UIKit.h>

@interface RCDUtilities : NSObject
+ (UIImage *)imageNamed:(NSString *)name ofBundle:(NSString *)bundleName;
+ (NSString *)defaultGroupPortrait:(RCGroup *)groupInfo;
+ (NSString *)defaultUserPortrait:(RCUserInfo *)userInfo;
+ (NSString *)getIconCachePath:(NSString *)fileName;
+ (NSString *)hanZiToPinYinWithString:(NSString *)hanZi;
+ (NSString *)getFirstUpperLetter:(NSString *)hanzi;
+ (NSMutableDictionary *)sortedArrayWithPinYinDic:(NSArray *)userList;
+ (BOOL)isContains:(NSString *)firstString withString:(NSString *)secondString;
+ (UIImage *)getImageWithColor:(UIColor *)color andHeight:(CGFloat)height;
+ (NSString *)getDataString:(long long)time;
+ (CGFloat)getStringHeight:(NSString *)text font:(UIFont *)font viewWidth:(CGFloat)width;
+ (BOOL)isLowerLetter:(NSString *)string;
+ (BOOL)judgeSealTalkAccount:(NSString *)string;
+ (int)getTotalUnreadCount;
+ (void)getGroupUserDisplayInfo:(NSString *)userId
                        groupId:(NSString *)groupId
                         result:(void (^)(RCUserInfo *user))result;
+ (void)getUserDisplayInfo:(NSString *)userId complete:(void (^)(RCUserInfo *user))completeBlock;
+ (BOOL)stringContainsEmoji:(NSString *)string;
/**
动态颜色设置

 @param lightColor  亮色
 @param darkColor  暗色
 @return 修正后的图片
*/
+ (UIColor *)generateDynamicColor:(UIColor *)lightColor darkColor:(UIColor *)darkColor;

/// 判断字符串中是否包含汉字
+ (BOOL)includeChinese:(NSString *)string;
@end
