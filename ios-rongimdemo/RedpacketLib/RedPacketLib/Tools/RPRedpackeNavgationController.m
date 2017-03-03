//
//  YZHNavViewController.m
//  RedpacketLib
//
//  Created by Mr.Yan on 16/8/6.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPRedpacketTool.h"
#import "RPRedpackeNavgationController.h"

#define APPKeyWindow [UIApplication sharedApplication].keyWindow
#define APPScreenWidth [UIScreen mainScreen].bounds.size.width

@interface RPRedpackeNavgationController ()
{
    UIImageView *lastScreenShotView;
    UIView *blackMask;
}

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) NSMutableArray *screenShotsList;

@end

@implementation RPRedpackeNavgationController

- (void)dealloc
{
    [_backgroundView removeFromSuperview];
    _backgroundView = nil;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    
    if (self) {
        self.screenShotsList = [[NSMutableArray alloc]initWithCapacity:2];
        self.canDragBack = YES;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBar.translucent = NO;
    
    UIImageView *shadowImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"leftside_shadow_bg"]];
    shadowImageView.frame = CGRectMake(-10, 0, 10, CGRectGetHeight(self.view.frame));
    [self.view addSubview:shadowImageView];
    
    UIScreenEdgePanGestureRecognizer *recognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self
                                                                                                     action:@selector(paningGestureReceive:)];
    recognizer.edges = UIRectEdgeLeft;
    [recognizer delaysTouchesBegan];
    recognizer.delaysTouchesBegan = YES;
    
    [self.view addGestureRecognizer:recognizer];
    
    //  关闭系统侧滑手势
    self.interactivePopGestureRecognizer.enabled = NO;
    
    //  移除底下的黑线
    [self removeNavigationBarbottomLine:self.navigationBar];
}

//  MARK:remove bottom line
- (void)removeNavigationBarbottomLine:(UIView *)superView
{
    if ([superView isKindOfClass:NSClassFromString(@"_UINavigationBarBackground")])
    {
        //移除分割线
        for (UIView *view in superView.subviews)
        {
            if ([view isKindOfClass:[UIImageView class]])
            {
                [view removeFromSuperview];
                return;
            }
        }
    }
    
    for (UIView *view in superView.subviews)
    {
        [self removeNavigationBarbottomLine:view];
    }
    
}

#pragma mark -

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count > 0) {
        [self.screenShotsList addObject:[self capture]];
    }
    
    if (animated && _canDragBack) {
        
        [super pushViewController:viewController animated:NO];
        [self animatingInitWithPush:YES];
        [UIView animateWithDuration:.5 animations:^{
            [self movePushView];
        } completion:^(BOOL finished) {
            self.backgroundView.hidden = YES;
        }];
        
        return;
    }
    
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    if (animated && _canDragBack) {
        
        [self animatingInitWithPush:NO];
        [UIView animateWithDuration:.35 animations:^{
            [self moveViewWithX:APPScreenWidth];
        } completion:^(BOOL finished) {
            CGRect frame = self.view.frame;
            frame.origin.x = 0;
            self.view.frame = frame;
            
            self.backgroundView.hidden = YES;
            
            [self popViewControllerAnimated:NO];
            
        }];
        
        return nil;
    }
    
    [self.screenShotsList removeLastObject];
    
    return [super popViewControllerAnimated:animated];
}

- (void)moveViewWithX:(float)x
{
    x = x > APPScreenWidth ? APPScreenWidth :x;
    x = x < 0 ? 0 : x ;
    
    CGRect frame = self.view.frame;
    frame.origin.x = x;
    self.view.frame = frame;

    float alpha = 0.8 - (x / APPScreenWidth);
    alpha = alpha < 0 ? 0 : alpha;
    
    lastScreenShotView.transform = CGAffineTransformMakeTranslation(x * .5, 0);
    blackMask.alpha = alpha;
}

- (void)movePushView
{
    CGRect frame = self.view.frame;
    frame.origin.x = 0;
    self.view.frame = frame;
    
    blackMask.alpha = 1;
    lastScreenShotView.transform = CGAffineTransformMakeScale(.9, .9);
}

- (void)animatingInitWithPush:(BOOL)isPush
{
    if (!self.backgroundView.superview)
    {
        //CGRect frame = self.view.frame;
        
        self.backgroundView = [[UIView alloc]initWithFrame:self.view.bounds];
        
        blackMask = [[UIView alloc]initWithFrame:self.view.bounds];
        blackMask.backgroundColor = [UIColor blackColor];
        [self.backgroundView addSubview:blackMask];
        
        [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
    }
    
    self.backgroundView.hidden = NO;
    
    if (lastScreenShotView) [lastScreenShotView removeFromSuperview];
    
    UIImage *lastScreenShot = [self.screenShotsList lastObject];
    lastScreenShotView = [[UIImageView alloc]initWithImage:lastScreenShot];
    lastScreenShotView.frame = self.view.bounds;
    [self.backgroundView insertSubview:lastScreenShotView belowSubview:blackMask];
    
    CGRect frame = lastScreenShotView.frame;
    
    if (isPush) {
        frame.origin.x = 0;
        CGRect animateFrame = self.view.frame;
        animateFrame.origin.x = APPScreenWidth;
        self.view.frame = animateFrame;
        blackMask.alpha = .0f;
        
    }else {
        frame.origin.x = -APPScreenWidth / 2.0f;
    }
    
    lastScreenShotView.frame = frame;
}

#pragma mark -

- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer
{
    if (self.viewControllers.count <= 1 || !self.canDragBack) return;
    
    CGPoint touchPoint = [recoginzer locationInView:APPKeyWindow];
    
    if (recoginzer.state == UIGestureRecognizerStateBegan) {
        
        [self animatingInitWithPush:NO];
        
    }else if (recoginzer.state == UIGestureRecognizerStateEnded){
        
        if (touchPoint.x > 50)
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:APPScreenWidth];
            } completion:^(BOOL finished) {
                
                [self popViewControllerAnimated:NO];
                
                CGRect frame = self.view.frame;
                frame.origin.x = 0;
                self.view.frame = frame;
                
                self.backgroundView.hidden = YES;
                
            }];
            
        } else {
            
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:0];
            } completion:^(BOOL finished) {
                self.backgroundView.hidden = NO;
            }];
            
        }
        return;
    
    }else if (recoginzer.state == UIGestureRecognizerStateCancelled){
        
        [UIView animateWithDuration:0.3 animations:^{
            [self moveViewWithX:0];
        } completion:^(BOOL finished) {
            self.backgroundView.hidden = YES;
        }];
        
        return;
    }else if (recoginzer.state == UIGestureRecognizerStateChanged) {
        
        [self moveViewWithX:touchPoint.x];
    }
}

- (UIImage *)capture
{
    [[[[UIApplication sharedApplication] windows] objectAtIndex:0] makeKeyWindow];
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [APPKeyWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    RPDebug(@"current window %@ \n Push Capture Image %@ imageSize %@",APPKeyWindow,img,NSStringFromCGSize(img.size));
    return img;
}

@end
