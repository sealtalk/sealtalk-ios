//
//  RPUntility.h
//  RedpacketLib
//
//  Created by 都基鹏 on 16/7/26.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,RPCheckNmuberStringType){
    RPNmuberStringSuccess           = 0, //符合校验规则
    RPNmuberStringInputError        = 1, //输入不为数字
    RPNmuberStringDecimalError      = 2, //当前数字不符合规范
    RPNmuberStringWholeLimitError   = 3, //整数位位数越界
    RPNmuberStringDecimalLimitError = 4, //小数位位数越界
    RPNmuberStringMinNumberError    = 5, //小于最小数
    RPNmuberStringMaxNumberError    = 6, //大于最大数
};
@interface RPUntility : NSObject

/**
 *  校验数字
 *
 *  @param string       number string
 *  @param decimalLimit 小数位数
 *  @param wholeLimit   整数位数
 *  @param minNumber    最小数
 *  @param maxNumber    最大数
 *
 *  @return 校验结果
 */
+ (RPCheckNmuberStringType)checkNumberString:(NSString *)string
                                decimalLimit:(NSNumber*)decimalLimit
                                  wholeLimit:(NSNumber*)wholeLimit
                                   minNumber:(NSNumber*)minNumber
                                   maxNumber:(NSNumber*)maxNumber
                               decimalLength:(NSNumber**)decimalLength
                                 wholeLength:(NSNumber**)wholeLength;
@end
