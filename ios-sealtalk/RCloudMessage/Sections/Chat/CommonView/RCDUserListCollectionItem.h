//
//  RCDUserListCollectionItem.h
//  RCloudMessage
//
//  Created by 杜立召 on 15/7/21.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDFriendInfo.h"
#import <UIKit/UIKit.h>

@protocol RCDUserListCollectionItemDelegate;

@interface RCDUserListCollectionItem : UICollectionViewCell

@property (nonatomic, strong) UIImageView *ivAva;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *btnImg;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, weak) id<RCDUserListCollectionItemDelegate> delegate;

- (void)setUserModel:(NSString *)userId;
@end

@protocol RCDUserListCollectionItemDelegate <NSObject>

- (void)deleteTipButtonClicked:(RCDUserListCollectionItem *)item;

@end
