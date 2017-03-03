//
//  UIView+Animation.m
//  HTAlertView
//
//  Created by Mr.Yang on 13-12-6.
//  Copyright (c) 2013年 MoonLightCompany. All rights reserved.
//

#import "UIView+YZHAnimation.h"
#import <QuartzCore/QuartzCore.h>


static NSString *animationType  = @"animationType";
static NSString *radarAnimation = @"radarAnimation";

@implementation UIView (YZHAnimation)

- (void)updateAnchorPoint:(PopAnchor)position to:(UIView *)view
{
    CGRect frame = view.frame;
    CGPoint anchorPoint = CGPointZero;
    CGPoint location = CGPointZero;
    
    if (position & PopAnchorTop) {
        anchorPoint.y  = 0;
        location.y = CGRectGetMinY(frame) - CGRectGetHeight(frame) / 2.0f;
    }
    if (position & PopAnchorBottom){
        anchorPoint.y = 1;
        location.y =  CGRectGetMaxY(frame) - CGRectGetHeight(frame) / 2.0f;
    }
    if (position & PopAnchorLeft){
        anchorPoint.x = 0;
        location.x = CGRectGetMinX(frame) - CGRectGetWidth(frame) / 2.0f;
    }
    if (position & PopAnchorRight){
        anchorPoint.x = 1;
        location.x = CGRectGetMinX(frame) - CGRectGetWidth(frame) / 2.0f;
    }
    if (position & PopAnchorCenterX){
        anchorPoint.x = .5;
        location.x = CGRectGetMinX(frame);
    }
    if (position & PopAnchorCenterY){
        anchorPoint.y = .5;
        location.y = CGRectGetMinY(frame);
    }
    
    frame.origin = location;
    view.frame = frame;
    view.layer.anchorPoint = anchorPoint;
}

- (void)rp_popupSubView:(UIView *)view atPosition:(PopAnchor)position
{
    [self updateAnchorPoint:position to:view];
    
    if (view.superview != self) {
        [self addSubview:view];
    }
    
    CATransform3D scale1 = CATransform3DMakeScale(.5, .5, 1);
    CATransform3D scale2 = CATransform3DMakeScale(1.05, 1.05, 1);
    CATransform3D scale3 = CATransform3DMakeScale(.95, .95, 1);
    CATransform3D scale4 = CATransform3DMakeScale(1, 1, 1);
    NSArray *keyValues = [NSArray arrayWithObjects:
                          [NSValue valueWithCATransform3D:scale1],
                          [NSValue valueWithCATransform3D:scale2],
                          [NSValue valueWithCATransform3D:scale3],
                          [NSValue valueWithCATransform3D:scale4],
                          nil];
    
    NSArray *keyTimes = [NSArray arrayWithObjects:
                         [NSNumber numberWithFloat:.0],
                         [NSNumber numberWithFloat:.4],
                         [NSNumber numberWithFloat:.7],
                         [NSNumber numberWithFloat:1],
                         nil];
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    [animation setValues:keyValues];
    [animation setKeyTimes:keyTimes];
    
    animation.removedOnCompletion = YES;
    animation.duration = .35;
    
    [view.layer addAnimation:animation forKey:@"viewPop"];
}


- (void)rp_shrinkDispaerWithDelegate:(id)delegate
{
    NSValue *value = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1)];
    NSValue *toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(.0, .0, 1)];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.fromValue = value;
    animation.toValue = toValue;
    animation.duration = .35;
    animation.delegate = delegate;
    
    [self.layer addAnimation:animation forKey:@"shrink"];
}

