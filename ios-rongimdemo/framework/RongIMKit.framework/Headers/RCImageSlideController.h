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


/**
 长按图片内容的回调

 @param sender 长按手势
 
 @discussion 如需使用SDK的长按图片内容处理，请调用父类方法 [super longPressed:sender];
 */
- (void)longPressed:(id)sender;

/*!
 图片消息进度的View
 @warning  **已废弃，请勿使用。**
 */
@property(nonatomic, strong) RCImageMessageProgressView *rcImageProressView;

@end
