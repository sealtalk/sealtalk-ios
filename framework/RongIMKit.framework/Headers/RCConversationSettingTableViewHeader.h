//
//  RCConversationSettingTableViewHeader.h
//  RongIMToolkit
//
//  Created by Liv on 15/3/25.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RCConversationSettingTableViewHeader;

/*!
 会话设置界面头像区域的点击回调
 */
@protocol RCConversationSettingTableViewHeaderDelegate <NSObject>
@optional

/*!
 点击Item（用户头像或加减号）的回调
 
 @param settingTableViewHeader  当前会话设置界面
 @param indexPathOfSelectedItem 点击的Item索引值
 @param users                   当前的用户信息RCUserInfo列表
 */
- (void)settingTableViewHeader:(RCConversationSettingTableViewHeader *)settingTableViewHeader
       indexPathOfSelectedItem:(NSIndexPath *)indexPathOfSelectedItem
            allTheSeletedUsers:(NSArray *)users;

/*!
 点击删除的回调
 
 @param indexPath 点击的索引
 */
- (void)deleteTipButtonClicked:(NSIndexPath *)indexPath;

/*!
 点击头像的回调
 
 @param userId 头像对应的用户ID
 */
- (void)didTipHeaderClicked:(NSString *)userId;

@end

/*!
 会话设置界面的头像区域
 */
@interface RCConversationSettingTableViewHeader
    : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

/*!
 是否显示删除（减号）
 */
@property(nonatomic, assign) BOOL showDeleteTip;

/*!
 是否允许删除用户
 */
@property(nonatomic, assign) BOOL isAllowedDeleteMember;

/*!
 是否允许添加用户
 */
@property(nonatomic, assign) BOOL isAllowedInviteMember;

/*!
 会话设置界面头像区域的点击回调
 */
@property(weak, nonatomic) id<RCConversationSettingTableViewHeaderDelegate> settingTableViewHeaderDelegate;

/*!
 用户信息RCUserInfo的列表
 */
@property(strong, nonatomic) NSMutableArray *users;

@end
