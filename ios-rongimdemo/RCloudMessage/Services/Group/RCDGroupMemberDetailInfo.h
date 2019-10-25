//
//  RCDGroupMemberDetailInfo.h
//  SealTalk
//
//  Created by 张改红 on 2019/8/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDGroupMemberDetailInfo : NSObject
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *groupNickname;
@property (nonatomic, strong) NSString *region;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *weChatAccount;
@property (nonatomic, strong) NSString *alipayAccount;
@property (nonatomic, strong) NSArray<NSString *> *describeArray;
- (instancetype)initWithJson:(NSDictionary *)json;
- (NSDictionary *)decode;
@end

NS_ASSUME_NONNULL_END
