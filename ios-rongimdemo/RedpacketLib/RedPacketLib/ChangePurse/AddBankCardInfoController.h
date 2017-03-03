//
//  AddBankCardInfoController.h
//  RedpacketLib
//
//  Created by Mr.Yan on 16/4/30.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHRefreshTableViewController.h"

@interface AddBankCardInfoController : YZHRefreshTableViewController

@property (nonatomic, copy) NSString *bankNmame;

@property (nonatomic, copy) NSString *cardId;

@property (nonatomic, copy) NSString *cardNo;

@property (nonatomic, strong) NSArray *provArray;

@property (nonatomic ,copy) NSString *bankNo;

@end
