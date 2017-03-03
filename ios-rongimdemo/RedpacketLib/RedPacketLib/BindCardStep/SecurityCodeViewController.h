//
//  SecurityCodeViewController.h
//  RedpacketLib
//
//  Created by Mr.Yan on 16/4/29.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHRefreshTableViewController.h"
#import "ApplyPaymentModel.h"
#import "RPValidateNameModel.h"

@protocol SecurityCodeDelegate <NSObject>

- (void)rebackToChangeWith:(BindingCardType)bindingCardType;

@end

@interface SecurityCodeViewController : YZHRefreshTableViewController

@property (nonatomic) BOOL isWithDrawing;

@property (nonatomic, strong) ApplyPaymentModel *paymentModel;

@property (nonatomic,weak) id<SecurityCodeDelegate> delegate;

@property (nonatomic ) BOOL isVerify;

@property(nonatomic, assign) BindingCardType bindingCardType;

@end
