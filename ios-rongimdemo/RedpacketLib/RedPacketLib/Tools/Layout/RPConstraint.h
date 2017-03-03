//
//  RPConstraint.h
//  Masonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "RPUtilities.h"

/**
 *	Enables Constraints to be created with chainable syntax
 *  Constraint can represent single NSLayoutConstraint (RPViewConstraint) 
 *  or a group of NSLayoutConstraints (MASComposisteConstraint)
 */
@interface RPConstraint : NSObject

// Chaining Support

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects RPConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight
 */
- (RPConstraint * (^)(UIEdgeInsets insets))insets;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects RPConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeWidth, NSLayoutAttributeHeight
 */
- (RPConstraint * (^)(CGSize offset))sizeOffset;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects RPConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeCenterX, NSLayoutAttributeCenterY
 */
- (RPConstraint * (^)(CGPoint offset))centerOffset;

/**
 *	Modifies the NSLayoutConstraint constant
 */
- (RPConstraint * (^)(CGFloat offset))offset;

/**
 *  Modifies the NSLayoutConstraint constant based on a value type
 */
- (RPConstraint * (^)(NSValue *value))valueOffset;

/**
 *	Sets the NSLayoutConstraint multiplier property
 */
- (RPConstraint * (^)(CGFloat multiplier))multipliedBy;

/**
 *	Sets the NSLayoutConstraint multiplier to 1.0/dividedBy
 */
- (RPConstraint * (^)(CGFloat divider))dividedBy;

/**
 *	Sets the NSLayoutConstraint priority to a float or MASLayoutPriority
 */
- (RPConstraint * (^)(UILayoutPriority priority))priority;

/**
 *	Sets the NSLayoutConstraint priority to MASLayoutPriorityLow
 */
- (RPConstraint * (^)())priorityLow;

/**
 *	Sets the NSLayoutConstraint priority to MASLayoutPriorityMedium
 */
- (RPConstraint * (^)())priorityMedium;

/**
 *	Sets the NSLayoutConstraint priority to MASLayoutPriorityHigh
 */
- (RPConstraint * (^)())priorityHigh;

/**
 *	Sets the constraint relation to NSLayoutRelationEqual
 *  returns a block which accepts one of the following:
 *    RPViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (RPConstraint * (^)(id attr))equalTo;

/**
 *	Sets the constraint relation to NSLayoutRelationGreaterThanOrEqual
 *  returns a block which accepts one of the following:
 *    RPViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (RPConstraint * (^)(id attr))greaterThanOrEqualTo;

/**
 *	Sets the constraint relation to NSLayoutRelationLessThanOrEqual
 *  returns a block which accepts one of the following:
 *    RPViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (RPConstraint * (^)(id attr))lessThanOrEqualTo;

/**
 *	Optional semantic property which has no effect but improves the readability of constraint
 */
- (RPConstraint *)with;

/**
 *	Optional semantic property which has no effect but improves the readability of constraint
 */
- (RPConstraint *)and;

/**
 *	Creates a new RPCompositeConstraint with the called attribute and reciever
 */
- (RPConstraint *)left;
- (RPConstraint *)top;
- (RPConstraint *)right;
- (RPConstraint *)bottom;
- (RPConstraint *)leading;
- (RPConstraint *)trailing;
- (RPConstraint *)width;
- (RPConstraint *)height;
- (RPConstraint *)centerX;
- (RPConstraint *)centerY;
- (RPConstraint *)baseline;

#if TARGET_OS_IPHONE || TARGET_OS_TV

- (RPConstraint *)leftMargin;
- (RPConstraint *)rightMargin;
- (RPConstraint *)topMargin;
- (RPConstraint *)bottomMargin;
- (RPConstraint *)leadingMargin;
- (RPConstraint *)trailingMargin;
- (RPConstraint *)centerXWithinMargins;
- (RPConstraint *)centerYWithinMargins;

#endif


/**
 *	Sets the constraint debug name
 */
- (RPConstraint * (^)(id key))key;

// NSLayoutConstraint constant Setters
// for use outside of rpm_updateConstraints/rpm_makeConstraints blocks

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects RPConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight
 */
- (void)setInsets:(UIEdgeInsets)insets;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects RPConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeWidth, NSLayoutAttributeHeight
 */
- (void)setSizeOffset:(CGSize)sizeOffset;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects RPConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeCenterX, NSLayoutAttributeCenterY
 */
- (void)setCenterOffset:(CGPoint)centerOffset;

/**
 *	Modifies the NSLayoutConstraint constant
 */
- (void)setOffset:(CGFloat)offset;

/**
 *  Activates an NSLayoutConstraint if it's supported by an OS. 
 *  Invokes install otherwise.
 */
- (void)activate;

/**
 *  Deactivates previously installed/activated NSLayoutConstraint.
 */
- (void)deactivate;

/**
 *	Creates a NSLayoutConstraint and adds it to the appropriate view.
 */
- (void)install;

/**
 *	Removes previously installed NSLayoutConstraint
 */
- (void)uninstall;

@end




