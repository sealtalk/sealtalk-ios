//
//  NSString+PinYin4Cocoa.h
//  PinYin4Cocoa
//
//  Created by kimziv on 13-9-15.
//  Copyright (c) 2013年 kimziv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (YZHPinYin4Cocoa)

- (NSInteger)yzh_indexOfString:(NSString *)s;
- (NSInteger)yzh_indexOfString:(NSString *)s fromIndex:(int)index;
- (NSInteger)yzh_indexOf:(int)ch;
- (NSInteger)yzh_indexOf:(int)ch fromIndex:(int)index;
+ (NSString *)yzh_valueOfChar:(unichar)value;

-(NSString *) yzh_stringByReplacingRegexPattern:(NSString *)regex withString:(NSString *) replacement;
-(NSString *) yzh_stringByReplacingRegexPattern:(NSString *)regex withString:(NSString *) replacement caseInsensitive:(BOOL) ignoreCase;
-(NSString *) yzh_stringByReplacingRegexPattern:(NSString *)regex withString:(NSString *) replacement caseInsensitive:(BOOL) ignoreCase treatAsOneLine:(BOOL) assumeMultiLine;
-(NSArray *) yzh_stringsByExtractingGroupsUsingRegexPattern:(NSString *)regex;
-(NSArray *) yzh_stringsByExtractingGroupsUsingRegexPattern:(NSString *)regex caseInsensitive:(BOOL) ignoreCase treatAsOneLine:(BOOL) yzh_assumeMultiLine;
-(BOOL) yzh_matchesPatternRegexPattern:(NSString *)regex;
-(BOOL) yzh_matchesPatternRegexPattern:(NSString *)regex caseInsensitive:(BOOL) ignoreCase treatAsOneLine:(BOOL) assumeMultiLine;
@end
