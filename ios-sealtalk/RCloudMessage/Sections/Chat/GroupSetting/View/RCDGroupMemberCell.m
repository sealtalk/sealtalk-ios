//
//  RCDGroupMemberCell.m
//  SealTalk
//
//  Created by 张改红 on 2019/6/18.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDGroupMemberCell.h"
#import <Masonry/Masonry.h>
#import "RCDUserInfoManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "RCDUtilities.h"
@interface RCDGroupMemberCell ()
@property (nonatomic, strong) UILabel *rightLabel;

@end
@implementation RCDGroupMemberCell
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    RCDGroupMemberCell *cell =
        (RCDGroupMemberCell *)[tableView dequeueReusableCellWithIdentifier:RCDGroupMemberCellIdentifier];
    if (!cell) {
        cell = [[RCDGroupMemberCell alloc] init];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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

- (void)setUserRole:(NSString *)role {
    self.rightLabel.text = role;
}

- (void)addSubviews {
    [self.contentView addSubview:self.portraitImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.rightLabel];
    [self.portraitImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(12);
        make.height.width.offset(40);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.portraitImageView.mas_right).offset(9);
        make.width.offset(150);
        make.height.offset(24);
    }];

    [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right);
        make.centerY.equalTo(self.contentView);
        make.width.offset(100);
        make.height.offset(23);
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

- (UILabel *)rightLabel {
    if (!_rightLabel) {
        _rightLabel = [[UILabel alloc] init];
        _rightLabel.font = [UIFont systemFontOfSize:16];
        _rightLabel.textAlignment = NSTextAlignmentRight;
        _rightLabel.textColor = RCDDYCOLOR(0x939393, 0x666666);
    }
    return _rightLabel;
}
@end
