//
//  RCContentView.h
//  RongIMKit
//
//  Created by xugang on 3/31/15.
//  Copyright (c) 2015 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 消息内容的View
 */
@interface RCContentView : UIView

/*!
 Frame发生变化的回调
 */
@property(nonatomic, copy) void (^eventBlock)(CGRect frame);

/*!
 注册Frame发生变化的回调

 @param eventBlock Frame发生变化的回调
 */
- (void)registerFrameChangedEvent:(void (^)(CGRect frame))eventBlock;

@end
