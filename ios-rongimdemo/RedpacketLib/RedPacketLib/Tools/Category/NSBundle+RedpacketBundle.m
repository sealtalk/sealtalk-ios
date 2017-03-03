//
//  NSBundle+RedpacketBundle.m
//  RedpacketLib
//
//  Created by Mr.Yang on 16/4/26.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "NSBundle+RedpacketBundle.h"
#import "YZHBaseViewController.h"


@implementation NSBundle (RedpacketBundle)

+ (NSBundle *)RedpacketBundle
{
    NSString *path = [[NSBundle bundleForClass:[YZHBaseViewController class]] pathForResource:@"RedpacketBundle" ofType:@"bundle"];
    NSBundle *nibBundle = [NSBundle bundleWithPath:path];
    
    return nibBundle;
}

+ (id)loadNibFromClass:(Class)classPr
{
    id object = [[[self RedpacketBundle] loadNibNamed:NSStringFromClass(classPr) owner:nil options:nil] lastObject];
    
    return object;
}

+ (NSString *)loadImagePath:(NSString *)imageName
{
    return [NSString stringWithFormat:@"RedpacketBundle.bundle/%@", imageName];
}

@end
