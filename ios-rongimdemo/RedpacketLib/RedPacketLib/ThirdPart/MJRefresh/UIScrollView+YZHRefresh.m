//  代码地址: https://github.com/CoderMJLee/MJRefresh
//  代码地址: http://code4app.com/ios/%E5%BF%AB%E9%80%9F%E9%9B%86%E6%88%90%E4%B8%8B%E6%8B%89%E4%B8%8A%E6%8B%89%E5%88%B7%E6%96%B0/52326ce26803fabc46000000
//  UIScrollView+MJRefresh.m
//  MJRefreshExample
//
//  Created by MJ Lee on 15/3/4.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "UIScrollView+YZHRefresh.h"
#import "YZHRefreshHeader.h"
#import "YZHRefreshFooter.h"
#import <objc/runtime.h>

@implementation NSObject (YZHMJRefresh)

+ (void)exchangeInstanceMethod1:(SEL)method1 method2:(SEL)method2
{
    method_exchangeImplementations(class_getInstanceMethod(self, method1), class_getInstanceMethod(self, method2));
}

+ (void)exchangeClassMethod1:(SEL)method1 method2:(SEL)method2
{
    method_exchangeImplementations(class_getClassMethod(self, method1), class_getClassMethod(self, method2));
}

@end

@implementation UIScrollView (YZHMJRefresh)

#pragma mark - header
static const char RP_RefreshHeaderKey = '\0';
- (void)setRp_header:(YZHRefreshHeader *)rp_header
{
    if (rp_header != self.rp_header) {
        // 删除旧的，添加新的
        [self.rp_header removeFromSuperview];
        [self insertSubview:rp_header atIndex:0];
        
        // 存储新的
        [self willChangeValueForKey:@"rp_header"]; // KVO
        objc_setAssociatedObject(self, &RP_RefreshHeaderKey,
                                 rp_header, OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:@"rp_header"]; // KVO
    }
}

- (YZHRefreshHeader *)rp_header
{
    return objc_getAssociatedObject(self, &RP_RefreshHeaderKey);
}

#pragma mark - footer
static const char RP_RefreshFooterKey = '\0';
- (void)setRp_footer:(YZHRefreshFooter *)rp_footer
{
    if (rp_footer != self.rp_footer) {
        // 删除旧的，添加新的
        [self.rp_footer removeFromSuperview];
        [self addSubview:rp_footer];
        
        // 存储新的
        [self willChangeValueForKey:@"rp_footer"]; // KVO
        objc_setAssociatedObject(self, &RP_RefreshFooterKey,
                                 rp_footer, OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:@"rp_footer"]; // KVO
    }
}

- (YZHRefreshFooter *)rp_footer
{
    return objc_getAssociatedObject(self, &RP_RefreshFooterKey);
}

#pragma mark - 过期
//- (void)setFooter:(YZHRefreshFooter *)footer
//{
//    self.rp_footer = footer;
//}
//
//- (YZHRefreshFooter *)footer
//{
//    return self.rp_footer;
//}
//
//- (void)setHeader:(YZHRefreshHeader *)header
//{
//    self.rp_header = header;
//}
//
//- (YZHRefreshHeader *)header
//{
//    return self.rp_header;
//}

#pragma mark - other
- (NSInteger)rp_totalDataCount
{
    NSInteger totalCount = 0;
    if ([self isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self;
        
        for (NSInteger section = 0; section<tableView.numberOfSections; section++) {
            totalCount += [tableView numberOfRowsInSection:section];
        }
    } else if ([self isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        
        for (NSInteger section = 0; section<collectionView.numberOfSections; section++) {
            totalCount += [collectionView numberOfItemsInSection:section];
        }
    }
    return totalCount;
}

static const char RP_RefreshReloadDataBlockKey = '\0';
- (void)setRp_reloadDataBlock:(void (^)(NSInteger))rp_reloadDataBlock
{
    [self willChangeValueForKey:@"rp_reloadDataBlock"]; // KVO
    objc_setAssociatedObject(self, &RP_RefreshReloadDataBlockKey, rp_reloadDataBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self didChangeValueForKey:@"rp_reloadDataBlock"]; // KVO
}

- (void (^)(NSInteger))rp_reloadDataBlock
{
    return objc_getAssociatedObject(self, &RP_RefreshReloadDataBlockKey);
}

- (void)rp_executeReloadDataBlock
{
    !self.rp_reloadDataBlock ? : self.rp_reloadDataBlock(self.rp_totalDataCount);
}
@end

@implementation UITableView (RP_Refresh)

+ (void)load
{
    [self exchangeInstanceMethod1:@selector(reloadData) method2:@selector(rp_reloadData)];
}

- (void)rp_reloadData
{
    [self rp_reloadData];
    
    [self rp_executeReloadDataBlock];
}
@end

@implementation UICollectionView (RP_Refresh)

+ (void)load
{
    [self exchangeInstanceMethod1:@selector(reloadData) method2:@selector(rp_reloadData)];
}

- (void)rp_reloadData
{
    [self rp_reloadData];
    
    [self rp_executeReloadDataBlock];
}
@end
