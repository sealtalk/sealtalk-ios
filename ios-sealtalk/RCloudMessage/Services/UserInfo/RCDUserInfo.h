//
//  RCDUserInfo.h
//  SealTalk
//
//  Created by 孙浩 on 2019/7/11.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDUserInfo : RCUserInfo

@property (nonatomic, strong) NSString *stAccount;
@property (nonatomic, strong) NSString *gender;

@end

NS_ASSUME_NONNULL_END
