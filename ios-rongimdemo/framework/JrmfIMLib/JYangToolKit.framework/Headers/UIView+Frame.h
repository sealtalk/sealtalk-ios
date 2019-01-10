//
//  UIView+Frame.h
//  JrmfWalletKit
//
//  Created by 一路财富 on 16/11/2.
//  Copyright © 2016年 JYang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Frame)

@property (nonatomic, assign) CGFloat jrmf_x;
@property (nonatomic, assign) CGFloat jrmf_y;
@property (nonatomic, assign) CGFloat jrmf_width;
@property (nonatomic, assign) CGFloat jrmf_height;

@property (nonatomic, assign) CGPoint jrmf_origin;
@property (nonatomic, assign) CGSize  jrmf_size;

@property (nonatomic, assign) CGFloat jrmf_centerX;
@property (nonatomic, assign) CGFloat jrmf_centerY;

@end
