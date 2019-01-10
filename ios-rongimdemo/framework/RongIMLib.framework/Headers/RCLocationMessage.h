/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCLocationMessage.h
//  Created by Heq.Shinoda on 14-6-13.

#import "RCMessageContent.h"
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

/*!
 地理位置消息的类型名
 */
#define RCLocationMessageTypeIdentifier @"RC:LBSMsg"

/*!
 地理位置消息类

 @discussion 地理位置消息类，此消息会进行存储并计入未读消息数。
 */
@interface RCLocationMessage : RCMessageContent <NSCoding>

/*!
 地理位置的二维坐标
 */
@property(nonatomic, assign) CLLocationCoordinate2D location;

/*!
 地理位置的名称
 */
@property(nonatomic, copy) NSString *locationName;

/*!
 地理位置的缩略图
 */
@property(nonatomic, strong) UIImage *thumbnailImage;

/*!
 地理位置的附加信息
 */
@property(nonatomic, copy) NSString *extra;

/*!
 初始化地理位置消息

 @param image 地理位置的缩略图
 @param location 地理位置的二维坐标
 @param locationName 地理位置的名称
 @return 地理位置消息的对象
 */
+ (instancetype)messageWithLocationImage:(UIImage *)image
                                location:(CLLocationCoordinate2D)location
                            locationName:(NSString *)locationName;

@end
