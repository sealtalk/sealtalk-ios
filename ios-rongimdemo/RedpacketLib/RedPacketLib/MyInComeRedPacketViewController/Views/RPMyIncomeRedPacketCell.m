//
//  RPMyIncomeRedPacketCell.m
//  RedpacketLib
//
//  Created by Mr.Yan on 2016/10/31.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPMyIncomeRedPacketCell.h"
#import "RPLayout.h"
#import "UIView+YZHExtension.h"
#import "RedpacketColorStore.h"
#import "UIImageView+YZHWebCache.h"
#import "RPRedpacketTool.h"
#import "NSDictionary+YZHExtern.h"

@interface RPMyIncomeRedPacketCell ()

@property (nonatomic, strong) UILabel *nameLable;
@property (nonatomic, strong) UIImageView *typeImageView;
@property (nonatomic, strong) UILabel *timeLable;
@property (nonatomic, strong) UILabel *moneyLabel;
@property (nonatomic, strong) UILabel *sourceLable;

@end

@implementation RPMyIncomeRedPacketCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self loadSubViews];
    }
    return self;
}

- (void)loadSubViews
{
    [self.nameLable rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.top.equalTo(self.rpm_top).offset(11);
        make.left.equalTo(self.rpm_left).offset(15);
    }];
    
    [self.typeImageView rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.left.equalTo(self.nameLable.rpm_right).offset(2);
        make.centerY.equalTo(self.nameLable.rpm_centerY).offset(0);
    }];
    
    [self.timeLable rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.bottom.equalTo(self.rpm_bottom).offset(-11);
        make.left.equalTo(self.rpm_left).offset(15);
    }];
 
    [self.moneyLabel rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.top.equalTo(self.rpm_top).offset(11);
        make.right.equalTo(self.rpm_right).offset(-15);
    }];
    
    [self.sourceLable rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.bottom.equalTo(self.rpm_bottom).offset(-11);
        make.right.equalTo(self.rpm_right).offset(-15);
    }];
    
    UIView * lineView = [self rp_addsubview:[UIView class]];
    lineView.backgroundColor = [RedpacketColorStore rp_lineColorLightGray];
    [lineView rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.right.equalTo(self);
         make.left.equalTo(self).offset(15);
        make.height.offset(RP_(@(0.5)).floatValue);
        make.bottom.equalTo(self);
    }];
}

