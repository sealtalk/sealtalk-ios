//
//  RCDGroupManagerCell.m
//  SealTalk
//
//  Created by 张改红 on 2019/6/18.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDGroupManagerCell.h"
#import <Masonry/Masonry.h>
#import "RCDUtilities.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface RCDGroupManagerCell ()
@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UIImageView *portraitImageView;

@property (nonatomic, strong) UIButton *deleteButton;

@property (nonatomic, strong) NSString *userId;
@end
@implementation RCDGroupManagerCell
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    RCDGroupManagerCell *cell =
        (RCDGroupManagerCell *)[tableView dequeueReusableCellWithIdentifier:RCDGroupManagerCellIdentifier];
    if (!cell) {
        cell = [[RCDGroupManagerCell alloc] init];
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

- (void)setDataModel:(NSString *)userId groupId:(NSString *)groupId {
    [self deleteButtonIsShow:NO];
    if (userId.length == 0) {
        self.nameLabel.textColor = HEXCOLOR(0x939393);
        self.nameLabel.text = RCDLocalizedString(@"GroupManagerAdd");
        self.portraitImageView.image = [UIImage imageNamed:@"groupmanageradd"];
    } else {
        self.userId = userId;
        self.nameLabel.textColor = RCDDYCOLOR(0x262626, 0x9f9f9f);
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
}

- (void)deleteButtonShow {
    [self deleteButtonIsShow:YES];
}

- (void)deleteButtonIsShow:(BOOL)isShow {
    self.deleteButton.hidden = !isShow;
    self.deleteButton.enabled = isShow;
}

- (void)didClickDeleteButton {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectUserId:)]) {
        [self.delegate didSelectUserId:self.userId];
    }
}

- (void)addSubviews {
    [self.contentView addSubview:self.portraitImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.deleteButton];
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

    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-12);
        make.centerY.equalTo(self.contentView);
        make.width.offset(22);
        make.height.offset(22);
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

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [[UIButton alloc] init];
        [_deleteButton setImage:[UIImage imageNamed:@"groupmanagerdelete"] forState:(UIControlStateNormal)];
        [_deleteButton addTarget:self
                          action:@selector(didClickDeleteButton)
                forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _deleteButton;
}
@end
