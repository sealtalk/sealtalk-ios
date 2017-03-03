//
//  RPMyIncomeHeaderVIew.h
//  RedpacketLib
//
//  Created by Mr.Yan on 2016/10/31.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RPMyIncomeHeaderView : UITableViewCell

@property (nonatomic, assign) BOOL isSend;

@property (nonatomic) NSDictionary *incomeHeaderDic;
@property (nonatomic ,weak) UILabel *moneyLable;
@property (nonatomic ,weak) UILabel *receiveNumbersLable;
@property (nonatomic ,weak) UILabel *bestLuckyNumbersLable;
@property (nonatomic ,weak) UIImageView *headImageView;
@property (nonatomic ,weak) UILabel *themeDescribeLable;
//receive
@property (nonatomic ,weak) UILabel *receiveDescribeLable;
@property (nonatomic ,weak) UILabel *bestLuckyDescibeLable;
//send
@property (nonatomic ,weak) UILabel *sendNumbersLable;

@end
