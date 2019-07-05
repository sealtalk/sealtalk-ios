//
//  RCDCountryListController.h
//  SealTalk
//
//  Created by 张改红 on 2019/2/18.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RCDCountry;
NS_ASSUME_NONNULL_BEGIN

@protocol RCDCountryListControllerDelegate <NSObject>

- (void)fetchCountryPhoneCode:(RCDCountry *)country;

@end

@interface RCDCountryListController : UITableViewController

@property (nonatomic, assign) BOOL showNavigationBarWhenBack;

@property(nonatomic, weak) id<RCDCountryListControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
