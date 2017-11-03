//
//  RCDPrivateSettingsUserInfoCell.h
//  RCloudMessage
//
//  Created by Jue on 16/5/17.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCDPrivateSettingsUserInfoCell : UITableViewCell

@property(strong, nonatomic) UIImageView *PortraitImageView;

@property(strong, nonatomic) UILabel *NickNameLabel;

@property(strong, nonatomic) UILabel *displayNameLabel;

- (id)initWithIsHaveDisplayName:(BOOL)isHaveDisplayName;
@end
