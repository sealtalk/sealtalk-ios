//
//  RCDCommonDefine.h
//  RCloudMessage
//
//  Created by 杜立召 on 15/3/19.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#ifndef RCloudMessage_RCDCommonDefine_h
#define RCloudMessage_RCDCommonDefine_h
#define RCDGroupNoticeTargetId @"__group_apply__"
#define RCDOpenQRCodeUrlNotification @"RCDOpenQRCodeUrlNotification"
#define RCDQRCodeContentInfoUrl @"http://web.sealtalk.im/download"

#define SealTalkLog(s, ...) NSLog((@"[SealTalkLog]%s [Line %d] " s), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#define RCDMetionAllUsetId @"All"

#define DEFAULTS [NSUserDefaults standardUserDefaults]
#define ShareApplicationDelegate [[UIApplication sharedApplication] delegate]
#define HEXCOLOR(rgbValue)                                                                                             \
    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0                                               \
                    green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0                                                  \
                     blue:((float)(rgbValue & 0xFF)) / 255.0                                                           \
                    alpha:1.0]
#define RCDDYCOLOR(lrgbValue, drgbValue)                                                                               \
    [RCDUtilities generateDynamicColor:HEXCOLOR(lrgbValue) darkColor:HEXCOLOR(drgbValue)]

#define IOS_FSystenVersion ([[[UIDevice currentDevice] systemVersion] floatValue])

#define RCDDebugTestFunction 0

#define RCDScreenWidth [UIScreen mainScreen].bounds.size.width
#define RCDScreenHeight [UIScreen mainScreen].bounds.size.height

#define RCD_IS_IPHONEX (RCDScreenWidth >= 375.0f && RCDScreenHeight >= 812.0f)
#define RCDExtraBottomHeight (RCD_IS_IPHONEX ? 34 : 0)
#define RCDExtraTopHeight (RCD_IS_IPHONEX ? 24 : 0)
#define RCDIsIPad [[UIDevice currentDevice].model containsString:@"iPad"]

#define rcd_dispatch_main_async_safe(block)                                                                            \
    if ([NSThread isMainThread]) {                                                                                     \
        block();                                                                                                       \
    } else {                                                                                                           \
        dispatch_async(dispatch_get_main_queue(), block);                                                              \
    }
#endif

//#define USE_SignalingKit true
