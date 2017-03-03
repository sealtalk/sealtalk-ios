//
//  RPAlipayAuth.h
//  RedpacketLib
//
//  Created by Mr.Yang on 2016/12/20.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPAlipayAuthInfo : NSObject

@property (nonatomic, readonly) NSString *authCode;
@property (nonatomic, readonly) NSString *userId;

@end


typedef void(^AlipayAuthCallBack)(BOOL isSuccess, NSString *error);

@interface RPAlipayAuth : NSObject

@property (nonatomic, readonly) RPAlipayAuthInfo *authInfo;

- (void)doAlipayAuth:(AlipayAuthCallBack)callBack;

@end
