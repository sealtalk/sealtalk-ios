//
//  RCDUtilities.m
//  RCloudMessage
//
//  Created by 杜立召 on 15/7/21.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDUtilities.h"
#import "DefaultPortraitView.h"
#import "RCDFriendInfo.h"
#import "pinyin.h"
#import "RCDContactsInfo.h"
#import "RCDGroupManager.h"
#import "RCDUserInfoManager.h"
#import <RongIMKit/RongIMKit.h>
@implementation RCDUtilities
+ (UIImage *)imageNamed:(NSString *)name ofBundle:(NSString *)bundleName {
    UIImage *image = nil;
    NSString *image_name = [NSString stringWithFormat:@"%@.png", name];
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *bundlePath = [resourcePath stringByAppendingPathComponent:bundleName];
    NSString *image_path = [bundlePath stringByAppendingPathComponent:image_name];

    // NSString* path = [[[[NSBundle mainBundle] resourcePath]
    // stringByAppendingPathComponent:bundleName]stringByAppendingPathComponent:[NSString
    // stringWithFormat:@"%@.png",name]];

    // image = [UIImage imageWithContentsOfFile:image_path];
    image = [[UIImage alloc] initWithContentsOfFile:image_path];
    return image;
}

+ (NSString *)defaultGroupPortrait:(RCGroup *)groupInfo {
    NSString *filePath = [[self class] getIconCachePath:[NSString stringWithFormat:@"group%@.png", groupInfo.groupId]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSURL *portraitPath = [NSURL fileURLWithPath:filePath];
        return [portraitPath absoluteString];
    } else {
        UIImage *portrait = [DefaultPortraitView portraitView:groupInfo.groupId name:groupInfo.groupName];
        BOOL result = [UIImagePNGRepresentation(portrait) writeToFile:filePath atomically:YES];
        if (result) {
            NSURL *portraitPath = [NSURL fileURLWithPath:filePath];
            return [portraitPath absoluteString];
        } else {
            return nil;
        }
    }
}

+ (NSString *)defaultUserPortrait:(RCUserInfo *)userInfo {
    NSString *filePath = [[self class] getIconCachePath:[NSString stringWithFormat:@"user%@.png", userInfo.userId]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSURL *portraitPath = [NSURL fileURLWithPath:filePath];
        return [portraitPath absoluteString];
    } else {
        UIImage *portrait = [DefaultPortraitView portraitView:userInfo.userId name:userInfo.name];
        BOOL result = [UIImagePNGRepresentation(portrait) writeToFile:filePath atomically:YES];
        if (result) {
            NSURL *portraitPath = [NSURL fileURLWithPath:filePath];
            return [portraitPath absoluteString];
        } else {
            return nil;
        }
    }
}

