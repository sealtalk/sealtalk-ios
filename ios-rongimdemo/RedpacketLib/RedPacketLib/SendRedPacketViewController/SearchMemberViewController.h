//
//  SearchMemberViewController.h
//  RedpacketLib
//
//  Created by Mr.Yan on 16/6/5.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "YZHRefreshTableViewController.h"
#import "RedpacketMessageModel.h"

@protocol SearchMemberViewDelegate <NSObject>
@optional
- (void)receiverInfos:(NSArray<RedpacketUserInfo *>*)userInfos;
- (void)getGroupMemberListCompletionHandle:(void (^)(NSArray<RedpacketUserInfo *> * groupMemberList))completionHandle;

@end

@interface SearchMemberViewController : YZHRefreshTableViewController

@property (nonatomic,weak) id<SearchMemberViewDelegate> delegate;

@end
