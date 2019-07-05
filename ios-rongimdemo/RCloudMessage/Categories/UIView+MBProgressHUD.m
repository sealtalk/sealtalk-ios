//
//  UIView+MBProgressHUD.m
//  SealClass
//
//  Created by liyan on 2019/3/12.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "UIView+MBProgressHUD.h"

#define MBPHUD_EXECUTE(...) \
__weak typeof(self) weakself = self; \
[self hideHUDCompletion:^{ \
[weakself.HUD removeFromSuperview]; \
__VA_ARGS__ \
}];

CGFloat const MBPHUDFontSize = 12;
CGFloat const MBPHUDShowTime = 2.0f;

@implementation UIView (MBProgressHUD)

@dynamic HUD;

- (MBProgressHUD *)HUD {
    return [MBProgressHUD HUDForView:self];
}

- (MBProgressHUD *)instanceHUD {
    MBProgressHUD *HUD = [[MBProgressHUD alloc]initWithView:self];
    return HUD;
}

- (void)showHUDMessage:(NSString *)message {
    MBPHUD_EXECUTE({
        MBProgressHUD *HUD = [weakself instanceHUD];
        [[UIApplication sharedApplication].keyWindow addSubview:HUD];
        [[UIApplication sharedApplication].keyWindow  bringSubviewToFront:HUD];
        HUD.mode = MBProgressHUDModeText;
        HUD.label.text = message;
        HUD.removeFromSuperViewOnHide = YES;
        [HUD showAnimated:YES];
        [HUD hideAnimated:YES afterDelay:MBPHUDShowTime];
    })
}

- (void)hideHUDCompletion:(nullable void(^)(void))completion {
    if (!self.HUD) { if (completion) completion(); return; }
    self.HUD.completionBlock = completion;
    [self.HUD hideAnimated:YES];
}
@end
