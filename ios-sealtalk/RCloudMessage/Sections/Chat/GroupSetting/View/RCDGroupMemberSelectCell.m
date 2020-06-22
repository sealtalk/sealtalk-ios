//
//  RCDGroupMemberSelectCell.m
//  SealTalk
//
//  Created by 张改红 on 2019/6/18.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDGroupMemberSelectCell.h"
#import <Masonry/Masonry.h>
#import "RCDUserInfoManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "RCDUtilities.h"

@interface RCDGroupMemberSelectCell ()
@property (nonatomic, strong) UIImageView *selectIcon;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UIImageView *portraitImageView;
@end
@implementation RCDGroupMemberSelectCell
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    RCDGroupMemberSelectCell *cell =
        (RCDGroupMemberSelectCell *)[tableView dequeueReusableCellWithIdentifier:RCDGroupMemberSelectCellIdentifier];
    if (!cell) {
        cell = [[RCDGroupMemberSelectCell alloc] init];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubviews];
    }
    return self;
}

- (void)setDataModel:(NSString *)userId groupId:(nonnull NSString *)groupId {
    __weak typeof(self) weakSelf = self;
    [RCDUtilities getGroupUserDisplayInfo:userId
                                  groupId:groupId
                                   result:^(RCUserInfo *user) {
                                       [weakSelf.portraitImageView
                                           sd_setImageWithURL:[NSURL URLWithString:user.portraitUri]
                                             placeholderImage:[UIImage imageNamed:@"contact"]];
                                       weakSelf.nameLabel.text = user.name;
                                   }];
}

- (void)setCellSelectState:(RCDGroupMemberSelectCellState)state {
    self.userInteractionEnabled = YES;
    if (state == RCDGroupMemberSelectCellStateDisable) {
        self.userInteractionEnabled = NO;
        self.selectIcon.image = [UIImage imageNamed:@"disable_select"];
    } else if (state == RCDGroupMemberSelectCellStateUnselected) {
        self.selectIcon.image = [UIImage imageNamed:@"forward_unselected"];
    } else if (state == RCDGroupMemberSelectCellStateSelected) {
        self.selectIcon.image = [UIImage imageNamed:@"forward_selected"];
    }
}

- (void)addSubviews {
    [self.contentView addSubview:self.portraitImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.selectIcon];

    [self.selectIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(12);
        make.height.width.offset(22);
    }];

    [self.portraitImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.selectIcon.mas_right).offset(9);
        make.height.width.offset(40);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.portraitImageView.mas_right).offset(9);
        make.width.offset(150);
        make.height.offset(24);
    }];
}

#pragma mark - getter
- (UIImageView *)portraitImageView {
    if (!_portraitImageView) {
        _portraitImageView = [[UIImageView alloc] init];
        _portraitImageView.layer.cornerRadius = 2.f;
        _portraitImageView.layer.masksToBounds = YES;
        _portraitImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _portraitImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:17];
        _nameLabel.textColor = RCDDYCOLOR(0x262626, 0x9f9f9f);
    }
    return _nameLabel;
}

- (UIImageView *)selectIcon {
    if (!_selectIcon) {
        _selectIcon = [[UIImageView alloc] init];
        [self setCellSelectState:(RCDGroupMemberSelectCellStateUnselected)];
    }
    return _selectIcon;
}
@end
