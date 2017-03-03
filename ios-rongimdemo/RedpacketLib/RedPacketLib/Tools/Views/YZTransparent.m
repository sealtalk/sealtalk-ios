//
//  YHTransparent.m
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/2/26.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "YZTransparent.h"

static UIView *keepTransparentView;

@implementation YZTransparent

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.alpha = .8;
    }
    
    return self;
}

+ (void)removeFromSuperView
{
    if (keepTransparentView) {
        [keepTransparentView removeFromSuperview];
        keepTransparentView = nil;
    }
}

+ (void)showInMainWindow:(TransparentViewTouch)touchBlock
{
    YZTransparent *transparentView = [[YZTransparent alloc] initWithFrame:[UIScreen mainScreen].bounds];
    keepTransparentView = transparentView;
    transparentView.transparentViewTouchBlock = touchBlock;
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:transparentView];
}

+ (void)showInView:(UIView *)view touchBlock:(TransparentViewTouch)transparentViewTouchBlock
{
    YZTransparent *transparentView = [[YZTransparent alloc] initWithFrame:[UIScreen mainScreen].bounds];
    keepTransparentView = transparentView;
    transparentView.transparentViewTouchBlock = transparentViewTouchBlock;
    
    [view addSubview:transparentView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_transparentViewTouchBlock) {
        _transparentViewTouchBlock(self);
    }
}

@end
