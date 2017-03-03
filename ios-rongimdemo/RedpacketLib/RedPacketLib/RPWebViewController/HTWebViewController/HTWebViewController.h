//
//  HTWebViewController.h
//  HTWebView
//
//  Created by Mr.Yang on 13-8-2.
//  Copyright (c) 2013年 Hunter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHRedpacketBridge.h"

/**
 *  返回按钮事件处理协议
 *
 *  @Description: 如需控制NavigationController是否允许pop ViewController 只需在Controller里遵守此协议
 */
@protocol NavigationBarShouldPopItemProtocol <NSObject>

/**
 *  是否允许NavigationController pop ViewController
 *
 *  @return @YES 允许 @NO 不允许
 */
- (BOOL)navigationBarShouldPopItem;

@end


/**
 *  网页视图，处理加载进度
 */
@interface HTWebView : UIWebView


@end


/**
 *  加载网页， 添加消息头参，显示加载进度，加载视图，加载错误视图
 *  @Param url 请求的URL链接
 *  @Param webView 网页视图
 */
@interface HTWebViewController : UIViewController <UIWebViewDelegate>

/**
 *  请求的URL链接
 */
@property (nonatomic, strong)               NSURL *url;

/**
 *  网页视图
 */
@property (nonatomic, strong, readonly)     HTWebView *webView;

/**
 *  需要监听的Host地址
 */
@property (nonatomic, copy)                 NSString *hookString;

/**
 *  双title大标题
 */
@property (nonatomic) UILabel *titleLable;

/**
 *  双title小标题
 */
@property (nonatomic) UILabel *subLable;
/**
 *  Request Callback
 *  服务器关于客户端的回调函数,需要子类重写,用来监听父类回调
 *  @param request
 */
- (void)userActionCallBackWithRequest:(NSURLRequest *)request;

/**
 *  在Header里添加要传的参数
 *
 *  @param anObject value
 *  @param aKey     key
 */
- (void)setHeaderObject:(id)anObject forKey:(id)aKey;

@end
