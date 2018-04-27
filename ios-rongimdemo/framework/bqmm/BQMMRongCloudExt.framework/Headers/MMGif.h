//
//  MMGif.h
//  StampMeSDK
//
//  Created by isan on 23/11/2017.
//  Copyright © 2017 siyanhui. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  网络表情
 */
@interface MMGif : NSObject

/**
 *  id
 */
@property (nonatomic, strong) NSString *imageId;

/**
 *  图片名称
 */
@property (nonatomic, strong) NSString *text;

/**
 *  图片缩略图地址  静图
 */
@property (nonatomic, strong) NSString *thumbImage;

/**
 *  图片缩略图地址  动图
 */
@property (nonatomic, strong) NSString *gifThumbImage;

/**
 *  图片地址
 *  可能是GIF、PNG、JPG格式
 */
@property (nonatomic, strong) NSString *mainImage;

/**
 *  图片尺寸（pix）
 */
@property (nonatomic, assign) CGSize size;

/**
 *  是否动画表情（GIF）
 */
@property (nonatomic, assign) BOOL isAnimated;

@end

