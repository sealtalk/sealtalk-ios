//
//  PinYinForObjc.h
//  Search
//
//  Created by LYZ on 14-1-24.
//  Copyright (c) 2014年 LYZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZHHanyuPinyinOutputFormat.h"
#import "YZHPinyinHelper.h"

@interface YZHPinYinForObjc : NSObject

+ (NSString*)yzh_chineseConvertToPinYin:(NSString*)chinese;//转换为拼音
+ (NSString*)yzh_chineseConvertToPinYinHead:(NSString *)chinese;//转换为拼音首字母
@end
