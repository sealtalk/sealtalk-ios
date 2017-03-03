//
//  UIVew+BFExtension.m
//  HoneycombClient
//
//  Created by Lucifer.YU on 12/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIView+YZHExtension.h"

@implementation UIView (YZHExtension)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)rp_left {
    return self.frame.origin.x;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setRp_left:(CGFloat)rd_left {
    CGRect frame = self.frame;
    frame.origin.x = rd_left;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)rp_top {
    return self.frame.origin.y;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setRp_top:(CGFloat)rd_top{
    CGRect frame = self.frame;
    frame.origin.y = rd_top;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)rp_right {
    return self.frame.origin.x + self.frame.size.width;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setRp_right:(CGFloat)rd_right{
    CGRect frame = self.frame;
    frame.origin.x = rd_right - frame.size.width;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)rp_bottom {
    return self.frame.origin.y + self.frame.size.height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setRp_bottom:(CGFloat)rd_bottom {
    CGRect frame = self.frame;
    frame.origin.y = rd_bottom - frame.size.height;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)rp_centerX {
    return self.center.x;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setRp_centerX:(CGFloat)rp_centerX{
    self.center = CGPointMake(rp_centerX, self.center.y);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)rp_centerY {
    return self.center.y;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setRp_centerY:(CGFloat)rp_centerY{
    self.center = CGPointMake(self.center.x, rp_centerY);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)rp_width {
    return self.frame.size.width;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setRp_width:(CGFloat)rp_width{
    CGRect frame = self.frame;
    frame.size.width = rp_width;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)rp_height {
    return self.frame.size.height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setRp_height:(CGFloat)rp_height{
    CGRect frame = self.frame;
    frame.size.height = rp_height;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)rp_ttScreenX {
    CGFloat x = 0.0f;
    for (UIView* view = self; view; view = view.superview) {
        x += view.rp_left;
    }
    return x;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)rp_ttScreenY {
    CGFloat y = 0.0f;
    for (UIView* view = self; view; view = view.superview) {
        y += view.rp_top;
    }
    return y;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)rp_screenViewX {
    CGFloat x = 0.0f;
    for (UIView* view = self; view; view = view.superview) {
        x += view.rp_left;
        
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView* scrollView = (UIScrollView*)view;
            x -= scrollView.contentOffset.x;
        }
    }
    
    return x;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)rp_screenViewY {
    CGFloat y = 0;
    for (UIView* view = self; view; view = view.superview) {
        y += view.rp_top;
        
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView* scrollView = (UIScrollView*)view;
            y -= scrollView.contentOffset.y;
        }
    }
    return y;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)rp_screenFrame {
    return CGRectMake(self.rp_screenViewX, self.rp_screenViewY, self.rp_width, self.rp_height);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGPoint)rp_origin {
    return self.frame.origin;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setRp_origin:(CGPoint)rp_origin{
    CGRect frame = self.frame;
    frame.origin = rp_origin;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)rp_size {
    return self.frame.size;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setRp_size:(CGSize)rp_size{
    CGRect frame = self.frame;
    frame.size = rp_size;
    self.frame = frame;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView *)findFirstResponder {
	UIView* baseView = self;
    
    if (baseView.isFirstResponder)
        return baseView;
	for (UIView *subview in baseView.subviews) {
		UIView *firstResponder = [subview findFirstResponder];
		if (firstResponder != nil)
			return firstResponder;
	}
	return nil;
}

- (id)rp_addsubview:(Class)viewClass {
    if ([viewClass isSubclassOfClass:[UIView class]] || viewClass == [UIView class]) {
        UIView * aView = [[viewClass alloc]init];
        [self addSubview:aView];
        return aView;
    }
    return nil;
}

+ (NSNumber *)properValue:(NSNumber *)values, ... {
    NSMutableArray *mutableValues = [NSMutableArray array];
    va_list args;
    va_start(args, values);
    if (values)
    {
        for (NSNumber *value = values;
             value != nil;
             value = va_arg(args, NSNumber *)) {
            [mutableValues addObject:value];
        }
    }
    va_end(args);
    
    switch (mutableValues.count) {
        case 0:
            return @(0);
            break;
        case 1:
            return mutableValues.firstObject;
            break;
        case 3: {
            if (RP_SCREENWIDTH == 320) {
                return mutableValues.firstObject;
            }else if (RP_SCREENWIDTH >320 && RP_SCREENWIDTH <414) {
                return mutableValues[1];
            }else {
                return mutableValues.lastObject;
            }
            break;
        }
        default:
            return @(0);
            break;
    }
}
@end
