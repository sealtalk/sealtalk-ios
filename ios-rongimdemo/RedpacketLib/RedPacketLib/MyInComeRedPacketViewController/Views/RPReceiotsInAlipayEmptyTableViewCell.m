//
//  RPReceiotsInAlipayEmptyTableViewCell.m
//  RedpacketLib
//
//  Created by 都基鹏 on 2017/1/13.
//  Copyright © 2017年 Mr.Yang. All rights reserved.
//

#import "RPReceiotsInAlipayEmptyTableViewCell.h"
#import "UIView+YZHExtension.h"
#import "RPLayout.h"
#import "RedpacketColorStore.h"

@interface RPReceiotsInAlipayEmptyTableViewCell()

@property (nonatomic,weak)UILabel * describeLable;

@end

@implementation RPReceiotsInAlipayEmptyTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.describeLable = [self rp_addsubview:[UILabel class]];
        self.describeLable.textColor = [RedpacketColorStore rp_textColorGray];
        self.describeLable.font = [UIFont systemFontOfSize:13];
        self.describeLable.textAlignment = NSTextAlignmentCenter;
        self.describeLable.text = @"你没有收到过红包";
        [self.describeLable rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.top.equalTo(self).offset(37);
            make.centerX.equalTo(self);
        }];
    }
    return self;
}

@end
