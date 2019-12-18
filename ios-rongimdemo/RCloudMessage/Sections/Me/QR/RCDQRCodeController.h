//
//  RCDGroupQRCodeController.h
//  SealTalk
//
//  Created by 张改红 on 2019/6/17.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDViewController.h"
#import <RongIMLib/RongIMLib.h>
#import "RCDGroupInfo.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCDQRCodeController : RCDViewController
- (instancetype)initWithTargetId:(NSString *)targetId conversationType:(RCConversationType)type;
@end

NS_ASSUME_NONNULL_END