+ (NSString *)getIconCachePath:(NSString *)fileName {
    NSString *cachPath =
        [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath =
        [cachPath stringByAppendingPathComponent:[NSString stringWithFormat:@"CachedIcons/%@",
                                                                            fileName]]; // 保存文件的名称

    NSString *dirPath = [cachPath stringByAppendingPathComponent:[NSString stringWithFormat:@"CachedIcons"]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:dirPath]) {
        [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return filePath;
}

/**
 *  汉字转拼音
 *
 *  @param hanZi 汉字
 *
 *  @return 转换后的拼音
 */
+ (NSString *)hanZiToPinYinWithString:(NSString *)hanZi {
    if (!hanZi) {
        return nil;
    }
    NSString *pinYinResult = [NSString string];
    for (int j = 0; j < hanZi.length; j++) {
        NSString *singlePinyinLetter = nil;
        if ([self isChinese:[hanZi substringWithRange:NSMakeRange(j, 1)]]) {
            singlePinyinLetter =
                [[NSString stringWithFormat:@"%c", pinyinFirstLetter([hanZi characterAtIndex:j])] uppercaseString];
        } else {
            singlePinyinLetter = [hanZi substringWithRange:NSMakeRange(j, 1)];
        }

        pinYinResult = [pinYinResult stringByAppendingString:singlePinyinLetter];
    }
    return pinYinResult;
}

+ (BOOL)isChinese:(NSString *)text {
    NSString *match = @"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:text];
}

+ (NSString *)getFirstUpperLetter:(NSString *)hanzi {
    NSString *pinyin = [self hanZiToPinYinWithString:hanzi];
    NSString *firstUpperLetter = [[pinyin substringToIndex:1] uppercaseString];
    if ([firstUpperLetter compare:@"A"] != NSOrderedAscending &&
        [firstUpperLetter compare:@"Z"] != NSOrderedDescending) {
        return firstUpperLetter;
    } else {
        return @"#";
    }
}

+ (NSMutableDictionary *)sortedArrayWithPinYinDic:(NSArray *)userList {
    if (!userList)
        return nil;
    NSArray *_keys = @[
        @"A",
        @"B",
        @"C",
        @"D",
        @"E",
        @"F",
        @"G",
        @"H",
        @"I",
        @"J",
        @"K",
        @"L",
        @"M",
        @"N",
        @"O",
        @"P",
        @"Q",
        @"R",
        @"S",
        @"T",
        @"U",
        @"V",
        @"W",
        @"X",
        @"Y",
        @"Z",
        @"#"
    ];

    NSMutableDictionary *infoDic = [NSMutableDictionary new];
    NSMutableArray *_tempOtherArr = [NSMutableArray new];
    BOOL isReturn = NO;

    for (NSString *key in _keys) {

        if ([_tempOtherArr count]) {
            isReturn = YES;
        }
        NSMutableArray *tempArr = [NSMutableArray new];
        for (id user in userList) {
            NSString *firstLetter;
            if ([user isMemberOfClass:[RCDFriendInfo class]]) {
                RCDFriendInfo *userInfo = (RCDFriendInfo *)user;
                if (userInfo.displayName.length > 0 && ![userInfo.displayName isEqualToString:@""]) {
                    firstLetter = [self getFirstUpperLetter:userInfo.displayName];
                } else {
                    firstLetter = [self getFirstUpperLetter:userInfo.name];
                }
            }
            if ([user isMemberOfClass:[RCUserInfo class]]) {
                RCUserInfo *userInfo = (RCUserInfo *)user;
                firstLetter = [self getFirstUpperLetter:userInfo.name];
            }
            if ([user isMemberOfClass:[RCDContactsInfo class]]) {
                RCDContactsInfo *contacts = (RCDContactsInfo *)user;
                firstLetter = [self getFirstUpperLetter:contacts.name];
            }
            if ([user isMemberOfClass:[RCDUserInfo class]]) {
                RCDUserInfo *userInfo = (RCDUserInfo *)user;
                firstLetter = [self getFirstUpperLetter:userInfo.name];
            }

            if ([firstLetter isEqualToString:key]) {
                [tempArr addObject:user];
            }

            if (isReturn)
                continue;
            char c = [firstLetter characterAtIndex:0];
            if (isalpha(c) == 0) {
                [_tempOtherArr addObject:user];
            }
        }
        if (![tempArr count])
            continue;
        [infoDic setObject:tempArr forKey:key];
    }
    if ([_tempOtherArr count])
        [infoDic setObject:_tempOtherArr forKey:@"#"];

    NSArray *keys = [[infoDic allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {

        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    NSMutableArray *allKeys = [[NSMutableArray alloc] initWithArray:keys];

    NSMutableDictionary *resultDic = [NSMutableDictionary new];
    [resultDic setObject:infoDic forKey:@"infoDic"];
    [resultDic setObject:allKeys forKey:@"allKeys"];
    return resultDic;
}

+ (BOOL)isContains:(NSString *)firstString withString:(NSString *)secondString {
    if (firstString.length == 0 || secondString.length == 0) {
        return NO;
    }
    NSString *twoStr = [[secondString stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
    if ([[firstString lowercaseString] containsString:[secondString lowercaseString]] ||
        [[firstString lowercaseString] containsString:twoStr] ||
        [[[self hanZiToPinYinWithString:firstString] lowercaseString] containsString:twoStr]) {
        return YES;
    }
    return NO;
}

+ (UIImage *)getImageWithColor:(UIColor *)color andHeight:(CGFloat)height {
    CGRect r = CGRectMake(0.0f, 0.0f, 1.0f, height);
    UIGraphicsBeginImageContext(r.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, r);

    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (NSString *)getDataString:(long long)time {
    if (time <= 0) {
        return @"0000-00-00 00:00:00";
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time / 1000];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [fmt stringFromDate:date];
    return dateString;
}

+ (CGFloat)getStringHeight:(NSString *)text font:(UIFont *)font viewWidth:(CGFloat)width {
    // 设置文字属性 要和label的一致
    NSDictionary *attrs = @{NSFontAttributeName : font};
    CGSize maxSize = CGSizeMake(width, MAXFLOAT);

    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;

    // 计算文字占据的宽高
    CGSize size = [text boundingRectWithSize:maxSize options:options attributes:attrs context:nil].size;

    // 当你是把获得的高度来布局控件的View的高度的时候.size转化为ceilf(size.height)。
    return ceilf(size.height);
}

+ (BOOL)isLowerLetter:(NSString *)string {
    NSString *firstString = @"";
    if (string.length > 0) {
        firstString = [string substringToIndex:1];
    } else {
        return NO;
    }
    NSString *regex = @"[A-Za-z]+";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([predicate evaluateWithObject:firstString]) {
        return YES;
    }
    return NO;
}

+ (BOOL)judgeSealTalkAccount:(NSString *)string {
    NSString *regex = @"^[A-Za-z0-9_-]+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([predicate evaluateWithObject:string]) {
        return YES;
    }
    return NO;
}

+ (int)getTotalUnreadCount {
    int unreadMsgCount = [[RCIMClient sharedRCIMClient] getUnreadCount:@[
        @(ConversationType_PRIVATE),
        @(ConversationType_APPSERVICE),
        @(ConversationType_PUBLICSERVICE),
        @(ConversationType_GROUP),
        @(ConversationType_SYSTEM)
    ]];
    return unreadMsgCount + (int)[RCDGroupManager getGroupNoticeUnreadCount];
}

+ (void)getGroupUserDisplayInfo:(NSString *)userId groupId:(NSString *)groupId result:(void (^)(RCUserInfo *))result {
    RCDFriendInfo *friend = [RCDUserInfoManager getFriendInfo:userId];
    if (friend && friend.displayName.length > 0) {
        if (friend.portraitUri.length == 0) {
            friend.portraitUri = [self defaultUserPortrait:friend];
        }
        RCUserInfo *user =
            [[RCUserInfo alloc] initWithUserId:userId name:friend.displayName portrait:friend.portraitUri];
        result(user);
        [[RCIM sharedRCIM] refreshGroupUserInfoCache:user withUserId:userId withGroupId:groupId];
    } else {
        [self getUserDisplayInfo:userId
                        complete:^(RCUserInfo *user) {
                            RCDGroupMember *memberDetail = [RCDGroupManager getGroupMember:userId groupId:groupId];
                            if (groupId.length > 0 && memberDetail.groupNickname.length > 0) {
                                user.name = memberDetail.groupNickname;
                            }
                            result(user);
                            [[RCIM sharedRCIM] refreshGroupUserInfoCache:user withUserId:userId withGroupId:groupId];
                        }];
    }
}

+ (void)getUserDisplayInfo:(NSString *)userId complete:(void (^)(RCUserInfo *))completeBlock {
    RCDFriendInfo *friend = [RCDUserInfoManager getFriendInfo:userId];
    if (friend && friend.displayName.length > 0) {
        if (friend.portraitUri.length == 0) {
            friend.portraitUri = [self defaultUserPortrait:friend];
        }
        RCUserInfo *user =
            [[RCUserInfo alloc] initWithUserId:userId name:friend.displayName portrait:friend.portraitUri];
        completeBlock(user);
    } else {
        RCDUserInfo *user = [RCDUserInfoManager getUserInfo:userId];
        if (user) {
            if (user.portraitUri.length == 0) {
                user.portraitUri = [self defaultUserPortrait:user];
            }
            completeBlock(user);
        } else {
            [RCDUserInfoManager getUserInfoFromServer:userId
                                             complete:^(RCDUserInfo *userInfo) {
                                                 if (user.portraitUri.length == 0) {
                                                     user.portraitUri = [self defaultUserPortrait:user];
                                                 }
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     completeBlock(userInfo);
                                                 });
                                             }];
        }
    }
}

/**
 判断字符串是否包含 emoji 表情

 @param string 需要判断的字符串
 @return 是否包含 emoji
 */
+ (BOOL)stringContainsEmoji:(NSString *)string {
    __block BOOL returnValue = NO;
    [string
        enumerateSubstringsInRange:NSMakeRange(0, [string length])
                           options:NSStringEnumerationByComposedCharacterSequences
                        usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {

                            const unichar hs = [substring characterAtIndex:0];
                            // surrogate pair
                            if (0xd800 <= hs && hs <= 0xdbff) {
                                if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                    if (0x1d000 <= uc && uc <= 0x1f77f) {
                                        returnValue = YES;
                                    }
                                }
                            } else if (substring.length > 1) {
                                const unichar ls = [substring characterAtIndex:1];
                                if (ls == 0x20e3) {
                                    returnValue = YES;
                                }
                            } else {
                                // non surrogate
                                if (0x2100 <= hs && hs <= 0x27ff) {
                                    // 区分九宫格输入 U+278b u'➋' -  U+2792 u'➒'
                                    if (0x278b <= hs && hs <= 0x2792) {
                                        returnValue = NO;
                                        // 九宫格键盘上 “^-^” 键所对应的为符号 ☻
                                    } else if (0x263b == hs) {
                                        returnValue = NO;
                                    } else {
                                        returnValue = YES;
                                    }
                                } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                    returnValue = YES;
                                } else if (0x2934 <= hs && hs <= 0x2935) {
                                    returnValue = YES;
                                } else if (0x3297 <= hs && hs <= 0x3299) {
                                    returnValue = YES;
                                } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 ||
                                           hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                    returnValue = YES;
                                }
                            }
                        }];

    return returnValue;
}

+ (UIColor *)generateDynamicColor:(UIColor *)lightColor darkColor:(UIColor *)darkColor {
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor =
            [UIColor colorWithDynamicProvider:^UIColor *_Nonnull(UITraitCollection *_Nonnull traitCollection) {
                if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                    return darkColor;
                } else {
                    return lightColor;
                }
            }];
        return dyColor;
    } else {
        return lightColor;
    }
}

+ (BOOL)includeChinese:(NSString *)string {
    for (int i = 0; i < [string length]; i++) {
        int a = [string characterAtIndex:i];
        if (a > 0x4e00 && a < 0x9fff) {
            return YES;
        }
    }
    return NO;
}

@end
