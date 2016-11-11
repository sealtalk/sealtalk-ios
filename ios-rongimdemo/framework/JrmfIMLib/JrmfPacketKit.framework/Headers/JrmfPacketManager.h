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
 打开我的钱包
 */
+ (void)getEventOpenWallet;

/**
 获取当前SDK版本

 @return SDK版本
 */
+ (NSString *)getCurrentVersion;

@end
