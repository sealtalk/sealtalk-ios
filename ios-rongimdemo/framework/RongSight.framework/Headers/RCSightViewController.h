//
//  RCSightViewController.h
//  RongExtensionKit
//
//  Created by zhaobingdong on 2017/4/24.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RCSightViewController;
@protocol RCSightViewControllerDelegate;

typedef NS_ENUM(NSInteger, RCSightViewControllerCameraCaptureMode) {
    RCSightViewControllerCameraCaptureModeSight,  /// 录制小视频  拍照  默认使用这种模式
    RCSightViewControllerCameraCaptureModePhoto // 仅拍照
};

/**
 视频预览视图控制器
 */
@interface RCSightViewController : UIViewController

- (instancetype)initWithCaptureMode:(RCSightViewControllerCameraCaptureMode)mode;

/**
 视频预览视图控制器代理
 */
@property(nonatomic, weak, nullable) id<RCSightViewControllerDelegate> delegate;

@end


@protocol RCSightViewControllerDelegate <NSObject>

/**
 当用户选择发送拍摄的静态图片时，调用该方法
 
 @param sightVC 视频预览视图控制器实例
 @param image 静态图片对象
 */
- (void)sightViewController:(RCSightViewController *)sightVC didFinishCapturingStillImage:(UIImage *)image;

/**
 当用户选择发送录制的小视频时，调用该方法
 
 @param sightVC 视频预览视图控制器实例
 @param url 当前小视频存储地址
 @param thumnail 小视频的第一帧图像的图片对象
 @param duration 小视频的时长，单位是s
 */
- (void)sightViewController:(RCSightViewController *)sightVC
         didWriteSightAtURL:(NSURL *)url
                  thumbnail:(UIImage *)thumnail
                   duration:(NSUInteger)duration;

@end

NS_ASSUME_NONNULL_END
