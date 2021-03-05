//
//  RCDReceiptDetailsHeaderView.h
//  RCloudMessage
//
//  Created by Jue on 16/9/23.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDTableViewCell.h"

/*!
 用户信息提供者

 @discussion SDK需要通过您实现的用户信息提供者，获取用户信息并显示。
 */
@protocol RCDReceiptDetailsHeaderViewDelegate <NSObject>

@optional

- (void)clickHasReadButton;

- (void)clickUnreadButton;

@end

@interface RCDReceiptDetailsHeaderView : UIView

- (instancetype)initWithFrame:(CGRect)frame hasReadCount:(NSInteger)hasReadCount unreadCount:(NSInteger)unreadCount;

@property (nonatomic, weak) id<RCDReceiptDetailsHeaderViewDelegate> delegate;

@end
