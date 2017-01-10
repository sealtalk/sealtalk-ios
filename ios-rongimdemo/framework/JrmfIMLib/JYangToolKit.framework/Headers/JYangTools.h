//
//  JYangTools.h
//  JYangToolKit
//
//  Created by 金阳 on 16/3/18.
//  Copyright © 2016年 JYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JYangTools : NSObject

/**
 *  获取规定文字在规定范围的Size
 *
 *  @param text 默认文本
 *  @param size 规定范围
 *  @param font 字体大小
 *
 *  @return 文本Size值
 */
+ (CGSize)getSize:(NSString *)text sizeBy:(CGSize)size font:(UIFont *)font;


/**
 *  获取字符串末4位数
 *
 *  @param sourceString 源字符串
 *
 *  @return 末4位字符串
 */
+ (NSString *)getLastForthStringFromString:(NSString *)sourceString;


/**
 *  网络地址的汉字转换操作
 *
 *  @param dataString 待格式化网址
 *
 *  @return 标准网络地址
 */
+ (NSString *)getFormatURLFromString:(NSString *)dataString;

/**
 *  身份证号校验
 *
 *  @param value 输入的字符串
 *
 *  @return YES 正确  NO 错误
 */
+ (BOOL)validateIDCardNumber:(NSString *)value;

/**
 *  银行卡号校验
 *
 *  @param _text 输入的银行卡号
 *
 *  @return YES 正确  NO 错误
 */
+ (BOOL)CheckCardNumberInput:(NSString *)_text;


/**
 *  alert信息弹框
 *
 *  @param msg     展示信息
 *  @param presentVC iOS9 之后的present视图
 */
+ (void)showAlertViewWithMsg:(NSString*)msg presentVC:(UIViewController *)presentVC;

/**
 *  alert信息弹框
 *
 *  @param msg          展示信息
 *  @param delegate     代理
 *  @param btntxt       按钮文字
 *  @param handler      按钮回调
 *  @param tag          Tag值
 */
+ (void)showAlertViewWithMsg:(NSString*)msg alertViewDelegate:(UIViewController *)delegate btnTxt:(NSString *)btntxt handler:(void (^)())handler tag:(NSInteger)tag;

/**
 *  alert信息弹框
 *
 *  @param viewController 展示视图
 *  @param msg            信息
 *  @param lTxt           左按钮文字
 *  @param leftHandler    左按钮回调
 *  @param rTxt           右按钮文字
 *  @param rightHandler   右按钮回调
 *  @param tag            Tag值
 */
+ (void)showAlertView:(UIViewController *)viewController message:(NSString *)msg leftTxt:(NSString *)lTxt leftHandler:(void (^)())leftHandler rightTxt:(NSString *)rTxt rightHandler:(void (^)())rightHandler tag:(NSInteger)tag;


/**
 *  校验手机号是否合法
 *
 *  @param _text    手机号
 *
 *  @return         YES 正确  NO 错误
 */
+(BOOL)CheckPhoneInput:(NSString *)_text;

/**
 *  判空
 *
 *  @param string   输入的字符串
 *
 *  @return         是否为空
 */
+ (BOOL)CheckEmptyWithString:(NSString *)string;

/**
 *  格式化身份证号码
 *
 *  @param sourceString 原字符串
 *
 *  @return 格式化后的身份证号码
 */
+ (NSString *)getIDCardNumberHideFromString:(NSString *)sourceString;

/**
 *  获取时间戳
 *
 *  @return 时间戳
 */
+ (NSString*)getCurTimeLong;

/**
 时间戳转日期

 @param stemp 时间戳

 @return 日期
 */
+ (NSString *)getCurTimeDateWithTimeStemp:(NSString *)stemp;

/**
 *  时间戳间隔是否为1Min
 *
 *  @param string   比较时间戳
 *
 *  @return         YES:超过1Min; NO:没超过1Min
 */
+ (NSInteger)isTimeStempForOneMinutes:(NSString *)string;

/**
 *  从bundle中读取图片
 *
 *  @param name 图片名称
 *
 *  @return image
 */

+ (UIImage*)imagesNamedFromCustomBundle:(NSString *)name;

/**
 *  从bundle中读取图片

 @param bundle bundle名称
 @param name 图片名称
 @return image
 */
+ (UIImage*)imagesNamedFromCustomBundle:(NSString *)bundle imgName:(NSString *)name;

/**
 *  格式化电话号码（131****761）
 *
 *  @param sourceString 源字符串
 *
 *  @return             格式化后字符串
 */
+ (NSString *)getPhoneNumberHideFromString:(NSString *)sourceString;

/**
 *  16进制制色
 *
 *  @param color        16进制字符串 支持@“#123456”、 @“0X123456”、 @“123456”三种格式
 *  @param alpha        透明度
 *  @param defaultColor 默认颜色
 *
 *  @return UIColor类型
 */
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha defaultColor:(UIColor *)defaultColor;

/**
 *  base64编码
 *
 *  @param string 源字符串
 *
 *  @return 编码后字符串
 */
+ (NSString *)stringByBase64Encode:(NSString *)string;

/**
 *  base64解码
 *
 *  @param string base64字符串
 *
 *  @return 解码字符串
 */
+ (NSString *)stringByBase64Decode:(NSString *)string;

/**
 *  银行卡简单格式校验
 *
 *  @param cardNo 待校验银行卡号
 *
 *  @return 格式是否正确
 */
+ (BOOL)checkBankCardNo:(NSString*)cardNo;

/**
 颜色生成图片

 @param color 颜色值
 @return 图片
 */
+ (UIImage *)createImageWithColor:(UIColor *) color;

/**
 去除字符串首尾空格
 
 @param string 源字符串
 @return 格式化后字符串
 */
+ (NSString *)TrimmingSpaceCharacterWithString:(NSString *)string;


@end
