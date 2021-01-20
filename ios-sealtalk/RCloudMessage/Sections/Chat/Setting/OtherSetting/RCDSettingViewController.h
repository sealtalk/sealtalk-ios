//
//  RCDSettingViewController.h
//  SealTalk
//
//  Created by 张改红 on 2020/7/23.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCDTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCDSettingViewController : RCDTableViewController
@property (nonatomic, assign) RCConversationType conversationType;
@property (nonatomic, strong) NSString *targetId;
@property (nonatomic, copy) void (^clearMessageHistory)();
@end

NS_ASSUME_NONNULL_END
