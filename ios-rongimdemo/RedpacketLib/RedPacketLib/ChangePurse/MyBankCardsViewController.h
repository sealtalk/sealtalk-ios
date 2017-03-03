//
//  MyBankCardsViewController.h
//  RedpacketLib
//
//  Created by Mr.Yan on 16/6/3.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "YZHRefreshTableViewController.h"

@protocol MyBankCardsDelegate <NSObject>

@optional
/**
 *  绑卡成功以后更新零钱
 */
- (void)binCardSucessRefreshChangeMoneyAndisBinCard:(BOOL)isBinCard;
@end

@interface MyBankCardsViewController : YZHRefreshTableViewController

@property (nonatomic,weak) id<MyBankCardsDelegate> delegate;

@end
