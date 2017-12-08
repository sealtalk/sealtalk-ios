//
//  RCDUIBarButtonItem.h
//  RCloudMessage
//
//  Created by Jue on 16/8/24.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCDUIBarButtonItem : UIBarButtonItem

@property(nonatomic, strong) UIButton *button;
//初始化包含图片的
- (RCDUIBarButtonItem *)initWithLeftBarButton:(NSString *)title target:(id)target action:(SEL)method;

//初始化包含图片的UIBarButtonItem
- (RCDUIBarButtonItem *)initContainImage:(UIImage *)buttonImage
                          imageViewFrame:(CGRect)imageFrame
                             buttonTitle:(NSString *)buttonTitle
                              titleColor:(UIColor *)titleColor
                              titleFrame:(CGRect)titleFrame
                             buttonFrame:(CGRect)buttonFrame
                                  target:(id)target
                                  action:(SEL)method;

//初始化不包含图片的UIBarButtonItem
- (RCDUIBarButtonItem *)initWithbuttonTitle:(NSString *)buttonTitle
                                 titleColor:(UIColor *)titleColor
                                buttonFrame:(CGRect)buttonFrame
                                     target:(id)target
                                     action:(SEL)method;

//设置UIBarButtonItem是否可以被点击和对应的颜色
- (void)buttonIsCanClick:(BOOL)isCanClick
             buttonColor:(UIColor *)buttonColor
           barButtonItem:(RCDUIBarButtonItem *)barButtonItem;

//平移UIBarButtonItem
- (NSArray<UIBarButtonItem *> *)setTranslation:(UIBarButtonItem *)barButtonItem translation:(CGFloat)translation;
@end
