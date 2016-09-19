//
//  RPRedpacketUser.h
//  RedpacketRequestDataLib
//
//  Created by Mr.Yang on 16/7/28.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RedpacketMessageModel.h"
#import "YZHRedpacketBridgeProtocol.h"

#define __RedpacketToken__  [RPRedpacketUser currentUser].userToken

/**
 *  红包Token
 */
UIKIT_EXTERN NSString *const RedpacketUserTokenKey;


@interface RPRedpacketUser : NSObject


@property (nonatomic, weak) id <YZHRedpacketBridgeDataSource>dataSource;


@property (nonatomic, readonly) RedpacketUserInfo *currentUserInfo;

/**
 *  用户Token
 */
@property (nonatomic, copy, readonly) NSString *userToken;

/**
 *  是否过期
 */
@property (nonatomic, assign,readonly) BOOL isTokenExpired;


+ (RPRedpacketUser *)currentUser;

- (void)clearTokenInfo;

- (void)redpacketTokenRequestSuccess:(NSDictionary *)tokenDic;

@end
