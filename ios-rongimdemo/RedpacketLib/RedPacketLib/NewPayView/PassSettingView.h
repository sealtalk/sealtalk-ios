//
//  PassSettingView.h
//  RedpacketLib
//
//  Created by Mr.Yang on 16/4/26.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PasswordFinishBlock)(NSString *pass);
typedef void (^PasswordFielInputingBlock)(NSString *pass);

@interface PassSettingView : UIView

@property (nonatomic, readonly) NSString *password;
@property (nonatomic, assign)   BOOL isSecurity;

- (instancetype)initWithWith:(CGFloat)width andPadding:(CGFloat)padding;

/**
 *  输入完成的Block
 */
@property (nonatomic, copy) PasswordFinishBlock passViewBlock;
/**
 *  正在输入的状态
 */
@property (nonatomic, copy) PasswordFielInputingBlock passViewInputingBlock;


- (void)becomeFirstResponder;
- (void)resignFirstResponder;

- (void)passwordInputError:(BOOL)error;
- (void)clearPassword;

@end
