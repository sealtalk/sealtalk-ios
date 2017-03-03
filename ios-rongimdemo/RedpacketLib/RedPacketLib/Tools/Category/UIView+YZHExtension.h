//
//  UIVew+BFExtension.h
//  HoneycombClient
//
//  Created by Lucifer.YU on 12/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define RP_SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define RP_SCREENHEIGHT [UIScreen mainScreen].bounds.size.height
#define RP_(args...) [UIView properValue:args,nil]
@interface UIView (YZHExtension)


/**
 * Shortcut for frame.origin.x.
 *
 * Sets frame.origin.x = left
 */
@property (nonatomic) CGFloat rp_left;

/**
 * Shortcut for frame.origin.y
 *
 * Sets frame.origin.y = top
 */
@property (nonatomic) CGFloat rp_top;

/**
 * Shortcut for frame.origin.x + frame.size.width
 *
 * Sets frame.origin.x = right - frame.size.width
 */
@property (nonatomic) CGFloat rp_right;

/**
 * Shortcut for frame.origin.y + frame.size.height
 *
 * Sets frame.origin.y = bottom - frame.size.height
 */
@property (nonatomic) CGFloat rp_bottom;

/**
 * Shortcut for frame.size.width
 *
 * Sets frame.size.width = width
 */
@property (nonatomic) CGFloat rp_width;

/**
 * Shortcut for frame.size.height
 *
 * Sets frame.size.height = height
 */
@property (nonatomic) CGFloat rp_height;

/**
 * Shortcut for center.x
 *
 * Sets center.x = centerX
 */
@property (nonatomic) CGFloat rp_centerX;

/**
 * Shortcut for center.y
 *
 * Sets center.y = centerY
 */
@property (nonatomic) CGFloat rp_centerY;

/**
 * Return the x coordinate on the screen.
 */
@property (nonatomic, readonly) CGFloat rp_ttScreenX;

/**
 * Return the y coordinate on the screen.
 */
@property (nonatomic, readonly) CGFloat rp_ttScreenY;

/**
 * Return the x coordinate on the screen, taking into account scroll views.
 */
@property (nonatomic, readonly) CGFloat rp_screenViewX;

/**
 * Return the y coordinate on the screen, taking into account scroll views.
 */
@property (nonatomic, readonly) CGFloat rp_screenViewY;

/**
 * Return the view frame on the screen, taking into account scroll views.
 */
@property (nonatomic, readonly) CGRect rp_screenFrame;

/**
 * Shortcut for frame.origin
 */
@property (nonatomic) CGPoint rp_origin;

/**
 * Shortcut for frame.size
 */
@property (nonatomic) CGSize rp_size;

// Find first responder in subviews
- (UIView *)findFirstResponder;

//simple add subleview
- (id)rp_addsubview:(Class)viewClass;

+ (NSNumber *)properValue:(NSNumber *)values, ...;
@end
