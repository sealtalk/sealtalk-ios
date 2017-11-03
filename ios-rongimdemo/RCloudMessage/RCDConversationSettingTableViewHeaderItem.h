//
//  RCDConversationSettingTableViewHeaderItem.h
//  RCloudMessage
//
//  Created by 杜立召 on 15/7/21.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDUserInfo.h"
#import <UIKit/UIKit.h>

@protocol RCDConversationSettingTableViewHeaderItemDelegate;

@interface RCDConversationSettingTableViewHeaderItem : UICollectionViewCell

@property(nonatomic, strong) UIImageView *ivAva;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIButton *btnImg;
@property(nonatomic, copy) NSString *userId;
@property(nonatomic, weak) id<RCDConversationSettingTableViewHeaderItemDelegate> delegate;

- (void)setUserModel:(RCUserInfo *)userModel;
@end

@protocol RCDConversationSettingTableViewHeaderItemDelegate <NSObject>

- (void)deleteTipButtonClicked:(RCDConversationSettingTableViewHeaderItem *)item;

@end
