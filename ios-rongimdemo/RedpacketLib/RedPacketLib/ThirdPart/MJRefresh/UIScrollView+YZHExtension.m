//  代码地址: https://github.com/CoderMJLee/MJRefresh
//  代码地址: http://code4app.com/ios/%E5%BF%AB%E9%80%9F%E9%9B%86%E6%88%90%E4%B8%8B%E6%8B%89%E4%B8%8A%E6%8B%89%E5%88%B7%E6%96%B0/52326ce26803fabc46000000
//  UIScrollView+Extension.m
//  MJRefreshExample
//
//  Created by MJ Lee on 14-5-28.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import "UIScrollView+YZHExtension.h"
#import <objc/runtime.h>

@implementation UIScrollView (YZHExtension)

- (void)setRp_insetT:(CGFloat)rp_insetT
{
    UIEdgeInsets inset = self.contentInset;
    inset.top = rp_insetT;
    self.contentInset = inset;
}

- (CGFloat)rp_insetT
{
    return self.contentInset.top;
}

- (void)setRp_insetB:(CGFloat)rp_insetB
{
    UIEdgeInsets inset = self.contentInset;
    inset.bottom = rp_insetB;
    self.contentInset = inset;
}

- (CGFloat)rp_insetB
{
    return self.contentInset.bottom;
}

- (void)setRp_insetL:(CGFloat)rp_insetL
{
    UIEdgeInsets inset = self.contentInset;
    inset.left = rp_insetL;
    self.contentInset = inset;
}

- (CGFloat)rp_insetL
{
    return self.contentInset.left;
}

- (void)setRp_insetR:(CGFloat)rp_insetR
{
    UIEdgeInsets inset = self.contentInset;
    inset.right = rp_insetR;
    self.contentInset = inset;
}

- (CGFloat)rp_insetR
{
    return self.contentInset.right;
}

- (void)setRp_offsetX:(CGFloat)rp_offsetX
{
    CGPoint offset = self.contentOffset;
    offset.x = rp_offsetX;
    self.contentOffset = offset;
}

- (CGFloat)rp_offsetX
{
    return self.contentOffset.x;
}

- (void)setRp_offsetY:(CGFloat)rp_offsetY
{
    CGPoint offset = self.contentOffset;
    offset.y = rp_offsetY;
    self.contentOffset = offset;
}

- (CGFloat)rp_offsetY
{
    return self.contentOffset.y;
}

- (void)setRp_contentW:(CGFloat)rp_contentW
{
    CGSize size = self.contentSize;
    size.width = rp_contentW;
    self.contentSize = size;
}

- (CGFloat)rp_contentW
{
    return self.contentSize.width;
}

- (void)setRp_contentH:(CGFloat)rp_contentH
{
    CGSize size = self.contentSize;
    size.height = rp_contentH;
    self.contentSize = size;
}

- (CGFloat)rp_contentH
{
    return self.contentSize.height;
}
@end
