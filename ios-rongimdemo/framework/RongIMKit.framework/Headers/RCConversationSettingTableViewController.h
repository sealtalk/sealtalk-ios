//
//  RCConversationSettingTableViewController.h
//  RongIMKit
//
//  Created by Liv on 15/4/20.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <RongIMLib/RongIMLib.h>

@class RCConversationSettingTableViewHeader;

/*!
 会话设置的ViewController
 */
@interface RCConversationSettingTableViewController : UITableViewController

/*!
默认的Cell

@discussion 内置置顶聊天、新消息通、清除消息记录三个cell
*/
@property(nonatomic, strong, readonly) NSArray *defaultCells;

/*!
 是否隐藏顶部视图
 */
@property(nonatomic, assign) BOOL headerHidden;

/*!
 是否将该会话置顶
 */
@property(nonatomic, assign) BOOL switch_isTop;

/*!
 是否接收新通知提醒
 */
@property(nonatomic, assign) BOOL switch_newMessageNotify;

/*!
 顶部视图显示的用户的用户信息RCUserInfo列表
 */
@property(nonatomic, strong) NSArray *users;

/*!
 禁止删除用户
 
 @param disable 是否禁止删除用户
 */
- (void)disableDeleteMemberEvent:(BOOL)disable;

/*!
 设置添加用户
 
 @param disable 是否禁止删除用户
 */
- (void)disableInviteMemberEvent:(BOOL)disable;

/*!
 开闭置顶聊天的回调
 
 @param sender 点击的Switch开关
 */
- (void)onClickIsTopSwitch:(id)sender;

/*!
 开闭新通知提醒的回调
 
 @param sender 点击的Switch开关
 */
- (void)onClickNewMessageNotificationSwitch:(id)sender;

/*!
 点击清除聊天记录的回调
 
 @param sender 清除聊天记录的按钮
 */
- (void)onClickClearMessageHistory:(id)sender;

/*!
 添加用户到顶部视图
 
 @param users 用户信息RCUserInfo列表
 */
- (void)inviteRemoteUsers:(NSArray *)users;

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
 点击删除用户的回调
 
 @param indexPath 当前删除的用户的头像索引值
 
 @discussion 点击头像左上角的删除按钮时的回调。
 */
- (void)deleteTipButtonClicked:(NSIndexPath *)indexPath;

/*!
 点击头像的回调
 
 @param userId 头像对应的用户ID
 */
- (void)didTipHeaderClicked:(NSString*)userId;

@end
