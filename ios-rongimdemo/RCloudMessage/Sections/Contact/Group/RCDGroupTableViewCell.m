//
//  RCDGroupTableViewCell.m
//  RCloudMessage
//
//  Created by 杜立召 on 15/3/19.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDGroupTableViewCell.h"
#import "RCDCommonDefine.h"
#import "RCDGroupInfo.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <RongIMKit/RongIMKit.h>
#import "RCDUtilities.h"
#import <Masonry/Masonry.h>
#import "RCDCommonString.h"

@interface RCDGroupTableViewCell ()

@property (nonatomic, copy) NSString *groupID;

/**
 *  群组名称label
 */
@property (nonatomic, strong) UILabel *groupNameLabel;

/**
 *  群组头像
 */
@property (nonatomic, strong) UIImageView *groupPortImgView;

/**
 *  群组id的label
 */
@property (nonatomic, strong) UILabel *groupIdLabel;

@end

@implementation RCDGroupTableViewCell

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initSubviews];
    }
    return self;
}

#pragma mark - Private Method
- (void)initSubviews {
    self.selectionStyle = UITableViewCellSelectionStyleDefault;

    [self.contentView addSubview:self.groupPortImgView];
    [self.contentView addSubview:self.groupNameLabel];
    [self.contentView addSubview:self.groupIdLabel];

    [self.groupPortImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.height.width.offset(36);
        make.left.equalTo(self.contentView).offset(10);
    }];

    [self.groupNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.groupPortImgView.mas_right).offset(10);
        make.centerY.equalTo(self.contentView);
        make.height.offset(21);
        make.right.equalTo(self.contentView).offset(-10);
    }];

    [self.groupIdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.groupNameLabel).offset(50);
        make.top.equalTo(self.groupNameLabel.mas_bottom);
        make.right.equalTo(self.groupNameLabel);
        make.height.offset(16);
    }];
}

#pragma mark - Public Method
- (void)setModel:(RCDGroupInfo *)group {
    self.groupNameLabel.text = group.groupName;
    BOOL isDisplayID = [DEFAULTS boolForKey:RCDDisplayIDKey];
    if (isDisplayID) {
        self.groupIdLabel.text = group.groupId;
    }
    if ([group.portraitUri isEqualToString:@""]) {
        group.portraitUri = [RCDUtilities defaultGroupPortrait:group];
    }
    [self.groupPortImgView
        sd_setImageWithURL:[NSURL URLWithString:group.portraitUri]
          placeholderImage:[RCKitUtility imageNamed:@"default_group_portrait" ofBundle:@"RongCloud.bundle"]];
}

+ (CGFloat)cellHeight {
    return 54.5f;
}

#pragma mark - Setter && Getter
- (UIImageView *)groupPortImgView {
    if (!_groupPortImgView) {
        _groupPortImgView = [[UIImageView alloc] init];
        if ([RCIM sharedRCIM].globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE &&
            [RCIM sharedRCIM].globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE) {
            _groupPortImgView.layer.cornerRadius = 28.f;
        } else {
            _groupPortImgView.layer.cornerRadius = 5.f;
        }
        _groupPortImgView.layer.masksToBounds = YES;
        _groupPortImgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _groupPortImgView;
}

- (UILabel *)groupNameLabel {
    if (!_groupNameLabel) {
        _groupNameLabel = [[UILabel alloc] init];
        _groupNameLabel.font = [UIFont systemFontOfSize:15];
        _groupNameLabel.textColor = RCDDYCOLOR(0x000000, 0x9f9f9f);
    }
    return _groupNameLabel;
}

- (UILabel *)groupIdLabel {
    if (!_groupIdLabel) {
        _groupIdLabel = [[UILabel alloc] init];
        _groupIdLabel.font = [UIFont systemFontOfSize:12];
        _groupIdLabel.textColor = RCDDYCOLOR(0x000000, 0x9f9f9f);
    }
    return _groupIdLabel;
}

@end
