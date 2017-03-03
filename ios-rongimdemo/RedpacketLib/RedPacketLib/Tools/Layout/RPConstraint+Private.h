//
//  RPConstraint+Private.h
//  Masonry
//
//  Created by Nick Tymchenko on 29/04/14.
//  Copyright (c) 2014 cloudling. All rights reserved.
//

#import "RPConstraint.h"

@protocol RPConstraintDelegate;


@interface RPConstraint ()

/**
 *  Whether or not to check for an existing constraint instead of adding constraint
 */
@property (nonatomic, assign) BOOL updateExisting;

/**
 *	Usually RPConstraintMaker but could be a parent RPConstraint
 */
@property (nonatomic, weak) id<RPConstraintDelegate> delegate;

/**
 *  Based on a provided value type, is equal to calling:
 *  NSNumber - setOffset:
 *  NSValue with CGPoint - setPointOffset:
 *  NSValue with CGSize - setSizeOffset:
 *  NSValue with UIEdgeInsets - setInsets:
 */
- (void)setLayoutConstantWithValue:(NSValue *)value;

@end


@interface RPConstraint (Abstract)

/**
 *	Sets the constraint relation to given NSLayoutRelation
 *  returns a block which accepts one of the following:
 *    RPViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (RPConstraint * (^)(id, NSLayoutRelation))equalToWithRelation;

/**
 *	Override to set a custom chaining behaviour
 */
- (RPConstraint *)addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute;

@end


@protocol RPConstraintDelegate <NSObject>

/**
 *	Notifies the delegate when the constraint needs to be replaced with another constraint. For example
 *  A RPViewConstraint may turn into a RPCompositeConstraint when an array is passed to one of the equality blocks
 */
- (void)constraint:(RPConstraint *)constraint shouldBeReplacedWithConstraint:(RPConstraint *)replacementConstraint;

- (RPConstraint *)constraint:(RPConstraint *)constraint addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute;

@end
