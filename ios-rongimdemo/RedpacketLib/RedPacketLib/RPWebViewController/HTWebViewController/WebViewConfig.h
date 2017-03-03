
//
//  WebViewConfig.h
//  InvestWebView
//
//  Created by Mr.Yang on 15/11/23.
//  Copyright © 2015年 Mr.Yang. All rights reserved.
//


/**
 *  配置系统色调 ，相关字体颜色， 文字描述
 */

#ifndef WebViewConfig_h
#define WebViewConfig_h

/**
 *  进度条颜色
 */
static uint const defaultColor_progressViewColor = 0x167ffc;

/**
 *  webView背景色
 */
static uint const defaultColor_webViewBackGroudColor = 0xeeeeee;

/**
 *  关闭按钮颜色
 */
static uint const defaultColor_closeButtonColor = 0xfa640e;

/**
 *  关闭按钮高亮颜色
 */
static uint const defaultColor_closeButtonHighLightColor = 0xea5414;

/**
 *  理财标题
 */
static NSString * const defaultString_investTitle = @"云账户";



/*-------------------------------------------------*/
//             以下设置切勿修改
/*-------------------------------------------------*/

#pragma mark - 
#pragma mark Extension

/*url劫持关键字*/
static NSString *ht_urlHookStr      = @"yunzhanghu.com/app";

/*认证回调*/
static NSString *ht_authAction         =   @"returnAuth";

/*绑卡回调*/
static NSString *ht_bindBankCardAction =   @"returnBankcard";

/*投资回调*/
static NSString *ht_investAction       =   @"returnInvest";


/**
 *  回调方法枚举
 */
typedef NS_ENUM(NSInteger, InvestCallBackMethod) {
    /**
     *  认证返回
     */
    InvestCallBackMethodAuth         = 0,
    /**
     *  绑定银行卡返回
     */
   InvestCallBackMethodBindBankCard = 1,
    /**
     *  投资
     */
    InvestCallBackMethodInvest       = 2,
    /**
     *  未知情况
     */
    InvestCallBackMethodUnknown      = -1
};

/**
 *  返回的状态码枚举
 */
typedef NS_ENUM(NSInteger, ReturnCode) {
    /**
     *  用户成功
     */
     ReturnCodeSuccess = 0,
    /**
     *  填写错误
     */
    ReturnCodeError = 1,
    /**
     *  多次填写错误
     */
    ReturnCodeMoreTimeError = 2
};

/**
 *  客户端回调方法
 *
 *  @param InvestCallBackMethod 回调的相关业务
 *  @param ReturnCode           相关业务处理状态
 *  @param NSString             相关业务处理说明
 *  @param id                   云账户返回参数
 */
typedef void(^InvestCallBackBlock)(InvestCallBackMethod, ReturnCode, NSString*, id);


static inline UIColor * ht_hexColor(uint color)
{
    float r = (color&0xFF0000) >> 16;
    float g = (color&0xFF00) >> 8;
    float b = (color&0xFF);
    
    return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f];
}


#endif /* WebViewConfig_h */
