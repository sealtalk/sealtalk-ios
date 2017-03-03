//
//  
//
//  Created by kimziv on 13-9-14.
//

#ifndef _PinyinFormatter_H_
#define _PinyinFormatter_H_
#import <Foundation/Foundation.h>
@class YZHHanyuPinyinOutputFormat;

@interface YZHPinyinFormatter : NSObject {
}

+ (NSString *)yzh_formatHanyuPinyinWithNSString:(NSString *)pinyinStr
                withHanyuPinyinOutputFormat:(YZHHanyuPinyinOutputFormat *)outputFormat;
+ (NSString *)yzh_convertToneNumber2ToneMarkWithNSString:(NSString *)pinyinStr;
- (id)init;
@end

#endif // _PinyinFormatter_H_
