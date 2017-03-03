//
//  
//
//  Created by kimziv on 13-9-14.
//

#ifndef _YZHChineseToPinyinResource_H_
#define _YZHChineseToPinyinResource_H_
#import <Foundation/Foundation.h>
@class NSArray;
@class NSMutableDictionary;

@interface YZHChineseToPinyinResource : NSObject {
    NSString* _yzh_directory;
    NSDictionary *_yzh_unicodeToHanyuPinyinTable;
}
//@property(nonatomic, strong)NSDictionary *unicodeToHanyuPinyinTable;

- (id)init;
- (void)yzh_initializeResource;
- (NSArray *)yzh_getHanyuPinyinStringArrayWithChar:(unichar)ch;
- (BOOL)yzh_isValidRecordWithNSString:(NSString *)record;
- (NSString *)yzh_getHanyuPinyinRecordFromCharWithChar:(unichar)ch;
+ (YZHChineseToPinyinResource *)yzh_getInstance;

@end



#endif // _ChineseToPinyinResource_H_
