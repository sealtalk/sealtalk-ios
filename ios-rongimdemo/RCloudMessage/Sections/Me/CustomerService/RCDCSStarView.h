//
//  RCCSStarView.h
//  RongSelfBuiltCustomerDemo
//
//  Created by 张改红 on 2016/12/6.
//  Copyright © 2016年 rongcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RCDCSStarViewDelegate <NSObject>
- (void)didSelectStar:(int)star;
@end

@interface RCDCSStarView : UIView

@property (nonatomic, weak) id<RCDCSStarViewDelegate> starDelegate;

- (void)setSubviews;

@end
