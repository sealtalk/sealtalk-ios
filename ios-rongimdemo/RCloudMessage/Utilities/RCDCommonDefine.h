//
//  RCDCommonDefine.h
//  RCloudMessage
//
//  Created by 杜立召 on 15/3/19.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#ifndef RCloudMessage_RCDCommonDefine_h
#define RCloudMessage_RCDCommonDefine_h

#define DEFAULTS [NSUserDefaults standardUserDefaults]
#define ShareApplicationDelegate [[UIApplication sharedApplication] delegate]
#define HEXCOLOR(rgbValue)                                                                                             \
    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0                                               \
                    green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0                                                  \
                     blue:((float)(rgbValue & 0xFF)) / 255.0                                                           \
                    alpha:1.0]
#define IOS_FSystenVersion ([[[UIDevice currentDevice] systemVersion] floatValue])

#define RCDDebugTestFunction 0

#define RCDPrivateCloudManualMode 0

#define RCDscreenWidth [UIScreen mainScreen].bounds.size.width
#define RCDscreenHeight [UIScreen mainScreen].bounds.size.height

#define RCD_IS_IPHONEX (RCDscreenWidth>=375.0f && RCDscreenHeight>=812.0f)
#define RCDExtraBottomHeight (RCD_IS_IPHONEX ? 34 : 0)
#define RCDExtraTopHeight (RCD_IS_IPHONEX ? 24 : 0)
#define RCDIsIPad [[UIDevice currentDevice].model containsString:@"iPad"]

#endif
