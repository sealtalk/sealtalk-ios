//
//  JrmfWalletSDK.h
//  JrmfWalletKit
//
//  Created by 一路财富 on 16/10/17.
//  Copyright © 2016年 JYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JrmfWalletSDK : NSObject

/**
 标准字体大小，默认14.f;
 */
@property (nonatomic, assign) CGFloat themeFontSize;

/**
 钱包页顶部主题色，默认#157EFB
 */
@property (nonatomic, strong) UIColor * themePageColor;

/**
 钱包页，充值、提现按钮颜色，默认#0665D6
 */
@property (nonatomic, strong) UIColor * pageBtnColor;

/**
 按钮主题色，默认#157EFB
 */
@property (nonatomic, strong) UIColor * themeBtnColor;

/**
 Navigation主题色，默认#157EFB
 */
@property (nonatomic, strong) UIColor * themeNavColor;

/**
 标题颜色，默认白色
 */
@property (nonatomic, strong) UIColor * NavTitColor;

/**
 标题栏字体大小，默认16.f
 */
@property (nonatomic, assign) CGFloat NavTitfontSize;

/**
 首页金额大小，默认22.f
 */
@property (nonatomic, assign) CGFloat pageChargeFont;

/**
 钱包标题，默认“我的钱包”
 */
@property (nonatomic, strong) NSString * pageTitleStr;


/**
 初始化函数
 
 @param partnerId 渠道ID（我们分配给贵公司的渠道名称）
 */
+ (void)instanceJrmfWalletSDKWithPartnerId:(NSString *)partnerId;


/**
 初始化三方令牌

 @param thirdToken 三方令牌
 */
+ (void)instanceJrmfWalletSDKWithThirdToken:(NSString *)thirdToken;


/**
 打开我的钱包
 */
+ (void)openWallet;

/**
 获取当前版本
 
 @return 版本号
 */
+ (NSString *)getCurrentVersion;

@end
