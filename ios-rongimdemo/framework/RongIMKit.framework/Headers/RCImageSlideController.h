//
//  RCImageSlideController.h
//  RongIMKit
//
//  Created by liulin on 16/5/18.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCBaseViewController.h"
#import "RCImageMessageProgressView.h"
#import <UIKit/UIKit.h>
@class RCMessageModel;

@interface RCImageSlideController : RCBaseViewController

/*!
 当前图片消息的数据模型
 */
@property(nonatomic, strong) RCMessageModel *messageModel;

/*!
 图片消息进度的View
 @warning  **已废弃，请勿使用。**
 */
@property(nonatomic, strong) RCImageMessageProgressView *rcImageProressView;

@end