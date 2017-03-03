//
//  MJRefreshAutoGifFooter.m
//  MJRefreshExample
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "YZHRefreshAutoGifFooter.h"

@interface YZHRefreshAutoGifFooter()
@property (weak, nonatomic) UIImageView *gifView;
/** 所有状态对应的动画图片 */
@property (strong, nonatomic) NSMutableDictionary *stateImages;
/** 所有状态对应的动画时间 */
@property (strong, nonatomic) NSMutableDictionary *stateDurations;
@end

@implementation YZHRefreshAutoGifFooter
#pragma mark - 懒加载
- (UIImageView *)gifView
{
    if (!_gifView) {
        UIImageView *gifView = [[UIImageView alloc] init];
        [self addSubview:_gifView = gifView];
    }
    return _gifView;
}

- (NSMutableDictionary *)stateImages
{
    if (!_stateImages) {
        self.stateImages = [NSMutableDictionary dictionary];
    }
    return _stateImages;
}

- (NSMutableDictionary *)stateDurations
{
    if (!_stateDurations) {
        self.stateDurations = [NSMutableDictionary dictionary];
    }
    return _stateDurations;
}

#pragma mark - 公共方法
- (void)setImages:(NSArray *)images duration:(NSTimeInterval)duration forState:(YZHRefreshState)state
{
    if (images == nil) return;
    
    self.stateImages[@(state)] = images;
    self.stateDurations[@(state)] = @(duration);
    
    /* 根据图片设置控件的高度 */
    UIImage *image = [images firstObject];
    if (image.size.height > self.rp_height) {
        self.rp_height = image.size.height;
    }
}

- (void)setImages:(NSArray *)images forState:(YZHRefreshState)state
{
    [self setImages:images duration:images.count * 0.1 forState:state];
}

#pragma mark - 实现父类的方法
- (void)placeSubviews
{
    [super placeSubviews];
    
    if (self.gifView.constraints.count) return;
    
    self.gifView.frame = self.bounds;
    if (self.isRefreshingTitleHidden) {
        self.gifView.contentMode = UIViewContentModeCenter;
    } else {
        self.gifView.contentMode = UIViewContentModeRight;
        self.gifView.rp_width = self.rp_width * 0.5 - 90;
    }
}

- (void)setState:(YZHRefreshState)state
{
    YZHMJRefreshCheckState
    
    // 根据状态做事情
    if (state == MJRefreshStateRefreshing) {
        NSArray *images = self.stateImages[@(state)];
        if (images.count == 0) return;
        [self.gifView stopAnimating];
        
        self.gifView.hidden = NO;
        if (images.count == 1) { // 单张图片
            self.gifView.image = [images lastObject];
        } else { // 多张图片
            self.gifView.animationImages = images;
            self.gifView.animationDuration = [self.stateDurations[@(state)] doubleValue];
            [self.gifView startAnimating];
        }
    } else if (state == MJRefreshStateNoMoreData || state == MJRefreshStateIdle) {
        [self.gifView stopAnimating];
        self.gifView.hidden = YES;
    }
}
@end

