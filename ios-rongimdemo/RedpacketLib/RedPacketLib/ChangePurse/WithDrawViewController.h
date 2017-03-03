//
//  WithDrawViewController.h
//  RedpacketLib
//
//  Created by Mr.Yan on 16/4/30.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHRefreshTableViewController.h"

@protocol WithDrawViewContrDelegate <NSObject>

- (void)withDrawSuccessfulWithMoney:(NSString *)money;

@end

@interface WithDrawViewController : YZHRefreshTableViewController

@property (nonatomic) NSDictionary *dict;

//提现金额
@property (nonatomic) NSString  *money;

@property (nonatomic,weak) id<WithDrawViewContrDelegate> delegate;

@end
