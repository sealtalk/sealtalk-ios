//
//  RCSightPlayerController.h
//  RongExtensionKit
//
//  Created by zhaobingdong on 2017/4/29.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RCSightPlayerControllerDelegate <NSObject>

@optional
/**
 关闭视频播放器时调用，overlay中closeBtn被点击时调用
 */
- (void)closeSightPlayer;

/**
 播放完毕时调用
 */
- (void)playToEnd;

@end

@protocol RCSightPlayerOverlay;

@interface RCSightPlayerController : NSObject

/**
 初始化视频播放控制器

 @param assetURL 视频的本地或者远程url
 @param isauto 初始化完成后是否自动开始播放
 @return 返回控制器实例
 */
- (instancetype)initWithURL:(NSURL *)assetURL autoPlay:(BOOL)isauto;

/**
 播放器视图
 */
@property(strong, nonatomic, readonly) UIView *view;

/**
 播放器覆盖视图
 */
@property(strong, nonatomic, readonly) id<RCSightPlayerOverlay> overlay;

/**
 播放器代理
 */
@property(weak, nonatomic) id<RCSightPlayerControllerDelegate> delegate;

/**
 是否循环播放，默认为NO，不循环播放
 */
@property(assign, nonatomic) BOOL isLoopPlayback;

/**
 视频的本地或者远程url，
 @discussion 如果开启了autoPlay设置该属性会自动调用 play 方法
 */
@property(strong, nonatomic) NSURL *rcSightURL;

/**
 第一帧的图像
 */
@property(strong, nonatomic, nullable) UIImage *firstFrameImage;

/**
 视频下载完成后是否自动播放，默认为NO ，不自动播放，
 */
@property(nonatomic, assign, getter=isAutoPlay) BOOL autoPlay;

/**
 是否隐藏播放器的覆盖控制图层
 */
@property(nonatomic, assign, getter=isOverlayHidden) BOOL overlayHidden;

/**
 设置视频播放器的缩略显示图

 @param image 图片显示图
 */
- (void)setFirstFrameThumbnail:(nullable UIImage *)image;

/**
 开始播放本地小视频，或者下载视频文件到本地播放
 */
- (void)play;

/**
 暂停播放
 */
- (void)pause;

/**
 销毁资源，重置状态，终止播放。
 
  @discussion 该方法不会终止下载操作，下载完成后会缓存视频文件，但是不会播放。
 */
- (void)reset;
-(void)setLoadingCenter:(CGPoint)center;

@end

NS_ASSUME_NONNULL_END
