//
//  RCDMyInfoInGroupController.h
//  SealTalk
//
//  Created by 张改红 on 2019/8/6.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDGroupMemberDetailController : UITableViewController
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, copy) void (^updateMemberDetail)();
@end

NS_ASSUME_NONNULL_END
