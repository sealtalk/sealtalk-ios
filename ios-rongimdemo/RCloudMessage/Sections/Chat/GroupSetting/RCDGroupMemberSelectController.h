//
//  RCDGroupMemberSelectController.h
//  SealTalk
//
//  Created by 张改红 on 2019/6/18.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDTableViewController.h"
typedef NS_ENUM(NSUInteger, RCDGroupMemberSelectType) {
    RCDGroupMemberSelectTypeAddManager, //选择管理员
    RCDGroupMemberSelectTypePoke,       //戳一下选人
};
NS_ASSUME_NONNULL_BEGIN
typedef void (^SelectMembersResult)(NSArray<NSString *> *memberIds);
@interface RCDGroupMemberSelectController : RCDTableViewController
@property (nonatomic, copy) SelectMembersResult selectResult;
- (instancetype)initWithGroupId:(NSString *)groupId type:(RCDGroupMemberSelectType)type;
@end

NS_ASSUME_NONNULL_END
