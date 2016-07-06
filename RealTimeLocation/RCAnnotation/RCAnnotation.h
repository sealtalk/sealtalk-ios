//
//  RCAnnotation.h
//  LocationSharer
//
//  Created by 杜立召 on 15/7/27.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCAnnotationView.h"
#import "RCLocationView.h"
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol RCAnnotationProtocol <NSObject>

- (MKAnnotationView *)annotationViewInMap:(MKMapView *)mapView;

@end

@interface RCAnnotation : NSObject <MKAnnotation, RCAnnotationProtocol>

@property(nonatomic, strong) RCAnnotationView *view;
@property(nonatomic, strong) RCLocationView *thumbnail;
@property(nonatomic, readwrite) CLLocationCoordinate2D coordinate;

- (id)initWithThumbnail:(RCLocationView *)thumbnail;
- (void)updateThumbnail:(RCLocationView *)thumbnail animated:(BOOL)animated;

@end
