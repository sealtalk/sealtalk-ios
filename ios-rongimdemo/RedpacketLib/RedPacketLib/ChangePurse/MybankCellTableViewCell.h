//
//  MybankCellTableViewCell.h
//  RedpacketLib
//
//  Created by Mr.Yan on 16/6/3.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

typedef void(^DelBankCardBlock)();

#import <UIKit/UIKit.h>

@interface MybankCellTableViewCell : UITableViewCell

@property (nonatomic) UIImageView *backImageView;

@property (nonatomic) UILabel *bankNameLable;

@property (nonatomic) UILabel *bankTypeLable;

@property (nonatomic) UILabel *bankNoLable;

@property (nonatomic) UILabel *cardTypeLable;

@property (nonatomic) UIView  *footterView;

@property (nonatomic, copy) DelBankCardBlock selectionBlockDel;

- (void)addfooterViewWithOnceMoney:(NSString *)onceMoney withDayMoney:(NSString *)dayMoney;

- (void)delFooterView;

@end
