//
//  RedpacketDetailCell.m
//  RedpacketLib
//
//  Created by Mr.Yan on 16/10/11.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RedpacketDetailCell.h"
#import "RPLayout.h"
#import "UIView+YZHExtension.h"
#import "RedpacketColorStore.h"
#import "UIImageView+YZHWebCache.h"
#import "RPRedpacketTool.h"
#import "NSDictionary+YZHExtern.h"

@interface RedpacketDetailCell ()
@property (nonatomic, strong)    UIImageView *headerImageView;
@property (nonatomic, strong)    UILabel *nameLabel;
@property (nonatomic, strong)    UILabel *timeLabel;
@property (nonatomic, strong)    UILabel *moneyLabel;
@property (nonatomic, strong)    UIImageView *typeImageView;
@property (nonatomic, strong)    UILabel *luckTitleLabel;
@end

@implementation RedpacketDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self loadSubViews];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)loadSubViews
{
    [self.headerImageView rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.left.equalTo(self.rpm_left).offset(15);
        make.centerY.equalTo(self.rpm_centerY).offset(0);
        make.height.offset(36);
        make.width.offset(36);
    }];
    self.headerImageView.layer.cornerRadius  = 36 / 2.0f;
    self.headerImageView.layer.masksToBounds = YES;
    
    [self.nameLabel rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.top.equalTo(self.rpm_top).offset(11);
        make.left.equalTo(self.headerImageView.rpm_right).offset(11);
    }];
    
    [self.timeLabel rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.bottom.equalTo(self.rpm_bottom).offset(-11);
        make.left.equalTo(self.headerImageView.rpm_right).offset(11);
    }];
    
    [self.moneyLabel rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.top.equalTo(self.rpm_top).offset(11);
        make.right.equalTo(self.rpm_right).offset(-15);
    }];
    
    [self.luckTitleLabel rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.bottom.equalTo(self.rpm_bottom).offset(-11);
        make.right.equalTo(self.rpm_right).offset(-15);
    }];
    
    [self.luckeImageView rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.top.equalTo(self.luckTitleLabel.rpm_top).offset(1);
        make.right.equalTo(self.luckTitleLabel.rpm_left).offset(-1);
        make.width.offset(17);
        make.height.offset(13);
    }];
}

- (void)setDetailCellData:(NSDictionary *)detailCellData
{
    _detailCellData = detailCellData;
    NSString *imageUrl = [detailCellData rp_stringForKey:@"Avatar"];
    [self.headerImageView rp_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:rpRedpacketBundleImage(@"redpacket_header")];
    NSString *name = [detailCellData rp_stringForKey:@"Nickname"];
    if (name.length > 11) {
        self.nameLabel.text =  [[name substringToIndex:11] stringByAppendingString:@"..."];
    }else {
        self.nameLabel.text = name;
    }
    
    self.moneyLabel.text = [NSString stringWithFormat:@"%@元",[detailCellData rp_stringForKey:@"Money"]];
    
    
    // 获得当前时间
    NSDate *  senddate=[NSDate date];
    
    NSDateFormatter  *dateformatter = [[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    
    NSString *locationString = [dateformatter stringFromDate:senddate];
    NSString *redpacketTIme = [detailCellData rp_stringIntForKey:@"DateTime"];
    if (redpacketTIme.length > 18) {
        redpacketTIme = [[detailCellData rp_stringIntForKey:@"DateTime"] substringWithRange:NSMakeRange(0, 10)];
        if ([locationString isEqualToString:redpacketTIme]) {//今天的红包
            self.timeLabel.text = [[detailCellData rp_stringIntForKey:@"DateTime"] substringWithRange:NSMakeRange(11, 5)];
        }else if(![[locationString substringWithRange:NSMakeRange(0, 4)] isEqualToString:[redpacketTIme substringWithRange:NSMakeRange(0, 4)]]){//往年的红包
            self.timeLabel.text = [[detailCellData rp_stringIntForKey:@"DateTime"] substringWithRange:NSMakeRange(0, 10)];
        }else{//昨天和今年之内的红包
            self.timeLabel.text = [[detailCellData rp_stringIntForKey:@"DateTime"] substringWithRange:NSMakeRange(5, 11)];
        }
    }else
    {
        self.timeLabel.text = redpacketTIme;
    }
    if ([[detailCellData rp_stringIntForKey:@"IsMaxAmount"] intValue]) {
        self.luckeImageView.hidden = NO;
        self.luckTitleLabel.hidden = NO;
    }else
    {
        self.luckeImageView.hidden = YES;
        self.luckTitleLabel.hidden = YES;
    }
}

- (UIImageView *)headerImageView
{
    if (!_headerImageView) {
        _headerImageView = [self rp_addsubview:[UIImageView class]];
        _headerImageView.backgroundColor = [RedpacketColorStore rp_backGroundGrayColor];
    }
    return _headerImageView;
}

- (UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [self rp_addsubview:[UILabel class]];
        _nameLabel.font = [UIFont systemFontOfSize:15.0];
        _nameLabel.textColor = [RedpacketColorStore rp_textColorBlack];
    }
    return _nameLabel;
}

- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [self rp_addsubview:[UILabel class]];
        _timeLabel.font = [UIFont systemFontOfSize:12.0];
        _timeLabel.textColor = [RedpacketColorStore rp_textColorGray];
    }
    return _timeLabel;
}

- (UILabel *)moneyLabel
{
    if (!_moneyLabel) {
        _moneyLabel = [self rp_addsubview:[UILabel class]];
        _moneyLabel.font = [UIFont systemFontOfSize:15.0];
        _moneyLabel.textColor = [RedpacketColorStore rp_textColorBlack];
        _moneyLabel.textAlignment = NSTextAlignmentRight;
    }
    return _moneyLabel;
}

- (UIImageView *)luckeImageView
{
    if (!_typeImageView) {
        _typeImageView = [self rp_addsubview:[UIImageView class]];
        [_typeImageView setImage:rpRedpacketBundleImage(@"redpacket_luckyBest")];
    }
    return _typeImageView;
}

- (UILabel *)luckTitleLabel
{
    if (!_luckTitleLabel) {
        _luckTitleLabel = [self rp_addsubview:[UILabel class]];
        _luckTitleLabel.font = [UIFont systemFontOfSize:12.0];
        _luckTitleLabel.textColor = [RedpacketColorStore rp_besetLuckyColor];
        _luckTitleLabel.text = @"手气最佳";
    }
    return _luckTitleLabel;
}

@end