- (void)setIncomeCellData:(NSDictionary *)incomeCellData
{
    _incomeCellData = incomeCellData;
    
    if (self.isSend) {
        self.typeImageView.hidden = YES;
        self.nameLable.text = [incomeCellData rp_stringForKey:@"Type"];
        
        NSString *dataTime;
        // 获得当前时间
        NSDate *  senddate=[NSDate date];
        NSDateFormatter  *dateformatter = [[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"YYYY-MM-dd"];
        NSString *locationString = [dateformatter stringFromDate:senddate];
        NSString *redpacketTIme = [[incomeCellData rp_stringIntForKey:@"DateTime"] substringWithRange:NSMakeRange(0, 10)];
        if ([locationString isEqualToString:redpacketTIme]) {//今天的红包
            dataTime = [[incomeCellData rp_stringIntForKey:@"DateTime"] substringWithRange:NSMakeRange(11, 5)];
        }else if(![[locationString substringWithRange:NSMakeRange(0, 4)] isEqualToString:[redpacketTIme substringWithRange:NSMakeRange(0, 4)]]){//往年的红包
            dataTime = [[incomeCellData rp_stringIntForKey:@"DateTime"] substringWithRange:NSMakeRange(0, 10)];
        }else{//昨天和今年之内的红包
            dataTime = [[incomeCellData rp_stringIntForKey:@"DateTime"] substringWithRange:NSMakeRange(5, 5)];
        }
        
        self.timeLable.text = [NSString stringWithFormat:@"%@ %@",dataTime,[incomeCellData rp_stringForKey:@"ProductName"]];
        
        self.moneyLabel.text = [NSString stringWithFormat:@"%@元",[incomeCellData rp_stringFloatForKey:@"Money"]];
        if ([[incomeCellData rp_stringIntForKey:@"TakenCount"] intValue] == [[incomeCellData rp_stringIntForKey:@"TotalCount"] intValue]) {
            self.sourceLable.text = [NSString stringWithFormat:@"已领完%@/%@个",[incomeCellData rp_stringIntForKey:@"TakenCount"],[incomeCellData rp_stringIntForKey:@"TotalCount"]];
        }else
        {
            self.sourceLable.text = [NSString stringWithFormat:@"已领取%@/%@个",[incomeCellData rp_stringIntForKey:@"TakenCount"],[incomeCellData rp_stringIntForKey:@"TotalCount"]];
        }

    }else
    {
        NSString *name = [incomeCellData rp_stringForKey:@"Nickname"];
        if (name.length > 11) {
            self.nameLable.text =  [[name substringToIndex:11] stringByAppendingString:@"..."];
        }else {
            self.nameLable.text = name;
        }
        self.sourceLable.text = [incomeCellData rp_stringForKey:@"ProductName"];
        self.moneyLabel.text = [NSString stringWithFormat:@"%@元",[incomeCellData rp_stringFloatForKey:@"Money"]];
        
        self.typeImageView.hidden = NO;
        if ([[incomeCellData rp_stringForKey:@"Type"] isEqualToString:@"rand"]) {
            [self.typeImageView setImage:rpRedpacketBundleImage(@"redPackert_luckCard")];
        }else if ([[incomeCellData rp_stringForKey:@"Type"] isEqualToString:@"member"]) {
            [self.typeImageView setImage:rpRedpacketBundleImage(@"redPackert_toSomebody")];
        }else{
            self.typeImageView.hidden = YES;
        }
        
        // 获得当前时间
        NSDate *  senddate=[NSDate date];
        NSDateFormatter  *dateformatter = [[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"YYYY-MM-dd"];
        NSString *locationString = [dateformatter stringFromDate:senddate];
        NSString *redpacketTIme = [[incomeCellData rp_stringIntForKey:@"DateTime"] substringWithRange:NSMakeRange(0, 10)];
        if ([locationString isEqualToString:redpacketTIme]) {//今天的红包
            self.timeLable.text = [[incomeCellData rp_stringIntForKey:@"DateTime"] substringWithRange:NSMakeRange(11, 5)];
        }else if(![[locationString substringWithRange:NSMakeRange(0, 4)] isEqualToString:[redpacketTIme substringWithRange:NSMakeRange(0, 4)]]){//往年的红包
            self.timeLable.text = [[incomeCellData rp_stringIntForKey:@"DateTime"] substringWithRange:NSMakeRange(0, 10)];
        }else{//昨天和今年之内的红包
            self.timeLable.text = [[incomeCellData rp_stringIntForKey:@"DateTime"] substringWithRange:NSMakeRange(5, 5)];
        }

    }
}

- (UILabel *)nameLable
{
    if (!_nameLable) {
        _nameLable = [self rp_addsubview:[UILabel class]];
        _nameLable.font = [UIFont systemFontOfSize:15.0f];
        _nameLable.textColor = [RedpacketColorStore rp_textColorBlack];
    }
    return _nameLable;
}

- (UIImageView *)typeImageView
{
    if (!_typeImageView) {
        _typeImageView = [self rp_addsubview:[UIImageView class]];
    }
    return _typeImageView;
}

- (UILabel *)timeLable
{
    if (!_timeLable) {
        _timeLable = [self rp_addsubview:[UILabel class]];
        _timeLable.font = [UIFont systemFontOfSize:12.0f];
        _timeLable.textColor = [RedpacketColorStore rp_textColorGray];
    }
    return _timeLable;
}

- (UILabel *)moneyLabel
{
    if (!_moneyLabel) {
        _moneyLabel = [self rp_addsubview:[UILabel class]];
        _moneyLabel.font = [UIFont systemFontOfSize:15.0f];
        _moneyLabel.textColor = [RedpacketColorStore rp_textColorBlack];
    }
    return _moneyLabel;
}

- (UILabel *)sourceLable
{
    if (!_sourceLable) {
        _sourceLable = [self rp_addsubview:[UILabel class]];
        _sourceLable.font = [UIFont systemFontOfSize:12.0f];
        _sourceLable.textColor = [RedpacketColorStore rp_textColorGray];
    }
    return _sourceLable;
}

@end
