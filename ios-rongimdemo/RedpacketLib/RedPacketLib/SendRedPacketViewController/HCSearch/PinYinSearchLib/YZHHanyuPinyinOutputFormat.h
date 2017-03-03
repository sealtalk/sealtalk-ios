/**
 *	Created by kimziv on 13-9-14.
 */
#ifndef _YZHHanyuPinyinOutputFormat_H_
#define _YZHHanyuPinyinOutputFormat_H_
#import <Foundation/Foundation.h>
typedef enum {
  YZHToneTypeWithToneNumber,
  YZHToneTypeWithoutTone,
  YZHToneTypeWithToneMark
}YZHToneType;

typedef enum {
    YZHCaseTypeUppercase,
    YZHCaseTypeLowercase
}YZHCaseType;

typedef enum {
    YZHVCharTypeWithUAndColon,
    YZHVCharTypeWithV,
    YZHVCharTypeWithUUnicode
}YZHVCharType;


@interface YZHHanyuPinyinOutputFormat : NSObject

@property(nonatomic, assign) YZHVCharType yzh_vCharType;
@property(nonatomic, assign) YZHCaseType yzh_caseType;
@property(nonatomic, assign) YZHToneType yzh_toneType;

- (id)init;
- (void)yzh_restoreDefault;
@end

#endif // _HanyuPinyinOutputFormat_H_
