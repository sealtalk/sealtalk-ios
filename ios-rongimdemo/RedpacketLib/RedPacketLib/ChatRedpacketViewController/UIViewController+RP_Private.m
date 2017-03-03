//
//  UIViewController+RP_Private.m
//  RedpacketLib
//
//  Created by 都基鹏 on 2016/12/5.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "UIViewController+RP_Private.h"
#import <objc/runtime.h>

@implementation UIViewController (RP_Private)

- (RedpacketViewControl *)rp_control {
    return objc_getAssociatedObject(self, @selector(rp_control));
}

- (void)setRp_control:(RedpacketViewControl *)rp_control {
    objc_setAssociatedObject(self, @selector(rp_control), rp_control, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
