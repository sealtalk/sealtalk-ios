//
//  RCDHaveSelectedViewController.h
//  SealTalk
//
//  Created by 孙浩 on 2019/6/18.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCDHaveSelectedViewController : RCDViewController

@property (nonatomic, copy) void (^confirmButtonBlock)(void);

@end

NS_ASSUME_NONNULL_END
