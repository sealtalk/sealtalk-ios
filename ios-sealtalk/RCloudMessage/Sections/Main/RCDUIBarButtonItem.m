//
//  RCDUIBarButtonItem.m
//  RCloudMessage
//
//  Created by Jue on 16/8/24.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDUIBarButtonItem.h"
#import <RongIMKit/RongIMKit.h>
@interface RCDUIBarButtonItem ()

@property (nonatomic, strong) UILabel *titleText;

@end

@implementation RCDUIBarButtonItem
+ (NSArray *)getLeftBarButton:(NSString *)title target:(id)target action:(SEL)method {
    return [RCKitUtility getLeftNavigationItems:[UIImage imageNamed:@"navigator_btn_back"] title:nil target:target action:method];
}

//初始化包含图片的UIBarButtonItem
- (RCDUIBarButtonItem *)initContainImage:(UIImage *)buttonImage target:(id)target action:(SEL)method {
    self = [[RCDUIBarButtonItem alloc] init];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height)];
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button.frame = view.bounds;
    UIImageView *image = [[UIImageView alloc] initWithImage:buttonImage];
    image.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    [self.button addSubview:image];
    [self.button addTarget:target action:method forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.button];
    self.customView = view;

    return self;
}

//初始化不包含图片的UIBarButtonItem
- (RCDUIBarButtonItem *)initWithbuttonTitle:(NSString *)buttonTitle
                                 titleColor:(UIColor *)titleColor
                                buttonFrame:(CGRect)buttonFrame
                                     target:(id)target
                                     action:(SEL)method {
    self = [[RCDUIBarButtonItem alloc] init];
    self.button = [[UIButton alloc] initWithFrame:buttonFrame];
    [self.button setTitle:buttonTitle forState:UIControlStateNormal];
    [self.button setTitleColor:titleColor forState:UIControlStateNormal];
    [self.button addTarget:target action:method forControlEvents:UIControlEventTouchUpInside];
    self.customView = self.button;
    return self;
}

//设置UIBarButtonItem是否可以被点击和对应的颜色
- (void)buttonIsCanClick:(BOOL)isCanClick
             buttonColor:(UIColor *)buttonColor
           barButtonItem:(RCDUIBarButtonItem *)barButtonItem {
    if (isCanClick == YES) {
        barButtonItem.customView.userInteractionEnabled = YES;
    } else {
        barButtonItem.customView.userInteractionEnabled = NO;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (buttonColor != nil) {
            if (barButtonItem.titleText != nil) {
                [barButtonItem.titleText setTextColor:buttonColor];
            } else {
                [barButtonItem.button setTitleColor:buttonColor forState:UIControlStateNormal];
                barButtonItem.customView = barButtonItem.button;
            }
        }
    });
}

//平移UIBarButtonItem
- (NSArray<UIBarButtonItem *> *)setTranslation:(UIBarButtonItem *)barButtonItem translation:(CGFloat)translation {
    if (barButtonItem == nil) {
        return nil;
    }

    NSArray<UIBarButtonItem *> *barButtonItems;
    UIBarButtonItem *negativeSpacer =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = translation;

    barButtonItems = [NSArray arrayWithObjects:negativeSpacer, barButtonItem, nil];

    return barButtonItems;
}
@end
