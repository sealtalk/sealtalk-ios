//
//  JrmfPacketManager.h
//  JrmfPacketManagerKit
//
//  Created by 一路财富 on 16/8/24.
//  Copyright © 2016年 JYang. All rights reserved.
//

//  注：IM红包类方法

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JrmfPacketManager : NSObject

/**
 获取当前SDK版本

 @return SDK版本
 */
+ (NSString *)getCurrentVersion;


/**
 配置微信

 @param wxKey weixin key
 */
+ (void)setWeixinKey:(NSString *)wxKey;

/**
 销毁扩展模块
 */
+ (void)destroyPacketModule;

@end
