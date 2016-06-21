//
//  RCPublicServiceChatViewController.h
//  RongIMKit
//
//  Created by litao on 15/6/12.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCConversationViewController.h"

/*!
 公众服务聊天界面的ViewController
 */
@interface RCPublicServiceChatViewController : RCConversationViewController

/*!
 点击富文本（图文）消息中URL的回调
 
 @param tapedUrl            点击的URL
 @param rcWebViewController 已包含融云JS鉴权的WebViewController
 
 @discussion SDK在回调中默认会使用WebView打开URL，您可以重写此回调。
 此回调中的rcWebViewController，已经包含了融云公众账号的JS鉴权，您在重写时可以直接使用此WebView来显示URL。
 */
- (void)didTapImageTxtMsgCell:(NSString *)tapedUrl webViewController:(UIViewController *)rcWebViewController;
@end
