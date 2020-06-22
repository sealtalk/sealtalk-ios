//
//  RCDUserSetting.h
//  SealTalk
//
//  Created by 张改红 on 2019/7/11.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
//当前登录用户设置信息
@interface RCDUserSetting : NSObject
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, assign) BOOL allowMobileSearch;
@property (nonatomic, assign) BOOL allowSTAccountSearch;
@property (nonatomic, assign) BOOL needAddFriendVerify;
@property (nonatomic, assign) BOOL needJoinGroupVerify;
- (instancetype)initWithJson:(NSDictionary *)json;
@end

NS_ASSUME_NONNULL_END
