//
//  RCDWeChatManager.h
//  SealTalk
//
//  Created by 孙浩 on 2019/7/10.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WXApi.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RCDWeChatManagerDelegate <NSObject>
@optional
- (void)wxSharedSucceed;
- (void)wxSharedFailure;
@end

@interface RCDWeChatManager : NSObject

@property (nonatomic, weak) id<RCDWeChatManagerDelegate> delegate;

+ (instancetype)sharedManager;

+ (void)registerApp:(NSString *)appid;

- (BOOL)handleOpenURL:(NSURL *)url;

/*! @brief 检查微信是否可转发
 *
 * @return 微信可以转发返回 YES，不能转发返回 NO。
 */
+ (BOOL)weChatCanShared;

/**
 发送文字到微信

 @param text 文字
 @param scene 发送的场景，分为朋友圈, 会话和收藏
 @return 发送成功返回 YES
 */
- (BOOL)sendTextContent:(NSString *)text atScene:(enum WXScene)scene;

/**
 发送图片到微信

 @param image 图片
 @param scene 发送的场景，分为朋友圈, 会话和收藏
 @return 发送成功返回 YES
 */
- (BOOL)sendImage:(UIImage *)image atScene:(enum WXScene)scene;

/**
 发送链接到微信.

 @param urlString 链接的 Url
 @param title 链接的 Title
 @param description 链接的描述
 @param thumbImage 链接的缩略图
 @param scene 发送的场景，分为朋友圈, 会话和收藏
 @return 发送成功返回 YES
 */
- (BOOL)sendLinkContent:(NSString *)urlString
                  title:(NSString *)title
            description:(NSString *)description
             thumbImage:(UIImage *)thumbImage
                atScene:(enum WXScene)scene;

@end

NS_ASSUME_NONNULL_END
