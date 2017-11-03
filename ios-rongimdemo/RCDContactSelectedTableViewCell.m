//
//  RCDContactSelectedTableViewCell.m
//  RCloudMessage
//
//  Created by Jue on 16/3/17.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDContactSelectedTableViewCell.h"
#import "DefaultPortraitView.h"
#import "RCDUserInfo.h"
#import "UIImageView+WebCache.h"
#import <RongIMKit/RongIMKit.h>

#define CellHeight 70.0f

@implementation RCDContactSelectedTableViewCell

+ (instancetype)contactSelectedTableViewCell {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    CGFloat cellHeigth = CellHeight;
    CGFloat cellWidth = self.frame.size.width;
    // selectedImageView
    CGFloat selectedImageViewWidth = 21;
    CGFloat selectedImageViewHeight = selectedImageViewWidth;
    CGFloat selectedImageViewX = 11 + 16;
    CGFloat selectedImageViewY = cellHeigth / 2.0 - selectedImageViewWidth / 2.0;
    self.selectedImageView =
        [[UIImageView alloc] initWithFrame:CGRectMake(selectedImageViewX, selectedImageViewY, selectedImageViewWidth,
                                                      selectedImageViewHeight)];
    self.selectedImageView.image = [UIImage imageNamed:@"unselect"];

    // portraitImageView
    CGFloat portraitImageViewWidth = 40;
    CGFloat portraitImageViewHeight = 40;
    CGFloat portraitImageViewX = CGRectGetMaxX(self.selectedImageView.frame) + 8;
    CGFloat portraitImageViewY = cellHeigth / 2.0 - portraitImageViewHeight / 2.0;
    self.portraitImageView =
        [[UIImageView alloc] initWithFrame:CGRectMake(portraitImageViewX, portraitImageViewY, portraitImageViewWidth,
                                                      portraitImageViewHeight)];

    // nicknameLabel
    CGFloat nicknameLabelWidth = cellWidth - CGRectGetMaxX(self.portraitImageView.frame) - 8 - 60;
    CGFloat nicknameLabelHeigth = cellHeigth - 15 - 17;
    CGFloat nicknameLabelX = CGRectGetMaxX(self.portraitImageView.frame) + 8;
    CGFloat nicknameLabelY = cellHeigth / 2.0 - nicknameLabelHeigth / 2.0;
    self.nicknameLabel = [[UILabel alloc]
        initWithFrame:CGRectMake(nicknameLabelX, nicknameLabelY, nicknameLabelWidth, nicknameLabelHeigth)];

    [self.contentView addSubview:self.selectedImageView];
    [self.contentView addSubview:self.portraitImageView];
    [self.contentView addSubview:self.nicknameLabel];
}

- (void)setModel:(RCDUserInfo *)user {
    if (user) {
        self.nicknameLabel.text = user.name;
        if ([user.portraitUri isEqualToString:@""]) {
            DefaultPortraitView *defaultPortrait =
                [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
            [defaultPortrait setColorAndLabel:user.userId Nickname:user.name];
            UIImage *portrait = [defaultPortrait imageFromView];
            self.portraitImageView.image = portrait;
        } else {
            [self.portraitImageView sd_setImageWithURL:[NSURL URLWithString:user.portraitUri]
                                      placeholderImage:[UIImage imageNamed:@"icon_person"]];
        }
    }
    if ([RCIM sharedRCIM].globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
        [RCIM sharedRCIM].globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
        self.portraitImageView.layer.masksToBounds = YES;
        self.portraitImageView.layer.cornerRadius = 20.f;
    } else {
        self.portraitImageView.layer.masksToBounds = YES;
        self.portraitImageView.layer.cornerRadius = 5.f;
    }
    self.portraitImageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        _selectedImageView.image = [UIImage imageNamed:@"select"];
    } else {
        _selectedImageView.image = [UIImage imageNamed:@"unselect"];
    }
    // Configure the view for the selected state
}

+ (CGFloat)cellHeight {
    return CellHeight;
}

@end
