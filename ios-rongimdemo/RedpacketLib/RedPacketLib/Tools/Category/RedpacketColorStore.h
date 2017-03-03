//
//  UIColor+RedpacketColors.h
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/2/26.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define  HTHexColor(hex)        [RedpacketColorStore rp_colorWithHEX:hex]


@interface RedpacketColorStore : NSObject

+ (UIColor *)rp_colorWithHEX:(uint)color;

+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

+ (UIColor *)randomColor;

+ (UIColor *)flashColorWithRed:(uint)red green:(uint)green blue:(uint)blue alpha:(float)alpha;

+ (UIColor *)colorWithPatternImageName:(NSString *)imageName;

+ (UIColor *)rp_backGroundColor;

+ (UIColor *)rp_backGroundGrayColor;

+ (UIColor *)rp_textColorBlack;

+ (UIColor *)rp_textColorBlack6;

+ (UIColor *)rp_textColorGray;

+ (UIColor *)rp_textColorLightGray;

+ (UIColor *)rp_textColorRed;

+ (UIColor *)rp_textcolorYellow;

+ (UIColor *)rp_textColorBlue;

+ (UIColor *)rp_lineColorLightGray;

+ (UIColor *)rp_redButtonNormalColor;

+ (UIColor *)rp_redButtonHighColor;

+ (UIColor *)rp_redButtonDisableColor;

+ (UIColor *)rp_blueButtonNormalColor;

+ (UIColor *)rp_blueButtonHightColor;

+ (UIColor *)rp_blueDisableColor;
+ (UIColor *)rp_besetLuckyColor;
//头像默认灰
+ (UIColor *)rp_headBackGroundColor;

//生成纯颜色图片
+ (UIImage *)rp_createImageWithColor:(UIColor*)color;


@end
