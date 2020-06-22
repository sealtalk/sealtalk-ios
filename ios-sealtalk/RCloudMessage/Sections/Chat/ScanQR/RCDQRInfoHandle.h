//
//  RCDQRInfoHandle.h
//  SealTalk
//
//  Created by 张改红 on 2019/7/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface RCDQRInfoHandle : NSObject
- (void)identifyQRCode:(NSString *)info base:(UIViewController *)viewController;
@end

NS_ASSUME_NONNULL_END
