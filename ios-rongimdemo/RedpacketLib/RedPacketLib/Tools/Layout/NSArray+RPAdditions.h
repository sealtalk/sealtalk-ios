//
//  NSArray+RPAdditions.h
//
//
//  Created by Daniel Hammond on 11/26/13.
//
//

#import "RPUtilities.h"
#import "RPConstraintMaker.h"
#import "RPViewAttribute.h"

typedef NS_ENUM(NSUInteger, MASAxisType) {
    RPAxisTypeHorizontal,
    RPAxisTypeVertical
};

@interface NSArray (RPAdditions)

/**
 *  Creates a RPConstraintMaker with each view in the callee.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing on each view
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to each view.
 *
 *  @return Array of created RPConstraints
 */
- (NSArray *)rpm_makeConstraints:(void (^)(RPConstraintMaker *make))block;

/**
 *  Creates a RPConstraintMaker with each view in the callee.
 *  Any constraints defined are added to each view or the appropriate superview once the block has finished executing on each view.
 *  If an existing constraint exists then it will be updated instead.
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to each view.
 *
 *  @return Array of created/updated RPConstraints
 */
- (NSArray *)rpm_updateConstraints:(void (^)(RPConstraintMaker *make))block;

/**
 *  Creates a RPConstraintMaker with each view in the callee.
 *  Any constraints defined are added to each view or the appropriate superview once the block has finished executing on each view.
 *  All constraints previously installed for the views will be removed.
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to each view.
 *
 *  @return Array of created/updated RPConstraints
 */
- (NSArray *)rpm_remakeConstraints:(void (^)(RPConstraintMaker *make))block;


@end
