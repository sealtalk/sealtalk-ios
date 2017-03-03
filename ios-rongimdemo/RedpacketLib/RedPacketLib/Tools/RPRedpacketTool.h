//
//  RPRedpacketTool.h
//  RedpacketRequestDataLib
//
//  Created by Mr.Yang on 16/7/26.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YZHBaseViewController.h"


/*---------------------------------------
 *  Defines
 ---------------------------------------*/


#define rpWeakSelf __weak typeof(self) weakSelf = self

#define rpURL(...) [NSURL URLWithString:__VA_ARGS__]

#define rpString(...) [NSString stringWithFormat:__VA_ARGS__]

#define RPDebugOpen  [YZHRedpacketBridge sharedBridge].isDebug

#define RPDebug(...)\
if(RPDebugOpen) {\
    NSLog(__VA_ARGS__);\
}\

#define RPAssert(condition, message)\
if(!(condition) && (RPDebugOpen)) {\
    NSLog(message);\
    NSAssert(condition, message);\
}\

#define RPDealloc     RPDebug(@"~~dealloc:%@", NSStringFromClass([self class]));
#define rpCurrentBundle  [NSBundle bundleForClass:[YZHBaseViewController class]]

#define rpRedpacketBundlePath [rpCurrentBundle pathForResource:@"RedpacketBundle" ofType:@"bundle"]

#define rpRedpacketBundleResource(__resource__) rpString(@"%@/%@", rpRedpacketBundlePath, __resource__)

#define rpImageNamed(__image__)  [UIImage imageNamed:__image__]
#define rpImageFilePath(__image__) [UIImage imageWithContentsOfFile:__image__]
#define rpImageSuffix(__image__)    rpString(@"%@.png", __image__)
#define rpRedpacketBundleImage(__image__) rpImageFilePath(rpRedpacketBundleResource(rpImageSuffix(__image__)))


UIKIT_STATIC_INLINE UIColor * rp_hexColor(uint color)
{
    float r = (color&0xFF0000) >> 16;
    float g = (color&0xFF00) >> 8;
    float b = (color&0xFF);
    
    return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f];
}

UIImage *rp_imageWithColor(UIColor *color);


@interface RPRedpacketTool : NSObject


@end
