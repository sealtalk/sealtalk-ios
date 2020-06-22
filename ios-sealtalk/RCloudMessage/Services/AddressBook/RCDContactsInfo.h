//
//  RCDContactsInfo.h
//  SealTalk
//
//  Created by 孙浩 on 2019/7/11.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDContactsInfo : NSObject

@property (nonatomic, assign) BOOL isRegister;     // 是否注册
@property (nonatomic, assign) BOOL isRelationship; // 是否是好友
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *stAccount;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *portraitUri;

@property (nonatomic, assign) BOOL isSelected;

@end

NS_ASSUME_NONNULL_END
