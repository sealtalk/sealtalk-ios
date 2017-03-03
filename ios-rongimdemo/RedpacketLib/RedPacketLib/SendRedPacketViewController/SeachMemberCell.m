//
//  SeachMemberCell.m
//  RedpacketLib
//
//  Created by Mr.Yan on 2016/10/24.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "SeachMemberCell.h"
#import "RPLayout.h"
#import "UIView+YZHExtension.h"
#import "RedpacketColorStore.h"
#import "UIImageView+YZHWebCache.h"
#import "RPRedpacketTool.h"
#import "NSDictionary+YZHExtern.h"

@implementation SeachMemberCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self loadSubviews];
    }
    return self;
}

- (void)loadSubviews
{
    self.headImageView.frame = CGRectMake(15, (self.bounds.size.height - 40) * .5, 40, 40);
    [self.headImageView rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.left.equalTo(self.rpm_left).offset(15);
        make.centerY.equalTo(self.rpm_centerY).offset(0);
        make.width.offset(36);
        make.height.offset(36);
    }];
    self.headImageView.layer.masksToBounds = YES;
    self.headImageView.layer.cornerRadius = 18.0;
    self.headImageView.layer.borderColor = [[UIColor clearColor] CGColor];

    self.nameLabel.frame = CGRectMake(80, 0, self.bounds.size.width, self.bounds.size.height);
    [self.nameLabel rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.height.equalTo(self.rpm_height).offset(0);
        make.left.equalTo(self.rpm_left).offset(80);
        make.width.equalTo(self.rpm_width).offset(-80);
        make.top.equalTo(self.rpm_top).offset(0);
    }];
}

- (UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [self rp_addsubview:[UILabel class]];
        _nameLabel.font = [UIFont systemFontOfSize:17.0];
        _nameLabel.textColor = [RedpacketColorStore rp_textColorBlack];
    }
    return _nameLabel;
}

- (UIImageView *)headImageView
{
    if (!_headImageView) {
        _headImageView = [self rp_addsubview:[UIImageView class]];
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _headImageView;
}

@end
