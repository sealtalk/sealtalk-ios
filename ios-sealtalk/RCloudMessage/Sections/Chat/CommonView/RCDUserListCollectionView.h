//
//  RCDUserListCollectionView.h
//  SealTalk
//
//  Created by 张改红 on 2019/5/31.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RCDUserListCollectionViewDelegate <NSObject>

@optional
/**
 *  点击删除的回调
 *
 *  @param indexPath 点击索引
 */
- (void)addButtonDidClicked;
/**
 *  点击删除的回调
 *
 *  @param indexPath 点击索引
 */
- (void)deleteButtonDidClicked;

/**
 *  点击头像的回调
 *
 *  @param userId 用户id
 */
- (void)didTipHeaderClicked:(NSString *)userId;

@end
@interface RCDUserListCollectionView : UICollectionView
@property (nonatomic, weak) id<RCDUserListCollectionViewDelegate> userListCollectionViewDelegate;

@property (nonatomic, strong) NSString *groupId;
- (instancetype)initWithFrame:(CGRect)frame isAllowAdd:(BOOL)isAllowAdd isAllowDelete:(BOOL)isAllowDelete;
- (void)reloadData:(NSArray *)userList;
@end
