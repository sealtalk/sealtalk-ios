//
//  RCDFriendListViewController.h
//  RCloudMessage
//
//  Created by Sin on 16/8/19.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>
#import <UIKit/UIKit.h>

@protocol RCDFriendListViewControllerDelegate <NSObject>

- (void)getFriendList:(void (^)(NSArray<NSString *> *friendList))complete;

@end

@interface RCDFriendListViewController : UITableViewController
@property(nonatomic, copy) void (^selectedBlock)(RCUserInfo *selectedUserInfo);
@property(nonatomic, copy) void (^cancelBlock)();

@property(nonatomic, weak) id<RCDFriendListViewControllerDelegate> delegate;

@property(nonatomic, strong) NSString *navigationTitle;

@property(nonatomic, assign) RCConversationType conversationType;
@property(nonatomic, strong) NSString *targetId;
@end
