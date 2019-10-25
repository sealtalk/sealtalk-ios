//
//  RCDChatViewController+RealTimeLocation.h
//  SealTalk
//
//  Created by Sin on 2019/5/31.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDChatViewController.h"
#import "RealTimeLocationStatusView.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCDChatViewController (RealTimeLocation) <RealTimeLocationStatusViewDelegate, RCRealTimeLocationObserver>
@property (nonatomic, weak) id<RCRealTimeLocationProxy> realTimeLocation;
@property (nonatomic, strong) RealTimeLocationStatusView *realTimeLocationStatusView;

- (void)registerRealTimeLocationCell;
- (void)getRealTimeLocationProxy;
- (void)showRealTimeLocationViewController;
@end

NS_ASSUME_NONNULL_END
