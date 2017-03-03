//
//  UIAlertView+YZXAlert.h
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/3/10.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^YZHAlertViewCompletionBlock)( UIAlertView * _Nonnull alertView, NSInteger buttonIndex);

@interface UIAlertView (YZHAlert)

//- (void)setCompletionBlock:(YZHAlertViewCompletionBlock)completionBlock;
@property(nonatomic ,copy ,nullable) YZHAlertViewCompletionBlock rp_completionBlock;


+ (void)rp_showAlertWithTitle:(nullable NSString*)title
                      message:(nullable NSString*)message
            cancelButtonTitle:(nullable NSString *)cancelButtonTitle
            otherButtonTitles:(nullable NSString *)otherButtonTitle
              completionBlock:(nullable YZHAlertViewCompletionBlock) completionBlock;
@end
