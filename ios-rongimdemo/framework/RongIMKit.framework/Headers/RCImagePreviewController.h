//
//  PreviewViewController.h
//  RCIM
//
//  Created by Heq.Shinoda on 14-5-27.
//  Copyright (c) 2014年 Heq.Shinoda. All rights reserved.
//

#import "RCBaseViewController.h"
#import "RCImageMessageProgressView.h"
#import <UIKit/UIKit.h>

@class RCMessageModel;

/*!
 查看图片消息中的原始图片的ViewController
 */
@interface RCImagePreviewController : RCBaseViewController

/*!
 原始图片的View
 */
@property(nonatomic, strong) UIImageView *originalImageView;

/*!
 消息的数据模型
 */
@property(nonatomic, strong) RCMessageModel *messageModel;

/*!
 图片消息进度的View
 */
@property(nonatomic, strong) RCImageMessageProgressView *rcImageProressView;

/*!
 取消按钮的点击事件

 @param sender 取消按钮

 @discussion SDK在此方法中，会针对默认的NavigationBar退出当前界面；
 如果您使用自定义导航按钮或者自定义按钮，可以重写此方法退出当前界面。
 */
- (void)leftBarButtonItemPressed:(id)sender;

/*!
 保存按钮的点击事件

 @param sender 保存按钮

 @discussion SDK在此方法中，默认会进行图片的保存。
 */
- (void)rightBarButtonItemPressed:(id)sender;

/*!
 图片下载完成的回调
 */
- (void)imageDownloadDone;

@end