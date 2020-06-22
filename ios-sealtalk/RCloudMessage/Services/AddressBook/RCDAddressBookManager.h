//
//  RCDAddressBookManager.h
//  SealTalk
//
//  Created by 孙浩 on 2019/7/11.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCDContactsInfo.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, RCDContactsAuthState) {
    RCDContactsAuthStateNotDetermine = 0, // 未决定
    RCDContactsAuthStateRefuse,           // 拒绝
    RCDContactsAuthStateApprove,          // 通过
};

@interface RCDAddressBookManager : NSObject

@property (nonatomic, assign) RCDContactsAuthState state;

+ (instancetype)sharedManager;

- (void)getContactsAuthState;

- (void)requestAuth;

- (NSArray *)getAllContactPhoneNumber;

- (NSArray *)getAllContacts;

// 获取通讯录朋友信息列表
+ (void)getContactsInfo:(NSArray *)phoneNumberList complete:(void (^)(NSArray *contactsList))completeBlock;

@end

NS_ASSUME_NONNULL_END
