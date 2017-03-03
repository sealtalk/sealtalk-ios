//
//  RPRedpacketViews.m
//  RedpacketLib
//
//  Created by Mr.Yang on 16/8/9.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPRedpacketViews.h"


@implementation RPRedpacketViews

+ (UIButton *)redpacketBlueButtonWithTitle:(NSString *)title
                               andSelector:(SEL)aSelector
                                 andTarget:(id)target
{
    NSArray *colors = @[[RedpacketColorStore rp_blueButtonNormalColor],
                        [RedpacketColorStore rp_blueButtonHightColor],
                        [RedpacketColorStore rp_blueDisableColor]];
    return [self buttonWithColors:colors withTitle:title andSelector:aSelector andTarget:target];
}

+ (UIButton *)redpacketRedButtonWithTitle:(NSString *)title
                              andSelector:(SEL)aSelector
                                andTarget:(id)target
{
    NSArray *colors = @[[RedpacketColorStore rp_redButtonNormalColor],
                        [RedpacketColorStore rp_redButtonHighColor],
                        [RedpacketColorStore rp_redButtonDisableColor]];
    
     return [self buttonWithColors:colors withTitle:title andSelector:aSelector andTarget:target];
}

+ (UIButton *)buttonWithColors:(NSArray <UIColor *> *)colors
                     withTitle:(NSString *)title
                   andSelector:(SEL)aSelector
                     andTarget:(nullable id)target
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(15, 0, [UIScreen mainScreen].bounds.size.width - 30, 44);
    //设置默认色
    [button setBackgroundImage:rp_imageWithColor(colors[0]) forState:UIControlStateNormal];
    
    //设置高亮颜色
    [button setBackgroundImage:rp_imageWithColor(colors[1]) forState:UIControlStateHighlighted];
    
    //设置disable颜色
    [button setBackgroundImage:rp_imageWithColor(colors[2]) forState:UIControlStateDisabled];
    
    button.titleLabel.font = [UIFont systemFontOfSize:17.0];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [button setTintColor:[UIColor whiteColor]];
    //    button.layer.borderWidth = 1;
    //    button.layer.borderColor = [UIColor clearColor].CGColor;
    button.layer.cornerRadius = 3.0;
    button.layer.masksToBounds = YES;
    
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:aSelector forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}


@end
