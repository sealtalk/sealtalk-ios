//
//  RedpacketErrorView.h
//  RedpacketLib
//
//  Created by Mr.Yang on 16/5/12.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RedpacketErrorView : UIView

+ (RedpacketErrorView *)viewWithWith:(CGFloat)width;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *prompt;
@property (nonatomic, strong) UIButton *submitButton;

@property (nonatomic, copy) void(^buttonClickBlock)(void);

@end
