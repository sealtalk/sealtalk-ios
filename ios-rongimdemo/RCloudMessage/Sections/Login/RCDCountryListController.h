//
//  RCDCountryListController.h
//  SealTalk
//
//  Created by 张改红 on 2019/2/18.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "RCDTableViewController.h"
@class RCDCountry;
NS_ASSUME_NONNULL_BEGIN

@protocol RCDCountryListControllerDelegate <NSObject>

- (void)fetchCountryPhoneCode:(RCDCountry *)country;

@end

@interface RCDCountryListController : RCDTableViewController

@property (nonatomic, assign) BOOL showNavigationBarWhenBack;

@property (nonatomic, weak) id<RCDCountryListControllerDelegate> delegate;

@property (nonatomic, copy) void (^SelectCountryResult)(RCDCountry *country);
@end

NS_ASSUME_NONNULL_END
