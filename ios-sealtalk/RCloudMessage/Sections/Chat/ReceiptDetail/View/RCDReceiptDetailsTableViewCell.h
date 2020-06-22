//
//  RCDReceiptDetailsTableViewCell.h
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
@protocol RCDReceiptDetailsCellDelegate <NSObject>

@optional

- (void)clickHasReadButton;

- (void)clickUnreadButton;

@end
static NSString *RCDReceiptDetailsTableViewCellIdentifier = @"RCDReceiptDetailsTableViewCellIdentifier";

@interface RCDReceiptDetailsTableViewCell : RCDTableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, weak) id<RCDReceiptDetailsCellDelegate> delegate;

@property (nonatomic, assign) BOOL displayHasreadUsers;

@property (nonatomic, assign) NSInteger hasReadUsersCount;

@property (nonatomic, assign) NSInteger unreadUsersCount;
@end
