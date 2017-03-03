//
//  ChineseString.h


#import <Foundation/Foundation.h>
//#import "pinyin.h"

@interface YZHChineseString : NSObject
@property(retain,nonatomic)NSString *yzh_string;
@property(retain,nonatomic)NSString *yzh_pinYin;

//-----  返回tableview右方indexArray
+(NSMutableArray*)yzh_IndexArray:(NSArray*)stringArr;

//-----  返回联系人
+(NSMutableArray*)yzh_LetterSortArray:(NSArray*)stringArr;



///----------------------
//返回一组字母排序数组(中英混排)
+(NSMutableArray*)yzh_SortArray:(NSArray*)stringArr;

@end