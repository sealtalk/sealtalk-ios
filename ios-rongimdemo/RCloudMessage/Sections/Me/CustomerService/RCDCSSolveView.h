//
//  RCDCSSolveView.h
//  RCloudMessage
//
//  Created by 张改红 on 2017/9/6.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMKit/RongIMKit.h>
@interface RCDCSSolveView : UIView

@property (nonatomic, copy) void(^isSolveBlock)(RCCSResolveStatus solveStatus);

- (void)setSubview;
@end
