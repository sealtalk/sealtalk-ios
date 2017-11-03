//
//  RCAnnotation.m
//  LocationSharer
//
//  Created by 杜立召 on 15/7/27.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCAnnotation.h"
#import "RCDUtilities.h"

@implementation RCAnnotation

- (id)initWithThumbnail:(RCLocationView *)thumbnail {
    self = [super init];
    if (self) {
        _coordinate = thumbnail.coordinate;
        _thumbnail = thumbnail;
        _view.userId = thumbnail.userId;
        _view.imageUrl = thumbnail.imageurl;
    }

    return self;
}

- (MKAnnotationView *)annotationViewInMap:(MKMapView *)mapView {
    if (!_view) {
        _view = (RCAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"RCAnnotationView"];
        if (!_view)
            _view = [[RCAnnotationView alloc] initWithAnnotation:self];
    } else {
        _view.annotation = self;
    }
    [self updateThumbnail:_thumbnail animated:NO];
    return _view;
}

- (void)updateThumbnail:(RCLocationView *)thumbnail animated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.33f
                         animations:^{
                             _coordinate = thumbnail.coordinate;
                         }];
    } else {
        _coordinate = thumbnail.coordinate;
    }

    if (_view) {
        _view.coordinate = self.coordinate;
        _view.userId = thumbnail.userId;
        _view.imageUrl = thumbnail.imageurl;
        _view.tapBlock = thumbnail.tapBlock;
        if (thumbnail.isMyLocation) {
            _view.locationImageView.image = [UIImage imageNamed:@"mylocation.png"];
        } else {
            _view.locationImageView.image = [UIImage imageNamed:@"otherlocation.png"];
        }
        //        if (_view.imageUrl&&_view.imageUrl.length>0) {
        //            [_view refreshHead:_view.imageUrl];
        //        }
    }
}

@end
