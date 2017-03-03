//
//  RPConstraint.m
//  Masonry
//
//  Created by Nick Tymchenko on 1/20/14.
//

#import "RPConstraint.h"
#import "RPConstraint+Private.h"

#define RPMethodNotImplemented() \
    @throw [NSException exceptionWithName:NSInternalInconsistencyException \
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)] \
                                 userInfo:nil]

@implementation RPConstraint

#pragma mark - Init

- (id)init {
	NSAssert(![self isMemberOfClass:[RPConstraint class]], @"RPConstraint is an abstract class, you should not instantiate it directly.");
	return [super init];
}

#pragma mark - NSLayoutRelation proxies

- (RPConstraint * (^)(id))equalTo {
    return ^id(id attribute) {
        return self.equalToWithRelation(attribute, NSLayoutRelationEqual);
    };
}

- (RPConstraint * (^)(id))greaterThanOrEqualTo {
    return ^id(id attribute) {
        return self.equalToWithRelation(attribute, NSLayoutRelationGreaterThanOrEqual);
    };
}

- (RPConstraint * (^)(id))lessThanOrEqualTo {
    return ^id(id attribute) {
        return self.equalToWithRelation(attribute, NSLayoutRelationLessThanOrEqual);
    };
}

#pragma mark - MASLayoutPriority proxies

- (RPConstraint * (^)())priorityLow {
    return ^id{
        self.priority(UILayoutPriorityDefaultLow);
        return self;
    };
}

- (RPConstraint * (^)())priorityMedium {
    return ^id{
        self.priority(UILayoutPriorityDefaultMedium);
        return self;
    };
}

- (RPConstraint * (^)())priorityHigh {
    return ^id{
        self.priority(UILayoutPriorityDefaultHigh);
        return self;
    };
}

#pragma mark - NSLayoutConstraint constant proxies

- (RPConstraint * (^)(UIEdgeInsets))insets {
    return ^id(UIEdgeInsets insets){
        self.insets = insets;
        return self;
    };
}

- (RPConstraint * (^)(CGSize))sizeOffset {
    return ^id(CGSize offset) {
        self.sizeOffset = offset;
        return self;
    };
}

- (RPConstraint * (^)(CGPoint))centerOffset {
    return ^id(CGPoint offset) {
        self.centerOffset = offset;
        return self;
    };
}

- (RPConstraint * (^)(CGFloat))offset {
    return ^id(CGFloat offset){
        self.offset = offset;
        return self;
    };
}

- (RPConstraint * (^)(NSValue *value))valueOffset {
    return ^id(NSValue *offset) {
        NSAssert([offset isKindOfClass:NSValue.class], @"expected an NSValue offset, got: %@", offset);
        [self setLayoutConstantWithValue:offset];
        return self;
    };
}

#pragma mark - NSLayoutConstraint constant setter

- (void)setLayoutConstantWithValue:(NSValue *)value {
    if ([value isKindOfClass:NSNumber.class]) {
        self.offset = [(NSNumber *)value doubleValue];
    } else if (strcmp(value.objCType, @encode(CGPoint)) == 0) {
        CGPoint point;
        [value getValue:&point];
        self.centerOffset = point;
    } else if (strcmp(value.objCType, @encode(CGSize)) == 0) {
        CGSize size;
        [value getValue:&size];
        self.sizeOffset = size;
    } else if (strcmp(value.objCType, @encode(UIEdgeInsets)) == 0) {
        UIEdgeInsets insets;
        [value getValue:&insets];
        self.insets = insets;
    } else {
        NSAssert(NO, @"attempting to set layout constant with unsupported value: %@", value);
    }
}

#pragma mark - Semantic properties

- (RPConstraint *)with {
    return self;
}

- (RPConstraint *)and {
    return self;
}

#pragma mark - Chaining

- (RPConstraint *)addConstraintWithLayoutAttribute:(NSLayoutAttribute __unused)layoutAttribute {
    RPMethodNotImplemented();
}

- (RPConstraint *)left {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeft];
}

- (RPConstraint *)top {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTop];
}

- (RPConstraint *)right {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeRight];
}

- (RPConstraint *)bottom {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBottom];
}

- (RPConstraint *)leading {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeading];
}

- (RPConstraint *)trailing {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTrailing];
}

- (RPConstraint *)width {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeWidth];
}

- (RPConstraint *)height {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeHeight];
}

- (RPConstraint *)centerX {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterX];
}

- (RPConstraint *)centerY {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterY];
}

- (RPConstraint *)baseline {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBaseline];
}

#if TARGET_OS_IPHONE || TARGET_OS_TV

- (RPConstraint *)leftMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeftMargin];
}

- (RPConstraint *)rightMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeRightMargin];
}

- (RPConstraint *)topMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTopMargin];
}

- (RPConstraint *)bottomMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBottomMargin];
}

- (RPConstraint *)leadingMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeadingMargin];
}

- (RPConstraint *)trailingMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTrailingMargin];
}

- (RPConstraint *)centerXWithinMargins {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterXWithinMargins];
}

- (RPConstraint *)centerYWithinMargins {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterYWithinMargins];
}

#endif

#pragma mark - Abstract

- (RPConstraint * (^)(CGFloat multiplier))multipliedBy { RPMethodNotImplemented(); }

- (RPConstraint * (^)(CGFloat divider))dividedBy { RPMethodNotImplemented(); }

- (RPConstraint * (^)(UILayoutPriority priority))priority { RPMethodNotImplemented(); }

- (RPConstraint * (^)(id, NSLayoutRelation))equalToWithRelation { RPMethodNotImplemented(); }

- (RPConstraint * (^)(id key))key { RPMethodNotImplemented(); }

- (void)setInsets:(UIEdgeInsets __unused)insets { RPMethodNotImplemented(); }

- (void)setSizeOffset:(CGSize __unused)sizeOffset { RPMethodNotImplemented(); }

- (void)setCenterOffset:(CGPoint __unused)centerOffset { RPMethodNotImplemented(); }

- (void)setOffset:(CGFloat __unused)offset { RPMethodNotImplemented(); }

- (void)activate { RPMethodNotImplemented(); }

- (void)deactivate { RPMethodNotImplemented(); }

- (void)install { RPMethodNotImplemented(); }

- (void)uninstall { RPMethodNotImplemented(); }

@end
