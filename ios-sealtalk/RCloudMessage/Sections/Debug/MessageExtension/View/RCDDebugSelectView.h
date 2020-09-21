//
//  RCDDebugSelectItem.h
//  SealTalk
//
//  Created by 张改红 on 2020/8/5.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol RCDDebugSelectViewDelegate <NSObject>

@optional

/**
 *  点击头像的回调
 *
 *  @param userId 用户id
 */
- (void)didTipItemClicked:(NSIndexPath *)indexPath;

@end
@interface RCDDebugSelectView : UICollectionView

@property (nonatomic, weak) id<RCDDebugSelectViewDelegate> debugSelectViewDelegate;

- (instancetype)initWithFrame:(CGRect)rect titleList:(NSArray *)titleList;

- (void)reloadData:(NSArray *)titleList;

@end

NS_ASSUME_NONNULL_END
