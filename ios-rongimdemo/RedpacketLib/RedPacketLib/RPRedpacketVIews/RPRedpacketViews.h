//
//  RPRedpacketViews.h
//  RedpacketLib
//
//  Created by Mr.Yang on 16/8/9.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RedpacketColorStore.h"
#import "RPRedpacketTool.h"


@interface RPRedpacketViews : NSObject

/**
 *  红包中所有的浅蓝色按钮，距离边界15，高度44
 *
 *  @return 返回浅蓝色高亮按钮
 */
+ (UIButton *)redpacketBlueButtonWithTitle:(NSString *)title
                               andSelector:(SEL)aSelector
                                 andTarget:(id)target;

/**
 *  红包中所有的红色按钮，距离边界15，高度44
 *
 *  @return 返回红色高亮按钮
 */
+ (UIButton *)redpacketRedButtonWithTitle:(NSString *)title
                              andSelector:(SEL)aSelector
                                andTarget:(id)target;

@end
