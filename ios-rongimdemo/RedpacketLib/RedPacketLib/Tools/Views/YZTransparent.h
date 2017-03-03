//
//  YHTransparent.h
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/2/26.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YZTransparent;

typedef void(^TransparentViewTouch)(YZTransparent *view);


@interface YZTransparent : UIView

@property (nonatomic, copy) TransparentViewTouch transparentViewTouchBlock;

+ (void)removeFromSuperView;

+ (void)showInMainWindow:(TransparentViewTouch)touchBlock;

+ (void)showInView:(UIView *)view touchBlock:(TransparentViewTouch)transparentViewTouchBlock;

@end
