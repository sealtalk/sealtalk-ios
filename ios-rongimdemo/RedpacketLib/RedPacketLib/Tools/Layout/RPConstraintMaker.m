//
//  RPConstraintBuilder.m
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "RPConstraintMaker.h"
#import "RPViewConstraint.h"
#import "RPCompositeConstraint.h"
#import "RPConstraint+Private.h"
#import "RPViewAttribute.h"
#import "View+RPAdditions.h"

@interface RPConstraintMaker () <RPConstraintDelegate>

@property (nonatomic, weak) UIView *view;
@property (nonatomic, strong) NSMutableArray *constraints;

@end

@implementation RPConstraintMaker

- (id)initWithView:(UIView *)view {
    self = [super init];
    if (!self) return nil;
    
    self.view = view;
    self.constraints = NSMutableArray.new;
    
    return self;
}

- (NSArray *)install {
    if (self.removeExisting) {
        NSArray *installedConstraints = [RPViewConstraint installedConstraintsForView:self.view];
        for (RPConstraint *constraint in installedConstraints) {
            [constraint uninstall];
        }
    }
    NSArray *constraints = self.constraints.copy;
    for (RPConstraint *constraint in constraints) {
        constraint.updateExisting = self.updateExisting;
        [constraint install];
    }
    [self.constraints removeAllObjects];
    return constraints;
}

#pragma mark - RPConstraintDelegate

- (void)constraint:(RPConstraint *)constraint shouldBeReplacedWithConstraint:(RPConstraint *)replacementConstraint {
    NSUInteger index = [self.constraints indexOfObject:constraint];
    NSAssert(index != NSNotFound, @"Could not find constraint %@", constraint);
    [self.constraints replaceObjectAtIndex:index withObject:replacementConstraint];
}

- (RPConstraint *)constraint:(RPConstraint *)constraint addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    RPViewAttribute *viewAttribute = [[RPViewAttribute alloc] initWithView:self.view layoutAttribute:layoutAttribute];
    RPViewConstraint *newConstraint = [[RPViewConstraint alloc] initWithFirstViewAttribute:viewAttribute];
    if ([constraint isKindOfClass:RPViewConstraint.class]) {
        //replace with composite constraint
        NSArray *children = @[constraint, newConstraint];
        RPCompositeConstraint *compositeConstraint = [[RPCompositeConstraint alloc] initWithChildren:children];
        compositeConstraint.delegate = self;
        [self constraint:constraint shouldBeReplacedWithConstraint:compositeConstraint];
        return compositeConstraint;
    }
    if (!constraint) {
        newConstraint.delegate = self;
        [self.constraints addObject:newConstraint];
    }
    return newConstraint;
}

- (RPConstraint *)addConstraintWithAttributes:(MASAttribute)attrs {
    __unused MASAttribute anyAttribute = (MASAttributeLeft | MASAttributeRight | MASAttributeTop | MASAttributeBottom | MASAttributeLeading
                                          | MASAttributeTrailing | MASAttributeWidth | MASAttributeHeight | MASAttributeCenterX
                                          | MASAttributeCenterY | MASAttributeBaseline
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
                                          | MASAttributeFirstBaseline | MASAttributeLastBaseline
#endif
#if TARGET_OS_IPHONE || TARGET_OS_TV
                                          | MASAttributeLeftMargin | MASAttributeRightMargin | MASAttributeTopMargin | MASAttributeBottomMargin
                                          | MASAttributeLeadingMargin | MASAttributeTrailingMargin | MASAttributeCenterXWithinMargins
                                          | MASAttributeCenterYWithinMargins
#endif
                                          );
    
    NSAssert((attrs & anyAttribute) != 0, @"You didn't pass any attribute to make.attributes(...)");
    
    NSMutableArray *attributes = [NSMutableArray array];
    
    if (attrs & MASAttributeLeft) [attributes addObject:self.view.rpm_left];
    if (attrs & MASAttributeRight) [attributes addObject:self.view.rpm_right];
    if (attrs & MASAttributeTop) [attributes addObject:self.view.rpm_top];
    if (attrs & MASAttributeBottom) [attributes addObject:self.view.rpm_bottom];
    if (attrs & MASAttributeLeading) [attributes addObject:self.view.rpm_leading];
    if (attrs & MASAttributeTrailing) [attributes addObject:self.view.rpm_trailing];
    if (attrs & MASAttributeWidth) [attributes addObject:self.view.rpm_width];
    if (attrs & MASAttributeHeight) [attributes addObject:self.view.rpm_height];
    if (attrs & MASAttributeCenterX) [attributes addObject:self.view.rpm_centerX];
    if (attrs & MASAttributeCenterY) [attributes addObject:self.view.rpm_centerY];
    if (attrs & MASAttributeBaseline) [attributes addObject:self.view.rpm_baseline];
    
    
#if TARGET_OS_IPHONE || TARGET_OS_TV
    
    if (attrs & MASAttributeLeftMargin) [attributes addObject:self.view.rpm_leftMargin];
    if (attrs & MASAttributeRightMargin) [attributes addObject:self.view.rpm_rightMargin];
    if (attrs & MASAttributeTopMargin) [attributes addObject:self.view.rpm_topMargin];
    if (attrs & MASAttributeBottomMargin) [attributes addObject:self.view.rpm_bottomMargin];
    if (attrs & MASAttributeLeadingMargin) [attributes addObject:self.view.rpm_leadingMargin];
    if (attrs & MASAttributeTrailingMargin) [attributes addObject:self.view.rpm_trailingMargin];
    if (attrs & MASAttributeCenterXWithinMargins) [attributes addObject:self.view.rpm_centerXWithinMargins];
    if (attrs & MASAttributeCenterYWithinMargins) [attributes addObject:self.view.rpm_centerYWithinMargins];
    
#endif
    
    NSMutableArray *children = [NSMutableArray arrayWithCapacity:attributes.count];
    
    for (RPViewAttribute *a in attributes) {
        [children addObject:[[RPViewConstraint alloc] initWithFirstViewAttribute:a]];
    }
    
    RPCompositeConstraint *constraint = [[RPCompositeConstraint alloc] initWithChildren:children];
    constraint.delegate = self;
    [self.constraints addObject:constraint];
    return constraint;
}

#pragma mark - standard Attributes

- (RPConstraint *)addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    return [self constraint:nil addConstraintWithLayoutAttribute:layoutAttribute];
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

- (RPConstraint *(^)(MASAttribute))attributes {
    return ^(MASAttribute attrs){
        return [self addConstraintWithAttributes:attrs];
    };
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


#pragma mark - composite Attributes

- (RPConstraint *)edges {
    return [self addConstraintWithAttributes:MASAttributeTop | MASAttributeLeft | MASAttributeRight | MASAttributeBottom];
}

- (RPConstraint *)size {
    return [self addConstraintWithAttributes:MASAttributeWidth | MASAttributeHeight];
}

- (RPConstraint *)center {
    return [self addConstraintWithAttributes:MASAttributeCenterX | MASAttributeCenterY];
}

#pragma mark - grouping

- (RPConstraint *(^)(dispatch_block_t group))group {
    return ^id(dispatch_block_t group) {
        NSInteger previousCount = self.constraints.count;
        group();

        NSArray *children = [self.constraints subarrayWithRange:NSMakeRange(previousCount, self.constraints.count - previousCount)];
        RPCompositeConstraint *constraint = [[RPCompositeConstraint alloc] initWithChildren:children];
        constraint.delegate = self;
        return constraint;
    };
}

@end
