//
//  RPCompositeConstraint.h
//  Masonry
//
//  Created by Jonas Budelmann on 21/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "RPConstraint.h"
#import "RPUtilities.h"

/**
 *	A group of RPConstraint objects
 */
@interface RPCompositeConstraint : RPConstraint

/**
 *	Creates a composite with a predefined array of children
 *
 *	@param	children	child RPConstraints
 *
 *	@return	a composite constraint
 */
- (id)initWithChildren:(NSArray *)children;

@end
