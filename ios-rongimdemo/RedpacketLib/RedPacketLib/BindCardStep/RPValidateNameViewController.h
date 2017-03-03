//
//  RPValidateNameViewController.h
//  RedpacketLib
//
//  Created by Mr.Yan on 2016/10/18.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "YZHRefreshTableViewController.h"
#import "RPValidateNameModel.h"
#import "ApplyPaymentModel.h"

@protocol RPValidatedeDelegate <NSObject>

@optional
/**
 *  设置支付密码成功 返回调用
 */
- (void)rebackToChangeWith:(BindingCardType)bindingCardType;

/**
 *  塞钱包页面 充值确认
 *  param:model 支付验证的数据结构
 */
- (void)rebackwithApplyPaymentModel:(ApplyPaymentModel *)model;

@end

@interface RPValidateNameViewController : YZHRefreshTableViewController

/**
 *  已经绑过的卡
 */
@property (nonatomic, strong) NSArray *cardArray;

/**
 *  绑卡页面代理
 */
@property (nonatomic,weak) id<RPValidatedeDelegate> delegate;

/**
 *  充值金额，充值时需要的参数
 */
@property (nonatomic,copy) NSString *moneyAccount;

/**
 *  根据Type显示修改文案
 */
@property(nonatomic, assign) BindingCardType bindingCardType;


@end
