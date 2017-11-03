//
//  RCDUserListTableViewCell.m
//  RCloudMessage
//
//  Created by Sin on 16/8/19.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDUserListTableViewCell.h"
#import <RongIMKit/RongIMKit.h>

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
@implementation RCDUserListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //布局View
        [self setUpView];
    }
    return self;
}

#pragma mark - setUpView
- (void)setUpView {
    //头像
    [self.contentView addSubview:self.headImageView];
    //姓名
    [self.contentView addSubview:self.nameLabel];
}
- (UIImageView *)headImageView {
    if (!_headImageView) {
        _headImageView =
            [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 5.0, [RCIM sharedRCIM].globalMessagePortraitSize.width,
                                                          [RCIM sharedRCIM].globalMessagePortraitSize.height)];

        if ([RCIM sharedRCIM].globalMessageAvatarStyle == RC_USER_AVATAR_RECTANGLE) {
            _headImageView.layer.cornerRadius = [[RCIM sharedRCIM] portraitImageViewCornerRadius];
        }
        if ([RCIM sharedRCIM].globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
            _headImageView.layer.cornerRadius = [[RCIM sharedRCIM] globalMessagePortraitSize].height / 2;
        }
    }
    _headImageView.layer.masksToBounds = YES;
    [_headImageView setContentMode:UIViewContentModeScaleAspectFit];
    return _headImageView;
}
- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 5.0, kScreenWidth - 60.0, 40.0)];
        [_nameLabel setFont:[UIFont systemFontOfSize:16.0]];
    }
    return _nameLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
