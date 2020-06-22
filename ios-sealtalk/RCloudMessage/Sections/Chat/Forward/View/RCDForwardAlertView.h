//
//  RCDForwardAlertView.h
//  RongEnterpriseApp
//
//  Created by Sin on 17/3/13.
//  Copyright © 2017年 rongcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMKit/RongIMKit.h>

@protocol RCDForwardAlertViewDelegate;
@class RCDForwardCellModel;
@interface RCDForwardAlertView : UIView
#pragma mark - init
+ (instancetype)alertViewWithModel:(RCConversation *)model;
+ (instancetype)alertViewWithSelectedContacts:(NSArray *)selectedContacts;

#pragma mark - show
- (void)show;

#pragma mark - delegate
@property (nonatomic, weak) id<RCDForwardAlertViewDelegate> delegate;

#pragma mark - data
//只有调用了alertViewWithModel:接口，下面的字段才有值
@property (nonatomic, strong, readonly) RCConversation *model;

@property (nonatomic, strong) NSArray *messageArray;

@end

@protocol RCDForwardAlertViewDelegate <NSObject>

/**
 点击某个按钮

 @param alertView alertView
 @param buttonIndex 0代表取消，1代表确定
 */
- (void)forwardAlertView:(RCDForwardAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
