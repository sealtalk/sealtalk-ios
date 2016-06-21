//
//  RCLocationPickerViewController.h
//  iOS-IMKit
//
//  Created by YangZigang on 14/10/31.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import <RongIMKit/RongIMKit.h>

/**
 * 位置选取视图控制器
 */
@interface RealTimeLocationViewController
    : UIViewController

@property (nonatomic, weak)id<RCRealTimeLocationProxy> realTimeLocationProxy;

@end

