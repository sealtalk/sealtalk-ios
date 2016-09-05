//
//  RCDTextFieldValidate.h
//  RongCloud
//  字段验证类
//  Created by Liv on 14/11/7.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCDTextFieldValidate : NSObject

//验证手机号码
+ (BOOL)validateMobile:(NSString *)mobile;

//验证电子邮箱
+ (BOOL)validateEmail:(NSString *)email;

//验证密码
+ (BOOL)validatePassword:(NSString *)password;

@end
