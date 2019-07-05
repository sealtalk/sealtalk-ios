//
//  RCDSelectingUserController.h
//  SealTalk
//
//  Created by 张改红 on 2019/6/20.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RCUserInfo;
NS_ASSUME_NONNULL_BEGIN

@interface RCDChooseUserController : UITableViewController
- (instancetype)initWithGroupId:(NSString *)groupId;
@property(nonatomic, copy) void (^selectedBlock)(RCUserInfo *selectedUserInfo);
@property(nonatomic, copy) void (^cancelBlock)(void);
@end

NS_ASSUME_NONNULL_END
