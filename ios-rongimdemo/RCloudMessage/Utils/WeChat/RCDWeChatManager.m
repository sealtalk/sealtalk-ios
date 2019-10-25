//
//  RCDWeChatManager.m
//  SealTalk
//
//  Created by 孙浩 on 2019/7/10.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDWeChatManager.h"

@interface RCDWeChatManager () <WXApiDelegate>

@end

@implementation RCDWeChatManager

+ (instancetype)sharedManager {
    static RCDWeChatManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
    });
    return manager;
}

+ (void)registerApp:(NSString *)appid {
    [WXApi registerApp:appid];
}

- (BOOL)handleOpenURL:(NSURL *)url {
    return [WXApi handleOpenURL:url delegate:self];
}

+ (BOOL)weChatCanShared {
    return [WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi];
}

- (BOOL)sendTextContent:(NSString *)text atScene:(enum WXScene)scene {

    if (![WXApi isWXAppInstalled]) {
        NSLog(@"未安装微信");
        return NO;
    }

    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = YES;
    req.text = text;
    req.scene = scene;
    return [WXApi sendReq:req];
}

- (BOOL)sendImage:(UIImage *)image atScene:(enum WXScene)scene {

    if (![WXApi isWXAppInstalled]) {
        NSLog(@"未安装微信");
        return NO;
    }

    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    UIImage *thumbImage = [UIImage imageWithData:UIImageJPEGRepresentation(image, 0.5)];

    WXImageObject *imageObject = [WXImageObject object];
    // 小于 10MB
    imageObject.imageData = imageData;

    WXMediaMessage *message = [WXMediaMessage message];
    message.mediaObject = imageObject;
    // 缩略图 小于32KB
    [message setThumbImage:thumbImage];

    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    return [WXApi sendReq:req];
}

- (BOOL)sendLinkContent:(NSString *)urlString
                  title:(NSString *)title
            description:(NSString *)description
             thumbImage:(UIImage *)thumbImage
                atScene:(enum WXScene)scene {

    if (![WXApi isWXAppInstalled]) {
        NSLog(@"未安装微信");
        return NO;
    }

    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = urlString;

    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    message.mediaObject = ext;
    [message setThumbImage:thumbImage];

    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.message = message;
    req.bText = NO;
    req.scene = scene;
    return [WXApi sendReq:req];
}

#pragma mark - WXApiDelegate
- (void)onReq:(BaseReq *)req {
    // just leave it here, WeChat will not call our app
}

- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        if (resp.errCode == 0) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(wxSharedSucceed)]) {
                [self.delegate wxSharedSucceed];
            }
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(wxSharedFailure)]) {
                [self.delegate wxSharedFailure];
            }
        }
    }
}

@end
