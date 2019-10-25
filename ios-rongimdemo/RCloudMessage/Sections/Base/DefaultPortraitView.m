//
//  DefaultPortraitView.m
//  RCloudMessage
//
//  Created by Jue on 16/3/31.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "DefaultPortraitView.h"

@implementation DefaultPortraitView
+ (UIImage *)portraitView:(NSString *)userId name:(NSString *)name {
    NSDictionary *textAttributes =
        @{NSFontAttributeName : [UIFont systemFontOfSize:50], NSForegroundColorAttributeName : [UIColor whiteColor]};
    return [self imageWithColor:[self getDisplayColor:userId]
                           size:CGSizeMake(100, 100)
                           text:[self getDisplayText:name]
                 textAttributes:textAttributes
                       circular:NO];
}

+ (NSString *)getDisplayText:(NSString *)text {
    NSString *firstLetter = nil;
    if (text.length > 0) {
        firstLetter = [text substringToIndex:1];
    } else {
        firstLetter = @"#";
    }
    return firstLetter;
}

+ (UIColor *)getDisplayColor:(NSString *)text {
    if (text.length <= 0) {
        return [self hexStringToColor:@"#e97ffb"];
    }
    //设置背景色
    text = [text uppercaseString]; //设置为大写
    int asciiCode = [text characterAtIndex:0];
    int colorIndex = asciiCode % 5;
    NSArray *colorList =
        [[NSArray alloc] initWithObjects:@"#e97ffb", @"#00b8d4", @"#82b2ff", @"#f3db73", @"#f0857c", nil];
    return [self hexStringToColor:colorList[colorIndex]];
}

+ (UIColor *)hexStringToColor:(NSString *)stringToConvert {
    NSString *cString = [[stringToConvert
        stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters

    if ([cString length] < 6)
        return [UIColor blackColor];
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor blackColor];

    // Separate into r, g, b substrings

    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;

    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];

    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:1.0f];
}

/**
 绘制图片

 @param color 背景色
 @param size 大小
 @param text 文字
 @param textAttributes 字体设置
 @param isCircular 是否圆形
 @return 图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color
                       size:(CGSize)size
                       text:(NSString *)text
             textAttributes:(NSDictionary *)textAttributes
                   circular:(BOOL)isCircular {
    if (!color || size.width <= 0 || size.height <= 0)
        return nil;
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    // circular
    if (isCircular) {
        CGPathRef path = CGPathCreateWithEllipseInRect(rect, NULL);
        CGContextAddPath(context, path);
        CGContextClip(context);
        CGPathRelease(path);
    }

    // color
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);

    // text
    CGSize textSize = [text sizeWithAttributes:textAttributes];
    [text drawInRect:CGRectMake((size.width - textSize.width) / 2, (size.height - textSize.height) / 2, textSize.width,
                                textSize.height)
        withAttributes:textAttributes];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
