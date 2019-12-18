//
//  RCDContactTableViewCell.h
//  RCloudMessage
//
//  Created by Jue on 16/3/16.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDTableViewCell.h"
@class RCUserInfo;

typedef void (^LongPressBlock)(NSString *userId);

@interface RCDContactTableViewCell : RCDTableViewCell

@property (nonatomic, copy) LongPressBlock longPressBlock;

@property (nonatomic, strong) UIImageView *portraitView;

@property (nonatomic, strong) UILabel *nicknameLabel;

@property (nonatomic, strong) UILabel *userIdLabel;

@property (nonatomic, strong) UILabel *noticeLabel;

- (void)showNoticeLabel:(int)noticeCount;

- (void)setModel:(RCUserInfo *)userInfo;

@end
