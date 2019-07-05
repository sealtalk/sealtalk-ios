//
//  RCLocationView.h
//  LocationSharer
//
//  Created by 杜立召 on 15/7/27.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef void (^TapActionBlock)(void);

@interface RCLocationView : NSObject

@property(nonatomic, copy) NSString *imageurl;
@property(nonatomic, strong) NSString *userId;
@property(nonatomic, assign) BOOL isMyLocation;
@property(nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property(nonatomic, copy) TapActionBlock tapBlock;

@end
