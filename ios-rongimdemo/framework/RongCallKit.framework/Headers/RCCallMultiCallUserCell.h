//
//  RCCallMultiCallUserCell.h
//  RongCallKit
//
//  Created by litao on 16/3/22.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCCallUserCallInfoModel.h"
#import <UIKit/UIKit.h>
@class RCloudImageView;

/*!
 多人音视频界面的用户Cell
 */
@interface RCCallMultiCallUserCell : UICollectionViewCell

/*!
 用户的头像View（视频时会使用此View作为用户的视频View）
 */
@property(nonatomic, strong) RCloudImageView *headerImageView;

/*!
 用户名字的Label
 */
@property(nonatomic, strong) UILabel *nameLabel;

/*!
 用户状态的Label
 */
@property(nonatomic, strong) UIImageView *statusView;

/*!
 设置用户通话信息和通话状态

 @param model      用户通话信息的Model
 @param callStatus 用户通话状态
 */
- (void)setModel:(RCCallUserCallInfoModel *)model status:(RCCallStatus)callStatus;

@end
