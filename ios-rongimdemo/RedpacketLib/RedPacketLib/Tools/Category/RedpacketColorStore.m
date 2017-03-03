//
//  UIColor+RedpacketColors.m
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/2/26.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RedpacketColorStore.h"

@implementation RedpacketColorStore

+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha
{
    //删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}

+ (UIColor *)rp_colorWithHEX:(uint)color
{
    float r = (color&0xFF0000) >> 16;
    float g = (color&0xFF00) >> 8;
    float b = (color&0xFF);
    return [RedpacketColorStore flashColorWithRed:r green:g blue:b alpha:1.0f];
}

+ (UIColor *)randomColor
{
    float r = (double)arc4random()/0x100000000;
    float g = (double)arc4random()/0x100000000;
    float b = (double)arc4random()/0x100000000;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

+ (UIColor *)flashColorWithRed:(uint)red green:(uint)green blue:(uint)blue alpha:(float)alpha
{
    float r = red/255.0f;
    float g = green/255.0f;
    float b = blue/255.0f;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
}

+ (UIColor *)colorWithPatternImageName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    
    if (image) {
        return [UIColor colorWithPatternImage:image];
    }
    
    return nil;
}

+ (UIColor *)rp_backGroundColor
{
    return HTHexColor(0xefefef);
}

+ (UIColor *)rp_backGroundGrayColor
{
    return HTHexColor(0xe3e3e3);
}

+ (UIColor *)rp_textColorBlack
{
    return HTHexColor(0x3e3e3e);
}

+ (UIColor *)rp_textColorBlack6
{
    return HTHexColor(0x6e6e6e);
}

+ (UIColor *)rp_textColorGray
{
    return HTHexColor(0x9e9e9e);
}

+ (UIColor *)rp_textColorLightGray
{
    return HTHexColor(0xc7c7c7);
}

+ (UIColor *)rp_textColorRed
{
    return HTHexColor(0xd24f44);
}

+ (UIColor *)rp_textcolorYellow
{
    return HTHexColor(0xd3d97a);
}                                           

+ (UIColor *)rp_textColorBlue
{
    return HTHexColor(0x167ffc);
}

+ (UIColor *)rp_lineColorLightGray
{
    return HTHexColor(0xc7c7c7);
}

+ (UIColor *)rp_redButtonNormalColor
{
    return HTHexColor(0xd24f44);
}

+ (UIColor *)rp_redButtonHighColor
{
    return HTHexColor(0xdb4740);
}

+ (UIColor *)rp_redButtonDisableColor
{
    return HTHexColor(0xf79e99);
}

+ (UIColor *)rp_blueButtonNormalColor
{
    return HTHexColor(0x35b7f3);
}

+ (UIColor *)rp_blueButtonHightColor
{
    return HTHexColor(0x2fa3d9);
}

+ (UIColor *)rp_blueDisableColor
{
    return HTHexColor(0xa5d9f1);
}

+ (UIColor *)rp_headBackGroundColor
{
    return HTHexColor(0xf9f9f9);
}

+ (UIColor *)rp_besetLuckyColor
{
    return HTHexColor(0xfabf40);
}

+ (UIImage *)rp_createImageWithColor:(UIColor*)color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
@end


