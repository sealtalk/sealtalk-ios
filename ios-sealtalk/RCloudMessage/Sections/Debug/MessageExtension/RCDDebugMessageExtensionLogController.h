//
//  RCDDebugMessageExtensionLogController.h
//  SealTalk
//
//  Created by 张改红 on 2020/8/5.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCDViewController.h"
#import <RongIMKit/RongIMKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface RCDDebugMessageExtensionLogController : RCDViewController
@property (nonatomic, strong) NSString *targetId;
@property (nonatomic, assign) RCConversationType conversationType;
@end

NS_ASSUME_NONNULL_END
