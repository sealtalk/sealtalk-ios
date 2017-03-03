//
//  RPUntility.m
//  RedpacketLib
//
//  Created by 都基鹏 on 16/7/26.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPUntility.h"
#define ACCEPTABLE_CHARECTERS @"0123456789"
#define ACCEPTABLEDECIMA_CHARECTERS @"."

@implementation RPUntility

+ (RPCheckNmuberStringType)checkNumberString:(NSString *)string
                                decimalLimit:(NSNumber*)decimalLimit
                                  wholeLimit:(NSNumber*)wholeLimit
                                   minNumber:(NSNumber*)minNumber
                                   maxNumber:(NSNumber*)maxNumber
                               decimalLength:(NSNumber**)decimalLength
                                 wholeLength:(NSNumber**)wholeLength;
{
    if (!string.length) return RPNmuberStringSuccess;
    
    NSMutableString * charectersString = ACCEPTABLE_CHARECTERS.mutableCopy;
    if (decimalLimit.integerValue > 0) [charectersString appendString:ACCEPTABLEDECIMA_CHARECTERS];
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:charectersString] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    if (![string isEqualToString:filtered]) return RPNmuberStringInputError;
    
    NSArray * numberList = [string componentsSeparatedByString:ACCEPTABLEDECIMA_CHARECTERS];
    if (numberList.count > 2) return RPNmuberStringDecimalError;
    
    if (numberList.count > 0) {
        NSString * wholeNumberString = [numberList objectAtIndex:0];
        if (wholeLength) *wholeLength = @(wholeNumberString.length);
        if (wholeNumberString.length > wholeLimit.integerValue) return RPNmuberStringWholeLimitError;
        
        if (numberList.count >1) {
            NSString * decimalNumberString = [numberList objectAtIndex:1];
            if (decimalLength) *decimalLength = @(decimalNumberString.length);
            if (decimalNumberString.length > decimalLimit.integerValue) return RPNmuberStringDecimalLimitError;
        }
    }
    
    switch ([@(string.floatValue) compare:minNumber]) {
        case NSOrderedAscending:
            return RPNmuberStringMinNumberError;
            break;
        default:
            break;
    }
    switch ([@(string.floatValue) compare:maxNumber]) {
        case NSOrderedDescending:
            return RPNmuberStringMaxNumberError;
            break;
        default:
            break;
    }
    return RPNmuberStringSuccess;
}
@end
