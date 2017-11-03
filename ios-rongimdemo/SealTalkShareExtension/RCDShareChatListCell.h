//
//  RCDShareChatListCell.h
//  RCloudMessage
//
//  Created by 张改红 on 16/8/4.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCDShareChatListCell : UITableViewCell
@property(nonatomic, strong) UIImageView *headerImageView;
@property(nonatomic, strong) UILabel *nameLabel;

- (void)setDataDic:(NSDictionary *)dataDic;
@end
