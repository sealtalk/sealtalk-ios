//
//  UIButton+RPAction.m
//  RedpacketLib
//
//  Created by 都基鹏 on 2016/11/29.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "UIButton+RPAction.h"
#import <objc/runtime.h>

static char rp_actionKey;

BOOL ClassMethodSwizzle(Class aClass, SEL originalSelector, SEL swizzleSelector) {
    
    Method originalMethod = class_getInstanceMethod(aClass, originalSelector);
    Method swizzleMethod = class_getInstanceMethod(aClass, swizzleSelector);
    
    BOOL didAddMethod =
    class_addMethod(aClass,
                    originalSelector,
                    method_getImplementation(swizzleMethod),
                    method_getTypeEncoding(swizzleMethod));
    if (didAddMethod) {
        class_replaceMethod(aClass,
                            swizzleSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzleMethod);
    }
    return YES;
}

@implementation UIButton (RPAction)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ClassMethodSwizzle([self class], @selector(pointInside:withEvent:), @selector(rp_pointInside:withEvent:));
    });
}

- (UIEdgeInsets)rp_hitTestEdgeInsets {
    NSValue * value = objc_getAssociatedObject(self, &rp_actionKey);
    if (value) {
        UIEdgeInsets edgeInsets; [value getValue:&edgeInsets]; return edgeInsets;
    }
    return UIEdgeInsetsZero;
}

- (void)setRp_hitTestEdgeInsets:(UIEdgeInsets)rp_hitTestEdgeInsets {
    
    NSValue *value = [NSValue value:&rp_hitTestEdgeInsets withObjCType:@encode(UIEdgeInsets)];
    objc_setAssociatedObject(self, &rp_actionKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (BOOL)rp_pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if(UIEdgeInsetsEqualToEdgeInsets(self.rp_hitTestEdgeInsets, UIEdgeInsetsZero) ||!self.enabled || self.hidden) {
        return [self rp_pointInside:point withEvent:event];
    }
    
    CGRect relativeFrame = self.bounds;
    CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, self.rp_hitTestEdgeInsets);

    return CGRectContainsPoint(hitFrame, point);
}

@end
