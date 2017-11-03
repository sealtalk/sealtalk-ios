//
//  RCDReceiptDetailsTableViewCell.h
//  RCloudMessage
//
//  Created by Jue on 16/9/23.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 用户信息提供者

 @discussion SDK需要通过您实现的用户信息提供者，获取用户信息并显示。
 */
@protocol RCDReceiptDetailsCellDelegate <NSObject>

@optional

- (void)clickHasReadButton;

- (void)clickUnreadButton;

- (void)clickPortrait:(NSString *)userId;

@end

@interface RCDReceiptDetailsTableViewCell : UITableViewCell

@property(nonatomic, strong) NSArray *userList;

@property(nonatomic, strong) NSArray *groupMemberList;

@property(nonatomic, weak) id<RCDReceiptDetailsCellDelegate> delegate;

@property(nonatomic, assign) BOOL displayHasreadUsers;

@property(nonatomic, assign) NSUInteger hasReadUsersCount;

@property(nonatomic, assign) NSUInteger unreadUsersCount;

@property(nonatomic, assign) CGFloat cellHeight;

@end
