//
//  RCDQuicklySendManager.h
//  SealTalk
//
//  Created by 孙浩 on 2019/8/1.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RCDQuicklySendView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RCDQuicklySendManagerDelegate <NSObject>

- (void)quicklySendViewDidTapImage:(UIImage *)image;

@end

@interface RCDQuicklySendManager : NSObject

@property (nonatomic, weak) id<RCDQuicklySendManagerDelegate> delegate;

+ (RCDQuicklySendManager *)sharedManager;

- (void)showQuicklySendViewWithframe:(CGRect)frame;

- (void)hideQuicklySendView;

@end

NS_ASSUME_NONNULL_END
