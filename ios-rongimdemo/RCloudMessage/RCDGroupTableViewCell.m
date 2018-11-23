//
//  RCDGroupTableViewCell.m
//  RCloudMessage
//
//  Created by 杜立召 on 15/3/19.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDGroupTableViewCell.h"
#import "DefaultPortraitView.h"
#import "RCDCommonDefine.h"
#import "RCDGroupInfo.h"
#import "UIImageView+WebCache.h"
#import <RongIMKit/RongIMKit.h>

#define CellHeight 54.5f

@implementation RCDGroupTableViewCell

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    CGFloat cellWidth = RCDscreenWidth;
    CGFloat cellHeight = CellHeight;
    //群组头像
    CGFloat imvGroupPortWidth = 36;
    CGFloat imvGroupPortHeight = imvGroupPortWidth;
    CGFloat imvGroupPortX = 10;
    CGFloat imvGroupPortY = cellHeight / 2.0 - imvGroupPortHeight / 2.0;
    self.imvGroupPort = [[UIImageView alloc]
        initWithFrame:CGRectMake(imvGroupPortX, imvGroupPortY, imvGroupPortWidth, imvGroupPortHeight)];
    //切圆角
    self.imvGroupPort.layer.masksToBounds = YES;
    self.imvGroupPort.layer.cornerRadius = 2.f;

    //群组名称
    CGFloat lblGroupNameHeight = 21;
    CGFloat lblGroupNameX = CGRectGetMaxX(self.imvGroupPort.frame) + 10;
    CGFloat lblGroupNameY = cellHeight / 2.0 - lblGroupNameHeight / 2.0;
    CGFloat lblGroupNameWidth = cellWidth - 100 - lblGroupNameX;
    self.lblGroupName =
        [[UILabel alloc] initWithFrame:CGRectMake(lblGroupNameX, lblGroupNameY, lblGroupNameWidth, lblGroupNameHeight)];
    self.lblGroupName.font = [UIFont systemFontOfSize:15];

    //群组id
    CGFloat lblGroupIdWidth = 200;
    CGFloat lblGroupIdHeight = 21;
    CGFloat lblGroupIdX = 100;
    CGFloat lblGroupIdY = CGRectGetMaxY(self.lblGroupName.frame) - 2;
    self.lblGroupId =
        [[UILabel alloc] initWithFrame:CGRectMake(lblGroupIdX, lblGroupIdY, lblGroupIdWidth, lblGroupIdHeight)];
    self.lblGroupId.font = [UIFont systemFontOfSize:12];

    [self.contentView addSubview:self.imvGroupPort];
    [self.contentView addSubview:self.lblGroupName];
    [self.contentView addSubview:self.lblGroupId];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setModel:(RCDGroupInfo *)group {
    self.lblGroupName.text = group.groupName;
    self.groupID = group.groupId;
    if ([RCIM sharedRCIM].globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE &&
        [RCIM sharedRCIM].globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE) {
        self.imvGroupPort.layer.masksToBounds = YES;
        self.imvGroupPort.layer.cornerRadius = 28.f;
    } else {
        self.imvGroupPort.layer.masksToBounds = YES;
        self.imvGroupPort.layer.cornerRadius = 5.f;
    }

    if ([group.portraitUri isEqualToString:@""]) {
        DefaultPortraitView *defaultPortrait = [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [defaultPortrait setColorAndLabel:group.groupId Nickname:group.groupName];
        UIImage *portrait = [defaultPortrait imageFromView];
        self.imvGroupPort.image = portrait;
    } else {
        [self.imvGroupPort sd_setImageWithURL:[NSURL URLWithString:group.portraitUri]
                             placeholderImage:[UIImage imageNamed:@"icon_person"]];
    }
    self.imvGroupPort.contentMode = UIViewContentModeScaleAspectFill;
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)cellHeight {
    return CellHeight;
}

@end
