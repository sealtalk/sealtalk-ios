//
//  JYangLib.h
//  JYangToolKit
//
//  Created by 一路财富 on 16/10/11.
//  Copyright © 2016年 JYang. All rights reserved.
//

//  注：该framework为金融魔方SDK工具类，若集成多个金融魔方SDK，导入一个即可
//  （勿动.h文件中内容）


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JYangLib : NSObject

#pragma mark - 获取网络图片

+ (void)JYangLibsetImageWithImageView:(UIImageView *)imageView URL:(NSURL *)url placeholderImage:(UIImage *)placeholder;


#pragma mark - 等待框

+ (void)JYangLibShowWaitInViewController:(UIViewController *)viewController View:(UIView *)view hint:(NSString *)hint;

+ (void)JYangLibHideWaitWithViewController:(UIViewController *)viewController;

+ (void)JYangLibShowWait:(NSString *)hint InViewController:(UIViewController *)viewController;


@end
