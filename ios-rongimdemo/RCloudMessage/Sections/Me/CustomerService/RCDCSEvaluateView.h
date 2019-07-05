//
//  RCDCSEvaluateView.h
//  RCloudMessage
//
//  Created by 张改红 on 2017/9/6.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMKit/RongIMKit.h>
@class RCDCSEvaluateModel;
@protocol RCDCSEvaluateViewDelegate <NSObject>

- (void)didSubmitEvaluate:(RCCSResolveStatus)solveStatus star:(int)star tagString:(NSString *)tagString suggest:(NSString *)suggest;

- (void)dismissEvaluateView;

@end


@interface RCDCSEvaluateView : UIView

@property (nonatomic, weak) id<RCDCSEvaluateViewDelegate> delegate;


- (instancetype)initWithEvaStarDic:(NSDictionary *)evaStarDic;
- (void)show;
- (void)hide;
@end
