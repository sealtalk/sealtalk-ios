//
//  RCDForwardSearchViewController.h
//  SealTalk
//
//  Created by 孙浩 on 2019/6/21.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class RCDForwardSearchResultModel;

@protocol RCDForwardSearchViewDelegate <NSObject>
- (void)forwardSearchViewControllerDidClickCancel;
@end

@interface RCDForwardSearchViewController : RCDViewController

@property (nonatomic, weak) id<RCDForwardSearchViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
