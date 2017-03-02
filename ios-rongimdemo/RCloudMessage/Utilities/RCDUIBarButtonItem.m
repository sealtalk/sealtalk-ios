//
//  RCDUIBarButtonItem.m
//  RCloudMessage
//
//  Created by Jue on 16/8/24.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDUIBarButtonItem.h"

@interface RCDUIBarButtonItem ()

@property (nonatomic, strong) UILabel *titleText;

@end

@implementation RCDUIBarButtonItem

//初始化包含图片的UIBarButtonItem
- (RCDUIBarButtonItem *)initContainImage:(UIImage *)buttonImage imageViewFrame:(CGRect)imageFrame buttonTitle:(NSString *)buttonTitle titleColor:(UIColor*)titleColor titleFrame:(CGRect)titleFrame buttonFrame:(CGRect)buttonFrame target:(id)target action:(SEL)method {
  self = [[RCDUIBarButtonItem alloc] init];
  self.button = [UIButton buttonWithType:UIButtonTypeCustom];
  self.button.frame = buttonFrame;
  UIImageView *image = [[UIImageView alloc]
                          initWithImage:buttonImage];
  image.frame = imageFrame;
  [self.button addSubview:image];
  if (buttonTitle != nil && titleColor != nil) {
    self.titleText =
    [[UILabel alloc] initWithFrame:titleFrame];
    self.titleText.text = buttonTitle;
    [self.titleText setBackgroundColor:[UIColor clearColor]];
    [self.titleText setTextColor:titleColor];
    [self.button addSubview:self.titleText];
  }
  [self.button addTarget:target
              action:method
    forControlEvents:UIControlEventTouchUpInside];
  self.customView = self.button;
  return self;
}

//初始化不包含图片的UIBarButtonItem
- (RCDUIBarButtonItem *)initWithbuttonTitle:(NSString *)buttonTitle titleColor:(UIColor*)titleColor buttonFrame:(CGRect)buttonFrame target:(id)target action:(SEL)method {
  self = [[RCDUIBarButtonItem alloc] init];
  self.button = [[UIButton alloc] initWithFrame:buttonFrame];
  [self.button setTitle:buttonTitle forState:UIControlStateNormal];
  [self.button setTitleColor:titleColor forState:UIControlStateNormal];
  [self.button addTarget:target
                action:method
      forControlEvents:UIControlEventTouchUpInside];
  self.customView = self.button;
  return self;
}

//设置UIBarButtonItem是否可以被点击和对应的颜色
- (void)buttonIsCanClick:(BOOL)isCanClick buttonColor:(UIColor *)buttonColor barButtonItem:(RCDUIBarButtonItem *)barButtonItem{
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
- (NSArray<UIBarButtonItem *> *) setTranslation:(UIBarButtonItem *)barButtonItem translation:(CGFloat)translation
{
  if (barButtonItem == nil) {
    return nil;
  }
  
  NSArray<UIBarButtonItem *> *barButtonItems;
  UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                     target:nil action:nil];
  negativeSpacer.width = translation;
  
  barButtonItems = [NSArray arrayWithObjects:negativeSpacer, barButtonItem, nil];
  
  return barButtonItems;
}
@end
