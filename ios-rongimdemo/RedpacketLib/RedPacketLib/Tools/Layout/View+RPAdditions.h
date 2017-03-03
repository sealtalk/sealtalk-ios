//
//  UIView+MASAdditions.h
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "RPUtilities.h"
#import "RPConstraintMaker.h"
#import "RPViewAttribute.h"

/**
 *	Provides constraint maker block
 *  and convience methods for creating RPViewAttribute which are view + NSLayoutAttribute pairs
 */
@interface UIView (RPAdditions)

/**
 *	following properties return a new RPViewAttribute with current view and appropriate NSLayoutAttribute
 */
@property (nonatomic, strong, readonly) RPViewAttribute *rpm_left;
@property (nonatomic, strong, readonly) RPViewAttribute *rpm_top;
@property (nonatomic, strong, readonly) RPViewAttribute *rpm_right;
@property (nonatomic, strong, readonly) RPViewAttribute *rpm_bottom;
@property (nonatomic, strong, readonly) RPViewAttribute *rpm_leading;
@property (nonatomic, strong, readonly) RPViewAttribute *rpm_trailing;
@property (nonatomic, strong, readonly) RPViewAttribute *rpm_width;
@property (nonatomic, strong, readonly) RPViewAttribute *rpm_height;
@property (nonatomic, strong, readonly) RPViewAttribute *rpm_centerX;
@property (nonatomic, strong, readonly) RPViewAttribute *rpm_centerY;
@property (nonatomic, strong, readonly) RPViewAttribute *rpm_baseline;
@property (nonatomic, strong, readonly) RPViewAttribute *(^rpm_attribute)(NSLayoutAttribute attr);

#if TARGET_OS_IPHONE || TARGET_OS_TV

@property (nonatomic, strong, readonly) RPViewAttribute *rpm_leftMargin;
@property (nonatomic, strong, readonly) RPViewAttribute *rpm_rightMargin;
@property (nonatomic, strong, readonly) RPViewAttribute *rpm_topMargin;
@property (nonatomic, strong, readonly) RPViewAttribute *rpm_bottomMargin;
@property (nonatomic, strong, readonly) RPViewAttribute *rpm_leadingMargin;
@property (nonatomic, strong, readonly) RPViewAttribute *rpm_trailingMargin;
@property (nonatomic, strong, readonly) RPViewAttribute *rpm_centerXWithinMargins;
@property (nonatomic, strong, readonly) RPViewAttribute *rpm_centerYWithinMargins;

#endif

/**
 *	a key to associate with this view
 */
@property (nonatomic, strong) id rpm_key;

/**
 *	Finds the closest common superview between this view and another view
 *
 *	@param	view	other view
 *
 *	@return	returns nil if common superview could not be found
 */
- (instancetype)rpm_closestCommonSuperview:(UIView *)view;

/**
 *  Creates a RPConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created RPConstraints
 */
- (NSArray *)rpm_makeConstraints:(void(^)(RPConstraintMaker *make))block;

/**
 *  Creates a RPConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing.
 *  If an existing constraint exists then it will be updated instead.
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created/updated RPConstraints
 */
- (NSArray *)rpm_updateConstraints:(void(^)(RPConstraintMaker *make))block;

/**
 *  Creates a RPConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing.
 *  All constraints previously installed for the view will be removed.
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created/updated RPConstraints
 */
- (NSArray *)rpm_remakeConstraints:(void(^)(RPConstraintMaker *make))block;

@end
