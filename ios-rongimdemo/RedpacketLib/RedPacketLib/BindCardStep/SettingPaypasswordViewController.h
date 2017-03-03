//
//  SettingPaypasswordViewController.h
//  RedpacketLib
//
//  Created by Mr.Yan on 16/4/29.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHRefreshTableViewController.h"
#import "RPValidateNameModel.h"

@protocol SettingPayDelegate <NSObject>

- (void)rebackToChangeWith:(BindingCardType)bindingCardType;

@end

@interface SettingPaypasswordViewController : YZHRefreshTableViewController

@property (nonatomic) BOOL isWithDrawing;

@property (nonatomic) NSString *captcha;

@property (nonatomic,weak) id<SettingPayDelegate> delegate;

@property(nonatomic, assign) BindingCardType bindingCardType;

@end
