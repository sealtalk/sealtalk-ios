//
//  RCDTextFieldValidate.m
//  RongCloud
//
//  Created by Liv on 14/11/7.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//
#import "RCDTextFieldValidate.h"
#import <UIKit/UIKit.h>
#import <RongIMKit/RCAlertView.h>
@implementation RCDTextFieldValidate

//验证手机号码
+ (BOOL)validateMobile:(NSString *)mobile {
    if (mobile.length == 0) {
        NSString *message = RCDLocalizedString(@"mobile_number_unempty");
        [self showAlertController:message cancelTitle:RCDLocalizedString(@"confirm")];
        return NO;
    }
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    if (![phoneTest evaluateWithObject:mobile]) {
        NSString *message = RCDLocalizedString(@"mobile_number_unempty");
        [self showAlertController:message cancelTitle:RCDLocalizedString(@"confirm")];
        return NO;
    }
    return YES;
}

//验证电子邮箱
+ (BOOL)validateEmail:(NSString *)email {
    if (email.length == 0) {
        return NO;
    }

    NSString *expression = [NSString stringWithFormat:@"^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*$"];
    NSError *error = NULL;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:expression
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:email options:0 range:NSMakeRange(0, [email length])];
    if (!match) {
        return NO;
    }
    return YES;
}

+ (void)showAlertController:(NSString *)message cancelTitle:(NSString *)cancelTitle {
    [RCAlertView showAlertController:nil message:message cancelTitle:cancelTitle];
}
@end
