//
//  RCDContactTableViewCell.h
//  RCloudMessage
//
//  Created by Jue on 16/3/16.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RCUserInfo;
@interface RCDContactTableViewCell : UITableViewCell

@property(nonatomic, strong) UIImageView *portraitView;

@property(nonatomic, strong) UILabel *nicknameLabel;

@property(nonatomic, strong) UILabel *userIdLabel;

- (void)setModel:(RCUserInfo *)userInfo;

@end
