//
//  RPRedpacketTool.m
//  RedpacketRequestDataLib
//
//  Created by Mr.Yang on 16/7/26.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPRedpacketTool.h"
#import "RPRedpacketUser.h"


#pragma mark -

UIImage *rp_imageWithColor(UIColor *color)
{
    CGSize size = CGSizeMake(10, 10);
    UIGraphicsBeginImageContextWithOptions(size, 0, [UIScreen mainScreen].scale);
    [color set];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@implementation RPRedpacketTool



@end
