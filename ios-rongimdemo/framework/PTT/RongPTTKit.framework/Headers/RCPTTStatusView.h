//
//  RCPTTStatusView.h
//  RongPTTKit
//
//  Created by Sin on 16/12/27.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCPTTCommonDefine.h"
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RCPTTSessionStatus) {
    /*!
     不存在，未加入
     */
    RCPTTSessionStatusNotExistAndNotJoined,

    /*!
     不存在，已加入(错误情况)
     */
    RCPTTSessionStatusNotExistAndJoined,

    /*!
     存在，未加入加入
     */
    RCPTTSessionStatusExistAndNotJoined,

    /*!
     存在，已加入
     */
    RCPTTSessionStatusExistAndJoined,
};

@protocol RCPTTStatusViewDelegate <NSObject>
- (void)onJoinPTT;
- (void)onShowPTTView;
- (void)didHidden:(BOOL)isHidden;
- (RCPTTSessionStatus)getPttSessionStatus;
@end

@interface RCPTTStatusView : UIView
@property(nonatomic, weak) id<RCPTTStatusViewDelegate> delegate;
- (void)updateText:(NSString *)statusText;
- (void)updatePTTStatus;
@end
