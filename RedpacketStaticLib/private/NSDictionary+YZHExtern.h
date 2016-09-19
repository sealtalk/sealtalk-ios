
//  Created by Hunter on 13-03-16.
//  Copyright (c) 2013年 Hunter. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  json parse 解析字典
 */
@interface NSDictionary (YZHExtern)

/**
 *  json parse: return @"暂无数据" if the string is @"" or return nil if the object is null or not a String.
 */
- (NSString *)rp_stringForKey:(id)key;

/**
 *  json parse: return intStringValue or return nil if the object is null or not a String.
 */
- (NSString *)rp_stringIntForKey:(id)key;

/**
 *  json parse: return DoubleStringValue or return nil if the object is null or not a String.
 */
- (NSString *)rp_stringDoubleValueForKey:(id) key;

/**
 *  json parse: return FloatStringValue or return nil if the object is null or not a String.
 */
- (NSString *)rp_stringFloatForKey:(id)key;

/**
 *  json parse: return nil if the object is null or not a NSDictionary.
 */
- (NSDictionary *)rp_dictionaryForKey:(id)key;

/**
 *  json parse: return nil if the object is null or not a NSMutableArray.
 */
- (NSMutableArray *)rp_arrayForKey:(id)key;


@end
