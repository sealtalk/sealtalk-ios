//
//
//
//  Created by kimziv on 13-9-14.
//

#include "YZHChineseToPinyinResource.h"
#include "YZHHanyuPinyinOutputFormat.h"
#include "YZHPinyinFormatter.h"
#include "YZHPinyinHelper.h"

#define YZH_HANYU_PINYIN @"Hanyu"
#define YZH_WADEGILES_PINYIN @"Wade"
#define YZH_MPS2_PINYIN @"MPSII"
#define YZH_YALE_PINYIN @"Yale"
#define YZH_TONGYONG_PINYIN @"Tongyong"
#define YZH_GWOYEU_ROMATZYH @"Gwoyeu"

@implementation YZHPinyinHelper

+ (NSArray *)yzh_toHanyuPinyinStringArrayWithChar:(unichar)ch {
    return [YZHPinyinHelper yzh_getUnformattedHanyuPinyinStringArrayWithChar:ch];
}

+ (NSArray *)yzh_toHanyuPinyinStringArrayWithChar:(unichar)ch
                  withHanyuPinyinOutputFormat:(YZHHanyuPinyinOutputFormat *)outputFormat {
    return [YZHPinyinHelper yzh_getFormattedHanyuPinyinStringArrayWithChar:ch withHanyuPinyinOutputFormat:outputFormat];
}

+ (NSArray *)yzh_getFormattedHanyuPinyinStringArrayWithChar:(unichar)ch
                            withHanyuPinyinOutputFormat:(YZHHanyuPinyinOutputFormat *)outputFormat {
    NSMutableArray *pinyinStrArray =[NSMutableArray arrayWithArray:[YZHPinyinHelper yzh_getUnformattedHanyuPinyinStringArrayWithChar:ch]];
    if (nil != pinyinStrArray) {
        for (int i = 0; i < (int) [pinyinStrArray count]; i++) {
            [pinyinStrArray replaceObjectAtIndex:i withObject:[YZHPinyinFormatter yzh_formatHanyuPinyinWithNSString:
                                                               [pinyinStrArray objectAtIndex:i]withHanyuPinyinOutputFormat:outputFormat]];
        }
        return pinyinStrArray;
    }
    else return nil;
}

+ (NSArray *)yzh_getUnformattedHanyuPinyinStringArrayWithChar:(unichar)ch {
    return [[YZHChineseToPinyinResource yzh_getInstance] yzh_getHanyuPinyinStringArrayWithChar:ch];
}

+ (NSArray *)yzh_toTongyongPinyinStringArrayWithChar:(unichar)ch {
    return [YZHPinyinHelper yzh_convertToTargetPinyinStringArrayWithChar:ch withPinyinRomanizationType: YZH_TONGYONG_PINYIN];
}

+ (NSArray *)yzh_toWadeGilesPinyinStringArrayWithChar:(unichar)ch {
    return [YZHPinyinHelper yzh_convertToTargetPinyinStringArrayWithChar:ch withPinyinRomanizationType: YZH_WADEGILES_PINYIN];
}

+ (NSArray *)yzh_toMPS2PinyinStringArrayWithChar:(unichar)ch {
    return [YZHPinyinHelper yzh_convertToTargetPinyinStringArrayWithChar:ch withPinyinRomanizationType: YZH_MPS2_PINYIN];
}

+ (NSArray *)yzh_toYalePinyinStringArrayWithChar:(unichar)ch {
    return [YZHPinyinHelper yzh_convertToTargetPinyinStringArrayWithChar:ch withPinyinRomanizationType: YZH_YALE_PINYIN];
}

+ (NSArray *)yzh_convertToTargetPinyinStringArrayWithChar:(unichar)ch
                           withPinyinRomanizationType:(NSString *)targetPinyinSystem {
    NSArray *hanyuPinyinStringArray = [YZHPinyinHelper yzh_getUnformattedHanyuPinyinStringArrayWithChar:ch];
    if (nil != hanyuPinyinStringArray) {
        NSMutableArray *targetPinyinStringArray = [NSMutableArray arrayWithCapacity:hanyuPinyinStringArray.count];
        for (int i = 0; i < (int) [hanyuPinyinStringArray count]; i++) {
            
        }
        return targetPinyinStringArray;
    }
    else return nil;
}

+ (NSArray *)yzh_toGwoyeuRomatzyhStringArrayWithChar:(unichar)ch {
    return [YZHPinyinHelper yzh_convertToGwoyeuRomatzyhStringArrayWithChar:ch];
}

+ (NSArray *)yzh_convertToGwoyeuRomatzyhStringArrayWithChar:(unichar)ch {
    NSArray *hanyuPinyinStringArray = [YZHPinyinHelper yzh_getUnformattedHanyuPinyinStringArrayWithChar:ch];
    if (nil != hanyuPinyinStringArray) {
        NSMutableArray *targetPinyinStringArray =[NSMutableArray arrayWithCapacity:hanyuPinyinStringArray.count];
        for (int i = 0; i < (int) [hanyuPinyinStringArray count]; i++) {
        }
        return targetPinyinStringArray;
    }
    else return nil;
}

+ (NSString *)yzh_toHanyuPinyinStringWithNSString:(NSString *)str
                  withHanyuPinyinOutputFormat:(YZHHanyuPinyinOutputFormat *)outputFormat
                                 withNSString:(NSString *)seperater {
    NSMutableString *resultPinyinStrBuf = [[NSMutableString alloc] init];
    for (int i = 0; i <  str.length; i++) {
        NSString *mainPinyinStrOfChar = [YZHPinyinHelper yzh_getFirstHanyuPinyinStringWithChar:[str characterAtIndex:i] withHanyuPinyinOutputFormat:outputFormat];
        if (nil != mainPinyinStrOfChar) {
            [resultPinyinStrBuf appendString:mainPinyinStrOfChar];
            if (i != [str length] - 1) {
                [resultPinyinStrBuf appendString:seperater];
            }
        }
        else {
            [resultPinyinStrBuf appendFormat:@"%C",[str characterAtIndex:i]];
        }
    }
    return resultPinyinStrBuf;
}

+ (NSString *)yzh_getFirstHanyuPinyinStringWithChar:(unichar)ch
                    withHanyuPinyinOutputFormat:(YZHHanyuPinyinOutputFormat *)outputFormat {
    NSArray *pinyinStrArray = [YZHPinyinHelper yzh_getFormattedHanyuPinyinStringArrayWithChar:ch withHanyuPinyinOutputFormat:outputFormat];
    if ((nil != pinyinStrArray) && ((int) [pinyinStrArray count] > 0)) {
        return [pinyinStrArray objectAtIndex:0];
    }
    else {
        return nil;
    }
}

- (id)yzh_init {
    return [super init];
}

@end
