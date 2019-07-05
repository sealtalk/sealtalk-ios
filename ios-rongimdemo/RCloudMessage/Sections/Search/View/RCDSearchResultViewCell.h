//
//  RCDSearchResultViewCell.h
//  RCloudMessage
//
//  Created by 张改红 on 16/9/8.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RCDSearchResultModel;
@class RCDLabel;
@interface RCDSearchResultViewCell : UITableViewCell
@property(nonatomic, strong) UIImageView *headerView;
@property(nonatomic, strong) RCDLabel *nameLabel;
@property(nonatomic, strong) RCDLabel *additionalLabel;
@property(nonatomic, strong) NSString *searchString;

- (void)setDataModel:(RCDSearchResultModel *)model;
@end
