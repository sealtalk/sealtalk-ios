//
//  NSArray+MASAdditions.m
//  
//
//  Created by Daniel Hammond on 11/26/13.
//
//

#import "NSArray+RPAdditions.h"
#import "View+RPAdditions.h"

@implementation NSArray (RPAdditions)

- (NSArray *)rpm_makeConstraints:(void(^)(RPConstraintMaker *make))block {
    NSMutableArray *constraints = [NSMutableArray array];
    for (UIView *view in self) {
        NSAssert([view isKindOfClass:[UIView class]], @"All objects in the array must be views");
        [constraints addObjectsFromArray:[view rpm_makeConstraints:block]];
    }
    return constraints;
}

- (NSArray *)rpm_updateConstraints:(void(^)(RPConstraintMaker *make))block {
    NSMutableArray *constraints = [NSMutableArray array];
    for (UIView *view in self) {
        NSAssert([view isKindOfClass:[UIView class]], @"All objects in the array must be views");
        [constraints addObjectsFromArray:[view rpm_updateConstraints:block]];
    }
    return constraints;
}

- (NSArray *)rpm_remakeConstraints:(void(^)(RPConstraintMaker *make))block {
    NSMutableArray *constraints = [NSMutableArray array];
    for (UIView *view in self) {
        NSAssert([view isKindOfClass:[UIView class]], @"All objects in the array must be views");
        [constraints addObjectsFromArray:[view rpm_remakeConstraints:block]];
    }
    return constraints;
}

- (UIView *)rpm_commonSuperviewOfViews
{
    UIView *commonSuperview = nil;
    UIView *previousView = nil;
    for (id object in self) {
        if ([object isKindOfClass:[UIView class]]) {
            UIView *view = (UIView *)object;
            if (previousView) {
                commonSuperview = [view rpm_closestCommonSuperview:commonSuperview];
            } else {
                commonSuperview = view;
            }
            previousView = view;
        }
    }
    NSAssert(commonSuperview, @"Can't constrain views that do not share a common superview. Make sure that all the views in this array have been added into the same view hierarchy.");
    return commonSuperview;
}

@end
