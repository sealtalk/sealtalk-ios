//
//  UIAlertView+YZXAlert.m
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/3/10.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "UIAlertView+YZHAlert.h"
#import <objc/runtime.h>

@implementation UIAlertView (YZHAlert)

- (void)setRp_completionBlock:(YZHAlertViewCompletionBlock)rp_completionBlock{
    
    objc_setAssociatedObject(self, @selector(completionBlock), rp_completionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    if (rp_completionBlock == NULL) {
        self.delegate = nil;
        
    }else {
        self.delegate = self;
    }
}

- (YZHAlertViewCompletionBlock)rp_completionBlock {
    return objc_getAssociatedObject(self, @selector(completionBlock));
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (self.rp_completionBlock) {
        self.rp_completionBlock(self, buttonIndex);
    }
}

+ (void)rp_showAlertWithTitle:(nullable NSString*)title
                      message:(nullable NSString*)message
            cancelButtonTitle:(nullable NSString *)cancelButtonTitle
            otherButtonTitles:(nullable NSString *)otherButtonTitle
              completionBlock:(nullable YZHAlertViewCompletionBlock) completionBlock;
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle,nil];
    
    alert.rp_completionBlock = completionBlock;
    [alert show];
}


@end
