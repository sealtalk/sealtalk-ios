//
//  RCBaseViewController.h
//  RongIMKit
//
//  Created by xugang on 15/1/22.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#ifndef __RCBaseViewController
#define __RCBaseViewController
#import <UIKit/UIKit.h>
#import <RongIMLib/RongIMLib.h>

/*!
 IMKit ViewController基类
 
 @discussion 主要定义了View的默认大小。
 */
@interface RCBaseViewController : UIViewController

///*!
// 是否开启左滑返回手势,默认是 NO ,关闭状态，可以在页面 viewDidLoad 里开启
// */
//如果需要实现滑动返回，请参考知识库http://support.rongcloud.cn/kb/NTEx 
//@property(nonatomic, assign) BOOL enableInteractivePopGestureRecognizer;
@end
#endif