//
//  LoginInfo.h
//  RongCloud
//  登陆信息
//  Created by Liv on 14/11/10.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@interface RCDLoginInfo : JSONModel

@property (nonatomic,copy) NSString *code;
@property (nonatomic,copy) NSString *token;
@property (nonatomic,copy) NSString *userId;
@property (nonatomic,copy) NSString *userName;
@property (nonatomic, copy) NSString *portrait;

+(id) shareLoginInfo;

@end
