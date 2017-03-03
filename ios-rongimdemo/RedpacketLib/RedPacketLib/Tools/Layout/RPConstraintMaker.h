//
//  RPConstraintBuilder.h
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "RPConstraint.h"
#import "RPUtilities.h"

typedef NS_OPTIONS(NSInteger, MASAttribute) {
    MASAttributeLeft = 1 << NSLayoutAttributeLeft,
    MASAttributeRight = 1 << NSLayoutAttributeRight,
    MASAttributeTop = 1 << NSLayoutAttributeTop,
    MASAttributeBottom = 1 << NSLayoutAttributeBottom,
    MASAttributeLeading = 1 << NSLayoutAttributeLeading,
    MASAttributeTrailing = 1 << NSLayoutAttributeTrailing,
    MASAttributeWidth = 1 << NSLayoutAttributeWidth,
    MASAttributeHeight = 1 << NSLayoutAttributeHeight,
    MASAttributeCenterX = 1 << NSLayoutAttributeCenterX,
    MASAttributeCenterY = 1 << NSLayoutAttributeCenterY,
    MASAttributeBaseline = 1 << NSLayoutAttributeBaseline,
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
    
    MASAttributeFirstBaseline = 1 << NSLayoutAttributeFirstBaseline,
    MASAttributeLastBaseline = 1 << NSLayoutAttributeLastBaseline,
    
#endif
    
#if TARGET_OS_IPHONE || TARGET_OS_TV
    
    MASAttributeLeftMargin = 1 << NSLayoutAttributeLeftMargin,
    MASAttributeRightMargin = 1 << NSLayoutAttributeRightMargin,
    MASAttributeTopMargin = 1 << NSLayoutAttributeTopMargin,
    MASAttributeBottomMargin = 1 << NSLayoutAttributeBottomMargin,
    MASAttributeLeadingMargin = 1 << NSLayoutAttributeLeadingMargin,
    MASAttributeTrailingMargin = 1 << NSLayoutAttributeTrailingMargin,
    MASAttributeCenterXWithinMargins = 1 << NSLayoutAttributeCenterXWithinMargins,
    MASAttributeCenterYWithinMargins = 1 << NSLayoutAttributeCenterYWithinMargins,

#endif
    
};

/**
 *  Provides factory methods for creating RPConstraints.
 *  Constraints are collected until they are ready to be installed
 *
 */
@interface RPConstraintMaker : NSObject

/**
 *	The following properties return a new RPViewConstraint
 *  with the first item set to the makers associated view and the appropriate RPViewAttribute
 */
@property (nonatomic, strong, readonly) RPConstraint *left;
@property (nonatomic, strong, readonly) RPConstraint *top;
@property (nonatomic, strong, readonly) RPConstraint *right;
@property (nonatomic, strong, readonly) RPConstraint *bottom;
@property (nonatomic, strong, readonly) RPConstraint *leading;
@property (nonatomic, strong, readonly) RPConstraint *trailing;
@property (nonatomic, strong, readonly) RPConstraint *width;
@property (nonatomic, strong, readonly) RPConstraint *height;
@property (nonatomic, strong, readonly) RPConstraint *centerX;
@property (nonatomic, strong, readonly) RPConstraint *centerY;
@property (nonatomic, strong, readonly) RPConstraint *baseline;

#if TARGET_OS_IPHONE || TARGET_OS_TV

@property (nonatomic, strong, readonly) RPConstraint *leftMargin;
@property (nonatomic, strong, readonly) RPConstraint *rightMargin;
@property (nonatomic, strong, readonly) RPConstraint *topMargin;
@property (nonatomic, strong, readonly) RPConstraint *bottomMargin;
@property (nonatomic, strong, readonly) RPConstraint *leadingMargin;
@property (nonatomic, strong, readonly) RPConstraint *trailingMargin;
@property (nonatomic, strong, readonly) RPConstraint *centerXWithinMargins;
@property (nonatomic, strong, readonly) RPConstraint *centerYWithinMargins;

#endif

/**
 *  Returns a block which creates a new MASCompositeConstraint with the first item set
 *  to the makers associated view and children corresponding to the set bits in the
 *  MASAttribute parameter. Combine multiple attributes via binary-or.
 */
@property (nonatomic, strong, readonly) RPConstraint *(^attributes)(MASAttribute attrs);

/**
 *	Creates a MASCompositeConstraint with type MASCompositeConstraintTypeEdges
 *  which generates the appropriate RPViewConstraint children (top, left, bottom, right)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) RPConstraint *edges;

/**
 *	Creates a MASCompositeConstraint with type MASCompositeConstraintTypeSize
 *  which generates the appropriate RPViewConstraint children (width, height)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) RPConstraint *size;

/**
 *	Creates a MASCompositeConstraint with type MASCompositeConstraintTypeCenter
 *  which generates the appropriate RPViewConstraint children (centerX, centerY)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) RPConstraint *center;

/**
 *  Whether or not to check for an existing constraint instead of adding constraint
 */
@property (nonatomic, assign) BOOL updateExisting;

/**
 *  Whether or not to remove existing constraints prior to installing
 */
@property (nonatomic, assign) BOOL removeExisting;

/**
 *	initialises the maker with a default view
 *
 *	@param	view	any MASConstrait are created with this view as the first item
 *
 *	@return	a new RPConstraintMaker
 */
- (id)initWithView:(UIView *)view;

/**
 *	Calls install method on any RPConstraints which have been created by this maker
 *
 *	@return	an array of all the installed RPConstraints
 */
- (NSArray *)install;

- (RPConstraint * (^)(dispatch_block_t))group;

@end