- (void)rp_popOutWithDelegate:(id)delegate
{
    CATransform3D scale1 = CATransform3DMakeScale(.0, .0, 1);
    CATransform3D scale2 = CATransform3DMakeScale(1.15, 1.15, 1);
    CATransform3D scale3 = CATransform3DMakeScale(.85, .85, 1);
    CATransform3D scale4 = CATransform3DMakeScale(1, 1, 1);
    NSArray *keyValues = [NSArray arrayWithObjects:
                          [NSValue valueWithCATransform3D:scale1],
                          [NSValue valueWithCATransform3D:scale2],
                          [NSValue valueWithCATransform3D:scale3],
                          [NSValue valueWithCATransform3D:scale4],
                          nil];
    
    NSArray *keyTimes = [NSArray arrayWithObjects:
                         [NSNumber numberWithFloat:.0],
                         [NSNumber numberWithFloat:.4],
                         [NSNumber numberWithFloat:.7],
                         [NSNumber numberWithFloat:1],
                         nil];
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    [animation setValues:keyValues];
    [animation setKeyTimes:keyTimes];
    
    animation.delegate = delegate;
    animation.removedOnCompletion = YES;
    animation.duration = .65;
    
    [self.layer addAnimation:animation forKey:@"viewPop"];
}

- (void)rp_shrinkDispaerWithCompletionBlock:(void (^) (void))animationStop1
{
    NSValue *value = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.01, 1.01, 1.01)];
    NSValue *toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(.1, .1, 1)];
    
    [UIView animateWithDuration:.1 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        self.layer.transform = [value CATransform3DValue];
        
    } completion:^(BOOL finished) {
       [UIView animateWithDuration:.3 animations:^{
           [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
           self.layer.transform = [toValue CATransform3DValue];
       } completion:^(BOOL finished) {
           animationStop1();
       }];
        
    }];
}

- (void)rp_glintAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = @(1.0f);
    animation.toValue = @(.3f);
    animation.repeatCount = 4;
    animation.autoreverses = YES;
    animation.duration = .35;
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    [self.layer addAnimation:animation forKey:@"glintAnimation"];
}

- (void)rp_shakeAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = @(M_PI / 6);
    animation.toValue = @(-M_PI / 6);
    animation.repeatCount = 4;
    animation.autoreverses = YES;
    animation.duration = .25 / 4;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [self.layer addAnimation:animation forKey:@"shakeAnimation"];
}

- (void)rp_shockAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    animation.fromValue = @(CGRectGetMinX(self.frame) - 20);
    animation.toValue = @(CGRectGetMinX(self.frame) + 20);
    animation.duration = .25 / 4;
    animation.repeatCount = 4;
    animation.autoreverses = YES;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [self.layer addAnimation:animation forKey:@"shockAnimation"];
}

- (void)rp_scaleAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue = @1.0f;
    animation.toValue = @1.3f;
    animation.duration  = .25;
    animation.autoreverses = YES;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [self.layer addAnimation:animation forKey:@"scaleAnimation"];
}

- (void)rp_radar:(NSInteger)count
{
    UIView *superView = self.superview;
    
    double animationDuation = 4.0f;
    for (int i = 0; i < count; i++) {
        
        CGFloat minLength = CGRectGetHeight(superView.bounds) > CGRectGetWidth(superView.bounds) ? CGRectGetWidth(superView.bounds) : CGRectGetHeight(superView.bounds);
        
        CALayer *layer = [[CALayer alloc] init];
        layer.bounds = CGRectMake(0, 0, minLength, minLength);
        layer.borderWidth = 1.0f;
        layer.borderColor = [UIColor blueColor].CGColor;
        layer.cornerRadius = CGRectGetHeight(layer.bounds) / 2.0f;
        layer.position = self.center;
        layer.affineTransform = CGAffineTransformMakeScale(0, 0);
        
        CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scale.fromValue = @(0.0f);
        scale.toValue = @(1.5f);
        
        CAKeyframeAnimation *fade = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        fade.values = @[@(1), @(.7), @(0)];
        fade.keyTimes = @[@0, @.6, @1];
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.duration = animationDuation;
        group.beginTime = CACurrentMediaTime() + animationDuation / count * i;
        group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        group.animations = @[scale, fade];
        
        [layer addAnimation:group forKey:radarAnimation];
        
        [superView.layer insertSublayer:layer below:self.layer];
    }
    
}

@end
