//
//  UIImage+GIF.h
//  LBGIFImage
//
//  Created by Laurin Brandner on 06.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (YZHGIF)

+ (UIImage *)rp_animatedGIFNamed:(NSString *)name;

+ (UIImage *)rp_animatedGIFWithData:(NSData *)data;

- (UIImage *)rp_animatedImageByScalingAndCroppingToSize:(CGSize)size;

@end
