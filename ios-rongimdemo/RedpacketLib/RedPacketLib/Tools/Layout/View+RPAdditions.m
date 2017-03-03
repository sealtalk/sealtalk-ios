//
//  UIView+MASAdditions.m
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "View+RPAdditions.h"
#import <objc/runtime.h>

@implementation UIView (RPAdditions)

- (NSArray *)rpm_makeConstraints:(void(^)(RPConstraintMaker *))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    RPConstraintMaker *constraintMaker = [[RPConstraintMaker alloc] initWithView:self];
    block(constraintMaker);
    return [constraintMaker install];
}

- (NSArray *)rpm_updateConstraints:(void(^)(RPConstraintMaker *))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    RPConstraintMaker *constraintMaker = [[RPConstraintMaker alloc] initWithView:self];
    constraintMaker.updateExisting = YES;
    block(constraintMaker);
    return [constraintMaker install];
}

- (NSArray *)rpm_remakeConstraints:(void(^)(RPConstraintMaker *make))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    RPConstraintMaker *constraintMaker = [[RPConstraintMaker alloc] initWithView:self];
    constraintMaker.removeExisting = YES;
    block(constraintMaker);
    return [constraintMaker install];
}

#pragma mark - NSLayoutAttribute properties

- (RPViewAttribute *)rpm_left {
    return [[RPViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeft];
}

- (RPViewAttribute *)rpm_top {
    return [[RPViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTop];
}

- (RPViewAttribute *)rpm_right {
    return [[RPViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeRight];
}

- (RPViewAttribute *)rpm_bottom {
    return [[RPViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBottom];
}

- (RPViewAttribute *)rpm_leading {
    return [[RPViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeading];
}

- (RPViewAttribute *)rpm_trailing {
    return [[RPViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTrailing];
}

- (RPViewAttribute *)rpm_width {
    return [[RPViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeWidth];
}

- (RPViewAttribute *)rpm_height {
    return [[RPViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeHeight];
}

- (RPViewAttribute *)rpm_centerX {
    return [[RPViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterX];
}

- (RPViewAttribute *)rpm_centerY {
    return [[RPViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterY];
}

- (RPViewAttribute *)rpm_baseline {
    return [[RPViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBaseline];
}

- (RPViewAttribute *(^)(NSLayoutAttribute))rpm_attribute
{
    return ^(NSLayoutAttribute attr) {
        return [[RPViewAttribute alloc] initWithView:self layoutAttribute:attr];
    };
}


#if TARGET_OS_IPHONE || TARGET_OS_TV

- (RPViewAttribute *)rpm_leftMargin {
    return [[RPViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeftMargin];
}

- (RPViewAttribute *)rpm_rightMargin {
    return [[RPViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeRightMargin];
}

- (RPViewAttribute *)rpm_topMargin {
    return [[RPViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTopMargin];
}

- (RPViewAttribute *)rpm_bottomMargin {
    return [[RPViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBottomMargin];
}

- (RPViewAttribute *)rpm_leadingMargin {
    return [[RPViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeadingMargin];
}

- (RPViewAttribute *)rpm_trailingMargin {
    return [[RPViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTrailingMargin];
}

- (RPViewAttribute *)rpm_centerXWithinMargins {
    return [[RPViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterXWithinMargins];
}

- (RPViewAttribute *)rpm_centerYWithinMargins {
    return [[RPViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterYWithinMargins];
}

#endif

#pragma mark - associated properties

- (id)rpm_key {
    return objc_getAssociatedObject(self, @selector(rpm_key));
}

- (void)setRpm_key:(id)rpm_key {
    objc_setAssociatedObject(self, @selector(rpm_key), rpm_key, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - heirachy

- (instancetype)rpm_closestCommonSuperview:(UIView *)view {
    UIView *closestCommonSuperview = nil;

    UIView *secondViewSuperview = view;
    while (!closestCommonSuperview && secondViewSuperview) {
        UIView *firstViewSuperview = self;
        while (!closestCommonSuperview && firstViewSuperview) {
            if (secondViewSuperview == firstViewSuperview) {
                closestCommonSuperview = secondViewSuperview;
            }
            firstViewSuperview = firstViewSuperview.superview;
        }
        secondViewSuperview = secondViewSuperview.superview;
    }
    return closestCommonSuperview;
}

@end
