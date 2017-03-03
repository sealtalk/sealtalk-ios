//
//  RPRedpacketPayManager.h
//  RedpacketLib
//
//  Created by Mr.Yang on 16/8/4.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RedpacketMessageModel.h"
#import "NewPayView.h"


typedef NS_ENUM(NSInteger, RedpacketPayUseType){
    //  发红包
    RedpacketPayUseTypeRedpacketSend,
    //  充值
    RedpacketPayUseTypeChange,
    //  转账
    RedpacketPayUseTypeTransfer
};

typedef void (^RedpacketPaySuccessBlock)(NSString *billRef, NSString *password);


@interface RPRedpacketPayManager : NSObject

@property (nonatomic, strong) NewPayView               *payTypeView;
@property (nonatomic, weak  ) NewPayView               *paySelectionView;


+ (RPRedpacketPayManager *)currentManager;

+ (void)releasePayManager;

- (void)payMoney:(NSString *)money inController:(UIViewController *__weak)controller
                           withRedpacketPayType:(RedpacketPayUseType)payType
                                    andPayBlock:(RedpacketPaySuccessBlock)payBlock;

- (void)reRequestUserWallet;

- (void)removeAllViews;

- (void)passwordInputError:(NSString *)error;

@end


