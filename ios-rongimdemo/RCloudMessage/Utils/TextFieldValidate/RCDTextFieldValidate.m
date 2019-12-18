//
//  RCDTextFieldValidate.m
//  RongCloud
//
//  Created by Liv on 14/11/7.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//
#import "RCDTextFieldValidate.h"
#import <UIKit/UIKit.h>

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

//验证密码
+ (BOOL)validatePassword:(NSString *)password {
    if (password.length == 0) {
        NSString *message = RCDLocalizedString(@"password_can_not_be_blank");
        [self showAlertController:message cancelTitle:RCDLocalizedString(@"confirm")];
        return NO;
    }
    NSRange _range = [password rangeOfString:@" "];
    if (_range.location != NSNotFound) {
        NSString *message = RCDLocalizedString(@"There_can_be_no_spaces_in_the_password");
        [self showAlertController:message cancelTitle:RCDLocalizedString(@"confirm")];
        return NO;
    }
    return YES;
}

+ (void)showAlertController:(NSString *)message cancelTitle:(NSString *)cancelTitle {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *rootVC = [UIApplication sharedApplication].delegate.window.rootViewController;
        UIAlertController *alertController =
            [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController
            addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDefault handler:nil]];
        [rootVC presentViewController:alertController animated:YES completion:nil];
    });
}
@end
