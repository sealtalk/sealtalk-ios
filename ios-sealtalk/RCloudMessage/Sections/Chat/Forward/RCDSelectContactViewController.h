//
//  RCDSelectContactViewController.h
//  SealTalk
//
//  Created by 孙浩 on 2019/6/19.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDViewController.h"

typedef NS_ENUM(NSUInteger, RCDContactSelectType) {
    RCDContactSelectTypeForward = 0, // 转发
    RCDContactSelectTypeDelete,      // 多选删人
};

NS_ASSUME_NONNULL_BEGIN

@interface RCDSelectContactViewController : RCDViewController

- (instancetype)initWithContactSelectType:(RCDContactSelectType)type;

@end

NS_ASSUME_NONNULL_END
