//
//  RCAnnotationView.h
//  LocationSharer
//
//  Created by 杜立召 on 15/7/27.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCLocationView.h"
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol RCAnnotationViewProtocol <NSObject>

- (void)didSelectAnnotationViewInMap:(MKMapView *)mapView;
- (void)didDeselectAnnotationViewInMap:(MKMapView *)mapView;

@end

@interface RCAnnotationView : MKAnnotationView <RCAnnotationViewProtocol> {
}

@property(nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, copy) NSString *imageUrl;
@property(nonatomic, strong) UIImageView *locationImageView;
//@property (nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) NSString *userId;
@property(nonatomic, strong) UILabel *subtitleLabel;
@property(nonatomic, copy) TapActionBlock tapBlock;

- (id)initWithAnnotation:(id<MKAnnotation>)annotation;
//- (void)refreshHead:(NSString *)imageUrl;

@end
