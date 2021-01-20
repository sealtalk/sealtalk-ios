//
//  RealTimeLocationDefine.h
//  SealTalk
//
//  Created by Jue on 2020/1/7.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#ifndef RealTimeLocationDefine_h
#define RealTimeLocationDefine_h
#import <RongIMKit/RCKitCommonDefine.h>
#define RTLLocalizedString(key) NSLocalizedStringFromTable(key, @"RealTimeLocation", nil)

#define RTLScreenWidth [UIScreen mainScreen].bounds.size.width
#define RTLScreenHeight [UIScreen mainScreen].bounds.size.height
#define UIColorFromRGB(rgbValue, alphaValue)                                                                           \
    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0                                               \
                    green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0                                                  \
                     blue:((float)(rgbValue & 0xFF)) / 255.0                                                           \
                    alpha:(float)alphaValue]

#define RTLIsIPad [[UIDevice currentDevice].model containsString:@"iPad"]

#endif /* RealTimeLocationDefine_h */
