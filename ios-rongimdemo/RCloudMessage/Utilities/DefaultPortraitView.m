//
//  DefaultPortraitView.m
//  RCloudMessage
//
//  Created by Jue on 16/3/31.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "DefaultPortraitView.h"
#import "pinyin.h"

@implementation DefaultPortraitView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)setColorAndLabel:(NSString *)userId Nickname:(NSString *)nickname {
    //设置背景色

    userId = [userId uppercaseString]; //设置为大写
    int asciiCode = [userId characterAtIndex:0];
    int colorIndex = asciiCode % 5;
    NSArray *colorList =
        [[NSArray alloc] initWithObjects:@"#e97ffb", @"#00b8d4", @"#82b2ff", @"#f3db73", @"#f0857c", nil];
    NSString *backgroundColorStr = colorList[colorIndex];
    self.backgroundColor = [self hexStringToColor:backgroundColorStr];

    //设置字母Label
    UILabel *firstCharacterLabel = [[UILabel alloc] init];

    NSString *firstLetter = nil;
    if (nickname.length > 0) {
        firstLetter = [nickname substringToIndex:1];
    } else {
        firstLetter = @"#";
    }
    firstCharacterLabel.text = firstLetter;
    firstCharacterLabel.textColor = [UIColor whiteColor];
    firstCharacterLabel.textAlignment = NSTextAlignmentCenter;
    firstCharacterLabel.font = [UIFont systemFontOfSize:50];
    firstCharacterLabel.frame = CGRectMake(self.frame.size.width / 2 - 30, self.frame.size.height / 2 - 30, 60, 60);
    //    firstCharacterLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:firstCharacterLabel];

    //    NSDictionary *views=NSDictionaryOfVariableBindings(firstCharacterLabel);
    //
    //    [self addConstraints:[NSLayoutConstraint
    //    constraintsWithVisualFormat:@"V:|-10-[firstCharacterLabel(60)]"
    //    options:0 metrics:nil views:views]];
    //
    //    [self addConstraints:[NSLayoutConstraint
    //    constraintsWithVisualFormat:@"H:|-10-[firstCharacterLabel(60)]"
    //    options:0 metrics:nil views:views]];

    //    [self addConstraint:[NSLayoutConstraint
    //                         constraintWithItem:firstCharacterLabel
    //                         attribute:NSLayoutAttributeCenterY
    //                         relatedBy:NSLayoutRelationEqual
    //                         toItem:self
    //                         attribute:NSLayoutAttributeCenterY
    //                         multiplier:1.0f
    //                         constant:0
    //                         ]];
    //    [self addConstraint:[NSLayoutConstraint
    //                         constraintWithItem:firstCharacterLabel
    //                         attribute:NSLayoutAttributeCenterX
    //                         relatedBy:NSLayoutRelationEqual
    //                         toItem:self
    //                         attribute:NSLayoutAttributeCenterX
    //                         multiplier:1.0f
    //                         constant:0
    //                         ]];
}

- (UIColor *)hexStringToColor:(NSString *)stringToConvert {
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

- (UIImage *)imageFromView {

    UIGraphicsBeginImageContext(self.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return theImage;
}

- (UIImage *)captureWithView {
    // 1.开启上下文
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);

    // 2.将控制器view的layer渲染到上下文
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];

    // 3.取出图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

    // 4.结束上下文
    UIGraphicsEndImageContext();

    return newImage;
}

@end
