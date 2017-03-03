//
//  RPYZTelphoneValidateView.h
//  RedpacketLib
//
//  Created by Mr.Yan on 2016/11/1.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RPTelphoneValidateView : UIView

@property (nonatomic, copy) NSString *telphone;
@property (nonatomic, copy) void(^closeButtonBlock)(RPTelphoneValidateView *passView);
@property (nonatomic, copy) void(^reSendButtonBlock)(RPTelphoneValidateView *passView);
@property (nonatomic, copy) void(^passFinishBlock)(NSString *pass);


- (void)timerRun;
- (void)becomeFristResponder;
- (void)clearInputField;
- (void)messageInputError:(BOOL)error;

@end
