//
//  RCDChatBgDetailViewController.h
//  SealTalk
//
//  Created by 孙浩 on 2019/8/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, RCDChatBgDetailType) {
    RCDChatBgDetailTypeDefault = 0,
    RCDChatBgDetailTypeAlbum,
};

@interface RCDChatBgDetailViewController : RCDViewController

- (instancetype)initWithChatBgDetailType:(RCDChatBgDetailType)type imageName:(NSString *)imageName;

- (instancetype)initWithChatBgDetailType:(RCDChatBgDetailType)type image:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
