//
//  RPCompositeConstraint.m
//  Masonry
//
//  Created by Jonas Budelmann on 21/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "RPCompositeConstraint.h"
#import "RPConstraint+Private.h"

@interface RPCompositeConstraint () <RPConstraintDelegate>

@property (nonatomic, strong) id rpm_key;
@property (nonatomic, strong) NSMutableArray *childConstraints;

@end

@implementation RPCompositeConstraint

- (id)initWithChildren:(NSArray *)children {
    self = [super init];
    if (!self) return nil;

    _childConstraints = [children mutableCopy];
    for (RPConstraint *constraint in _childConstraints) {
        constraint.delegate = self;
    }

    return self;
}

#pragma mark - RPConstraintDelegate

- (void)constraint:(RPConstraint *)constraint shouldBeReplacedWithConstraint:(RPConstraint *)replacementConstraint {
    NSUInteger index = [self.childConstraints indexOfObject:constraint];
    NSAssert(index != NSNotFound, @"Could not find constraint %@", constraint);
    [self.childConstraints replaceObjectAtIndex:index withObject:replacementConstraint];
}

- (RPConstraint *)constraint:(RPConstraint __unused *)constraint addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    id<RPConstraintDelegate> strongDelegate = self.delegate;
    RPConstraint *newConstraint = [strongDelegate constraint:self addConstraintWithLayoutAttribute:layoutAttribute];
    newConstraint.delegate = self;
    [self.childConstraints addObject:newConstraint];
    return newConstraint;
}

#pragma mark - NSLayoutConstraint multiplier proxies 

- (RPConstraint * (^)(CGFloat))multipliedBy {
    return ^id(CGFloat multiplier) {
        for (RPConstraint *constraint in self.childConstraints) {
            constraint.multipliedBy(multiplier);
        }
        return self;
    };
}

- (RPConstraint * (^)(CGFloat))dividedBy {
    return ^id(CGFloat divider) {
        for (RPConstraint *constraint in self.childConstraints) {
            constraint.dividedBy(divider);
        }
        return self;
    };
}

#pragma mark - MASLayoutPriority proxy

- (RPConstraint * (^)(UILayoutPriority))priority {
    return ^id(UILayoutPriority priority) {
        for (RPConstraint *constraint in self.childConstraints) {
            constraint.priority(priority);
        }
        return self;
    };
}

#pragma mark - NSLayoutRelation proxy

- (RPConstraint * (^)(id, NSLayoutRelation))equalToWithRelation {
    return ^id(id attr, NSLayoutRelation relation) {
        for (RPConstraint *constraint in self.childConstraints.copy) {
            constraint.equalToWithRelation(attr, relation);
        }
        return self;
    };
}

#pragma mark - attribute chaining

- (RPConstraint *)addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    [self constraint:self addConstraintWithLayoutAttribute:layoutAttribute];
    return self;
}

#pragma mark - debug helpers

- (RPConstraint * (^)(id))key {
    return ^id(id key) {
        self.rpm_key = key;
        int i = 0;
        for (RPConstraint *constraint in self.childConstraints) {
            constraint.key([NSString stringWithFormat:@"%@[%d]", key, i++]);
        }
        return self;
    };
}

#pragma mark - NSLayoutConstraint constant setters

- (void)setInsets:(UIEdgeInsets)insets {
    for (RPConstraint *constraint in self.childConstraints) {
        constraint.insets = insets;
    }
}

- (void)setOffset:(CGFloat)offset {
    for (RPConstraint *constraint in self.childConstraints) {
        constraint.offset = offset;
    }
}

- (void)setSizeOffset:(CGSize)sizeOffset {
    for (RPConstraint *constraint in self.childConstraints) {
        constraint.sizeOffset = sizeOffset;
    }
}

- (void)setCenterOffset:(CGPoint)centerOffset {
    for (RPConstraint *constraint in self.childConstraints) {
        constraint.centerOffset = centerOffset;
    }
}

#pragma mark - RPConstraint

- (void)activate {
    for (RPConstraint *constraint in self.childConstraints) {
        [constraint activate];
    }
}

- (void)deactivate {
    for (RPConstraint *constraint in self.childConstraints) {
        [constraint deactivate];
    }
}

- (void)install {
    for (RPConstraint *constraint in self.childConstraints) {
        constraint.updateExisting = self.updateExisting;
        [constraint install];
    }
}

- (void)uninstall {
    for (RPConstraint *constraint in self.childConstraints) {
        [constraint uninstall];
    }
}

@end
