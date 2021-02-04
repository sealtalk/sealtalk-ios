//
//  RCDReceiptDetailHeader.h
//  SealTalk
//
//  Created by 张改红 on 2019/5/31.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RCMessageModel;
NS_ASSUME_NONNULL_BEGIN
@protocol RCDReceiptDetailHeaderDelegate <NSObject>

- (void)receiptDetailHeaderDidUpdate:(BOOL)isClosed;

@end
@interface RCDReceiptDetailHeader : UIView
@property (nonatomic, weak) id<RCDReceiptDetailHeaderDelegate> delegate;
- (instancetype)initWithMessage:(RCMessageModel *)message;
@end

NS_ASSUME_NONNULL_END
