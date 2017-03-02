//
//  RCSettingViewController.h
//  RongIMKit
//
//  Created by Liv on 15/4/20.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCConversationSettingTableViewController.h"

/*!
 清空会话中所有消息的回调
 
 @param isSuccess 是否删除会话中的所有消息
 */
typedef void (^clearHistory)(BOOL isSuccess);

/*!
 会话设置的ViewController
 */
@interface RCSettingViewController : RCConversationSettingTableViewController

/*!
当前会话的目标会话ID
*/
@property(nonatomic, copy) NSString *targetId;

/*!
 当前会话的会话类型
 */
@property(nonatomic, assign) RCConversationType conversationType;

/*!
 清空会话中所有消息的回调
 
 @discussion 在清空消息的的回调中,您需要调用会话页面的reloadData进行刷新。
 */
@property(nonatomic, copy) clearHistory clearHistoryCompletion;

/*!
 清空会话中所有消息的ActionSheet
 */
@property(nonatomic, readonly, strong) UIActionSheet *clearMsgHistoryActionSheet;

/*!
 清空会话中所有消息
 */
- (void)clearHistoryMessage;

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

@end
