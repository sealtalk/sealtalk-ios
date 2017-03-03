//
//  MASAttribute.h
//  Masonry
//
//  Created by Jonas Budelmann on 21/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "RPUtilities.h"

/**
 *  An immutable tuple which stores the view and the related NSLayoutAttribute.
 *  Describes part of either the left or right hand side of a constraint equation
 */
@interface RPViewAttribute : NSObject

/**
 *  The view which the reciever relates to. Can be nil if item is not a view.
 */
@property (nonatomic, weak, readonly) UIView *view;

/**
 *  The item which the reciever relates to.
 */
@property (nonatomic, weak, readonly) id item;

/**
 *  The attribute which the reciever relates to
 */
@property (nonatomic, assign, readonly) NSLayoutAttribute layoutAttribute;

/**
 *  Convenience initializer.
 */
- (id)initWithView:(UIView *)view layoutAttribute:(NSLayoutAttribute)layoutAttribute;

/**
 *  The designated initializer.
 */
- (id)initWithView:(UIView *)view item:(id)item layoutAttribute:(NSLayoutAttribute)layoutAttribute;

/**
 *	Determine whether the layoutAttribute is a size attribute
 *
 *	@return	YES if layoutAttribute is equal to NSLayoutAttributeWidth or NSLayoutAttributeHeight
 */
- (BOOL)isSizeAttribute;

@end
