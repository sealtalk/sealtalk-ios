//
//  RCDAddressBookTableViewCell.m
//  RCloudMessage
//
//  Created by Liv on 15/3/13.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDAddressBookTableViewCell.h"
#import "DefaultPortraitView.h"
#import "RCDCommonDefine.h"
#import "RCDUserInfo.h"
#import "UIImageView+WebCache.h"
#import <RongIMKit/RongIMKit.h>

#define CellHeight 65.0f

@implementation RCDAddressBookTableViewCell

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    CGFloat cellWidth = self.frame.size.width;
    CGFloat cellHeight = CellHeight;
    CGFloat screenWidth = RCDscreenWidth;
    if (cellWidth < screenWidth) {
        cellWidth = screenWidth;
    }
    //头像 portraitImageView
    CGFloat portraitImageViewX = 6 + 16;
    CGFloat portraitImageViewY = cellHeight / 2.0 - 36 / 2.0;
    self.portraitImageView =
        [[UIImageView alloc] initWithFrame:CGRectMake(portraitImageViewX, portraitImageViewY, 36, 36)];

    //昵称
    CGFloat nameLabelWidth = 100;
    CGFloat nameLabelHeight = 21;
    CGFloat nameLabelX = CGRectGetMaxX(self.portraitImageView.frame) + 8;
    CGFloat nameLabelY = cellHeight / 2.0 - nameLabelHeight / 2.0;
    self.nameLabel =
        [[UILabel alloc] initWithFrame:CGRectMake(nameLabelX, nameLabelY, nameLabelWidth, nameLabelHeight)];
    self.nameLabel.font = [UIFont systemFontOfSize:17];

    //右侧箭头
    CGFloat arrowWidth = 15;
    CGFloat arrowHeight = cellHeight - 19.5 - 19 - 8 - 8;
    CGFloat arrowX = cellWidth - arrowWidth - 8;
    CGFloat arrowY = cellHeight / 2.0 - arrowHeight / 2.0;
    self.arrow = [[UIImageView alloc] initWithFrame:CGRectMake(arrowX, arrowY, arrowWidth, arrowHeight)];
    self.arrow.image = [UIImage imageNamed:@"grayarrow"];

    //右侧label
    CGFloat rightLabelWidth = 80;
    CGFloat rightLabelHeight = cellHeight - 16.5 - 16;
    CGFloat rightLabelX = CGRectGetMaxX(self.arrow.frame) - 20 - rightLabelWidth;
    CGFloat rightLabelY = 16.5;
    self.rightLabel =
        [[UILabel alloc] initWithFrame:CGRectMake(rightLabelX, rightLabelY, rightLabelWidth, rightLabelHeight)];
    self.rightLabel.font = [UIFont systemFontOfSize:14];
    self.rightLabel.textAlignment = NSTextAlignmentRight;

    //“接受”按钮
    CGFloat acceptBtnWidth = rightLabelWidth - 15;
    CGFloat acceptBtnHeight = rightLabelHeight - 8;
    CGFloat acceptBtnX = cellWidth - acceptBtnWidth - 8;

    CGFloat acceptBtnY = rightLabelY + 5;
    _acceptBtn = [[UIButton alloc] initWithFrame:CGRectMake(acceptBtnX, acceptBtnY, acceptBtnWidth, acceptBtnHeight)];
    _acceptBtn.tag = self.tag;
    [_acceptBtn setTitle:RCDLocalizedString(@"accept") forState:UIControlStateNormal];
    [_acceptBtn setTintColor:[UIColor whiteColor]];
    [_acceptBtn setBackgroundColor:[[UIColor alloc] initWithRed:23 / 255.f green:136 / 255.f blue:213 / 255.f alpha:1]];
    _acceptBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_acceptBtn.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];

    [self.contentView addSubview:self.portraitImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.rightLabel];
    [self.contentView addSubview:self.arrow];
    [self.contentView addSubview:_acceptBtn];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat cellWidth = self.frame.size.width;
    CGFloat screenWidth = RCDscreenWidth;
    if (cellWidth < screenWidth) {
        cellWidth = screenWidth;
    }
    CGFloat arrowX = cellWidth - 15 - 8;
    CGRect arrowFrame = self.arrow.frame;
    arrowFrame.origin.x = arrowX;
    self.arrow.frame = arrowFrame;
    
    CGRect rightLabelFrame = self.rightLabel.frame;
    rightLabelFrame.origin.x = CGRectGetMaxX(self.arrow.frame) - 20 - 80;
    self.rightLabel.frame = rightLabelFrame;
    
    CGRect acceptFrame = self.acceptBtn.frame;
    acceptFrame.origin.x = cellWidth - acceptFrame.size.width - 8;

    self.acceptBtn.frame = acceptFrame;
}

- (void)setModel:(RCDUserInfo *)user {
    if (user) {
        self.nameLabel.text = user.name;
        if ([user.portraitUri isEqualToString:@""]) {
            DefaultPortraitView *defaultPortrait =
                [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
            [defaultPortrait setColorAndLabel:user.userId Nickname:user.name];
            UIImage *portrait = [defaultPortrait imageFromView];
            self.portraitImageView.image = portrait;
        } else {
            [self.portraitImageView sd_setImageWithURL:[NSURL URLWithString:user.portraitUri]
                                      placeholderImage:[UIImage imageNamed:@"contact"]];
        }
    }
    if ([user.status intValue] == 20) {
        self.rightLabel.text = RCDLocalizedString(@"had_accept");
        self.acceptBtn.hidden = YES;
        self.arrow.hidden = NO;
    }
    if ([user.status intValue] == 10) {
        self.rightLabel.text = RCDLocalizedString(@"had_invite");
        self.selected = NO;
        self.arrow.hidden = YES;
        self.acceptBtn.hidden = YES;
    }

    if ([RCIM sharedRCIM].globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
        [RCIM sharedRCIM].globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
        self.portraitImageView.layer.masksToBounds = YES;
        self.portraitImageView.layer.cornerRadius = 18.f;
    } else {
        self.portraitImageView.layer.masksToBounds = YES;
        self.portraitImageView.layer.cornerRadius = 5.f;
    }
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.portraitImageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)cellHeight {
    return CellHeight;
}

@end
