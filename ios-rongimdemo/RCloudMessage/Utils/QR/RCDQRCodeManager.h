//
//  QRCodeManager.h
//  SealTalk
//
//  Created by 张改红 on 2019/6/3.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface RCDQRCodeManager : NSObject
+ (UIImage *)getQRCodeImage:(NSString *)content;
+ (NSString *)decodeQRCodeImage:(UIImage *)image;
@end

NS_ASSUME_NONNULL_END
