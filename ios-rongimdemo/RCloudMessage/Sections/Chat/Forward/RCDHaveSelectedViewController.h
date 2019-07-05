//
//  RCDHaveSelectedViewController.h
//  SealTalk
//
//  Created by 孙浩 on 2019/6/18.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDHaveSelectedViewController : UIViewController

@property (nonatomic, copy) void (^confirmButtonBlock)(void);

@end

NS_ASSUME_NONNULL_END
