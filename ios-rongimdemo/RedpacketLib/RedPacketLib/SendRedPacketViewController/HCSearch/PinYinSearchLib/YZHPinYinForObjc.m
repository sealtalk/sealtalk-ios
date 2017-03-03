//
//  PinYinForObjc.m
//  Search
//
//  Created by LYZ on 14-1-24.
//  Copyright (c) 2014年 LYZ. All rights reserved.
//

#import "YZHPinYinForObjc.h"

@implementation YZHPinYinForObjc

+ (NSString*)yzh_chineseConvertToPinYin:(NSString*)chinese {
    NSString *sourceText = chinese;
    YZHHanyuPinyinOutputFormat *outputFormat = [[YZHHanyuPinyinOutputFormat alloc] init];
    [outputFormat setYzh_toneType:YZHToneTypeWithoutTone];
    [outputFormat setYzh_vCharType:YZHVCharTypeWithV];
    [outputFormat setYzh_caseType:YZHCaseTypeLowercase];
    NSString *outputPinyin = [YZHPinyinHelper yzh_toHanyuPinyinStringWithNSString:sourceText withHanyuPinyinOutputFormat:outputFormat withNSString:@""];
    
    return outputPinyin;
}

+ (NSString*)yzh_chineseConvertToPinYinHead:(NSString *)chinese {
    YZHHanyuPinyinOutputFormat *outputFormat = [[YZHHanyuPinyinOutputFormat alloc] init];
    [outputFormat setYzh_toneType:YZHToneTypeWithoutTone];
    [outputFormat setYzh_vCharType:YZHVCharTypeWithV];
    [outputFormat setYzh_caseType:YZHCaseTypeLowercase];
    NSMutableString *outputPinyin = [[NSMutableString alloc] init];
    for (int i=0;i <chinese.length;i++) {
        NSString *mainPinyinStrOfChar = [YZHPinyinHelper yzh_getFirstHanyuPinyinStringWithChar:[chinese characterAtIndex:i] withHanyuPinyinOutputFormat:outputFormat];
        if (nil!=mainPinyinStrOfChar) {
            [outputPinyin appendString:[mainPinyinStrOfChar substringToIndex:1]];
        } else {
            break;
        }
    }
    return outputPinyin;
}
@end
