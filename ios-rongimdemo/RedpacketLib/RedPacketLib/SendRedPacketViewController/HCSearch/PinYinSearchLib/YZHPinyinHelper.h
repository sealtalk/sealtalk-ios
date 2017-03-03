//
//  
//
//  Created by kimziv on 13-9-14.
//

#ifndef _PinyinHelper_H_
#define _PinyinHelper_H_
#import <Foundation/Foundation.h>
@class YZHHanyuPinyinOutputFormat;

@interface YZHPinyinHelper : NSObject {
}

+ (NSArray *)yzh_toHanyuPinyinStringArrayWithChar:(unichar)ch;
+ (NSArray *)yzh_toHanyuPinyinStringArrayWithChar:(unichar)ch
                         withHanyuPinyinOutputFormat:(YZHHanyuPinyinOutputFormat *)outputFormat;
+ (NSArray *)yzh_getFormattedHanyuPinyinStringArrayWithChar:(unichar)ch
                                   withHanyuPinyinOutputFormat:(YZHHanyuPinyinOutputFormat *)outputFormat;
+ (NSArray *)yzh_getUnformattedHanyuPinyinStringArrayWithChar:(unichar)ch;
+ (NSArray *)yzh_toTongyongPinyinStringArrayWithChar:(unichar)ch;
+ (NSArray *)yzh_toWadeGilesPinyinStringArrayWithChar:(unichar)ch;
+ (NSArray *)yzh_toMPS2PinyinStringArrayWithChar:(unichar)ch;
+ (NSArray *)yzh_toYalePinyinStringArrayWithChar:(unichar)ch;
+ (NSArray *)yzh_convertToTargetPinyinStringArrayWithChar:(unichar)ch
                                  withPinyinRomanizationType:(NSString *)targetPinyinSystem;
+ (NSArray *)yzh_toGwoyeuRomatzyhStringArrayWithChar:(unichar)ch;
+ (NSArray *)yzh_convertToGwoyeuRomatzyhStringArrayWithChar:(unichar)ch;
+ (NSString *)yzh_toHanyuPinyinStringWithNSString:(NSString *)str
                  withHanyuPinyinOutputFormat:(YZHHanyuPinyinOutputFormat *)outputFormat
                                 withNSString:(NSString *)seperater;
+ (NSString *)yzh_getFirstHanyuPinyinStringWithChar:(unichar)ch
                    withHanyuPinyinOutputFormat:(YZHHanyuPinyinOutputFormat *)outputFormat;
- (id)yzh_init;
@end

#endif // _PinyinHelper_H_
