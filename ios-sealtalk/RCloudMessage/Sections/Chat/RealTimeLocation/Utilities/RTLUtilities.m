//
//  RTLUtilities.m
//  SealTalk
//
//  Created by Jue on 2020/1/7.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RTLUtilities.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "RealTimeLocationDefine.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation RTLUtilities
MBProgressHUD *hud;

+ (void)showHUDAddedTo:(UIView *)superView
                 color:(UIColor *)color
             labelText:(NSString *)labelText
              animated:(BOOL)animated {
    hud = [MBProgressHUD showHUDAddedTo:superView animated:animated];
    hud.color = color;
    hud.labelText = labelText;
    [hud show:YES];
}

+ (void)hideHUDAnimated:(BOOL)animated {
    [hud hideAnimated:animated];
}

+ (void)setImageWithURL:(NSURL *)imageUrl
       placeholderImage:(UIImage *)placeholderImage
              imageView:(UIImageView *)imageView {
    [imageView sd_setImageWithURL:imageUrl placeholderImage:placeholderImage];
}

+ (UIImage *)imageNamed:(NSString *)name ofBundle:(NSString *)bundleName {
    UIImage *image = nil;
    NSString *image_name = name;
    if (![image_name hasSuffix:@".png"]) {
        image_name = [NSString stringWithFormat:@"%@.png", name];
    }
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *bundlePath = [resourcePath stringByAppendingPathComponent:bundleName];
    NSString *image_path = [bundlePath stringByAppendingPathComponent:image_name];

    image = [UIImage imageWithContentsOfFile:image_path];

    return image;
}

+ (BOOL)isRTL {
    return (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_9_0 && [UIView appearance].semanticContentAttribute == UISemanticContentAttributeForceRightToLeft);
}

@end
