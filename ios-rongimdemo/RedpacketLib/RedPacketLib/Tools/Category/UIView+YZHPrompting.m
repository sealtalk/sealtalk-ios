//
//  UIView+Prompting.m
//  zhibo
//
//  Created by Mr.Yang on 14-3-19.
//  Copyright (c) 2014年 Mr.Yang. All rights reserved.
//

#import "UIView+YZHPrompting.h"
#import "RedpacketColorStore.h"
#import "RPRedpacketTool.h"


@implementation UIView (YZHPrompting)

- (UIView *)showView
{
    UIView *view = self;
    if (YES) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        view = window;
    }
    
    return [self promptingTopView];
}

//  获取顶部的视图
- (UIView *)promptingTopView
{
    NSArray *windwos = [[UIApplication sharedApplication] windows];
    
    UIView *topView = self;
    
    if (windwos.count) {
        UIWindow *keyboarWindow = [windwos lastObject];
        if ([keyboarWindow isKindOfClass:NSClassFromString(@"UIRemoteKeyboardWindow")]) {
            topView = keyboarWindow;
        }
    }
    
    return topView;
}

//等待提示框
- (YZHMBProgressHUD *)rp_showHudWaitingView:(NSString *)prompt
{
    /*
     UIWindow *window = [UIApplication sharedApplication].keyWindow;
     */
    YZHMBProgressHUD *hud = [YZHMBProgressHUD showHUDAddedTo:[self showView] animated:YES];
    hud.labelText = prompt;
    hud.color = [RedpacketColorStore flashColorWithRed:97 green:97 blue:97 alpha:1];
    
    hud.minSize = CGSizeMake(132.f, 108.0f);
    return hud;
}

//提示警告信息
- (YZHMBProgressHUD *)rp_showHudAuto:(NSString *)text
{
    return [self showMBHudView:text customerView:nil removeAuto:YES];
}

//成功的警告框
- (YZHMBProgressHUD *)rp_showHudSuccessView:(NSString *)text
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:rpRedpacketBundleImage(@"redpacket_prompt_hudSuccess")];
    imageView.frame = CGRectMake(0, 0, 32, 32);
    
    return [self showMBHudView:text customerView:imageView removeAuto:YES];
}

//错误的警告框
- (YZHMBProgressHUD *)rp_showHudErrorView:(NSString *)text
{
    RPDebug(@"%@", rpRedpacketBundlePath);
    UIImage *image = rpRedpacketBundleImage(@"redpacket_prompt_hudError");
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, 32, 32);
    
    return [self showMBHudView:text customerView:imageView removeAuto:YES];
}

- (YZHMBProgressHUD *)rp_showHudManaual:(NSString *)text
{
    return [self showMBHudView:text customerView:nil removeAuto:NO];
}

//  手动关闭的提示框
- (void)rp_removeHudInManaual
{
    /*
     UIWindow *window = [UIApplication sharedApplication].keyWindow;
     */
    [YZHMBProgressHUD hideAllHUDsForView:[self showView] animated:YES];
    
    [YZHMBProgressHUD hideAllHUDsForView:self animated:YES];
    
}

- (YZHMBProgressHUD *)showMBHudView:(NSString *)text customerView:(UIView *)customerView removeAuto:(BOOL)autoremove
{
    [YZHMBProgressHUD hideAllHUDsForView:[self showView] animated:YES];
    
    YZHMBProgressHUD *hud=[YZHMBProgressHUD showHUDAddedTo:[self showView] animated:NO];
    hud.color = [RedpacketColorStore flashColorWithRed:97 green:97 blue:97 alpha:1];
    hud.removeFromSuperViewOnHide = YES;
    hud.customView = customerView;
    hud.mode = customerView ? MBProgressHUDModeCustomView : MBProgressHUDModeText;
    hud.detailsLabelText = text;
    hud.detailsLabelFont = [UIFont systemFontOfSize:16.0f];
    hud.minSize = CGSizeMake(132.f, 108.0f);
    
    if (autoremove) {
        [hud hide:YES afterDelay:1.2];
    }
    
    return hud;
}

@end
