//
//  RCDPokeAlertView.h
//  SealTalk
//
//  Created by 张改红 on 2019/8/1.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMKit/RongIMKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface RCDPokeAlertView : UIView
+ (void)showPokeAlertView:(RCConversationType)type
                 targetId:(NSString *)targetId
         inViewController:(UIViewController *)controller;
@end

NS_ASSUME_NONNULL_END
