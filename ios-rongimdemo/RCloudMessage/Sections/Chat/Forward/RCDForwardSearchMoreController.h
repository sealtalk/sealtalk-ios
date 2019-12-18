//
//  RCDForwardSearchMoreController.h
//  SealTalk
//
//  Created by 孙浩 on 2019/6/21.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCDForwardSearchMoreController : RCDViewController

@property (nonatomic, copy) NSString *searchString;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, strong, nullable) NSArray *resultArray;
@property (nonatomic, copy) void (^cancelBlock)(void);
@property (nonatomic, assign) BOOL isShowSeachBar;
@property (nonatomic, assign) int messageCount;

@end

NS_ASSUME_NONNULL_END
