//
//  RPConstraint.h
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "RPViewAttribute.h"
#import "RPConstraint.h"
#import "RPLayoutConstraint.h"
#import "RPUtilities.h"

/**
 *  A single constraint.
 *  Contains the attributes neccessary for creating a NSLayoutConstraint and adding it to the appropriate view
 */
@interface RPViewConstraint : RPConstraint <NSCopying>

/**
 *	First item/view and first attribute of the NSLayoutConstraint
 */
@property (nonatomic, strong, readonly) RPViewAttribute *firstViewAttribute;

/**
 *	Second item/view and second attribute of the NSLayoutConstraint
 */
@property (nonatomic, strong, readonly) RPViewAttribute *secondViewAttribute;

/**
 *	initialises the RPViewConstraint with the first part of the equation
 *
 *	@param	firstViewAttribute	view.rpm_left, view.rpm_width etc.
 *
 *	@return	a new view constraint
 */
- (id)initWithFirstViewAttribute:(RPViewAttribute *)firstViewAttribute;

/**
 *  Returns all RPViewConstraints installed with this view as a first item.
 *
 *  @param  view  A view to retrieve constraints for.
 *
 *  @return An array of RPViewConstraints.
 */
+ (NSArray *)installedConstraintsForView:(UIView *)view;

@end
