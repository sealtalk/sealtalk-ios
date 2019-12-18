
//
//  RCLocationPickerViewController.m
//  iOS-IMKit
//
//  Created by YangZigang on 14/10/31.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RealTimeLocationViewController.h"
#import "HeadCollectionView.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "RCAnnotation.h"
#import "RCLocationConvert.h"
#import "UIColor+RCColor.h"

@interface RealTimeLocationViewController () <RCRealTimeLocationObserver, MKMapViewDelegate,
                                              HeadCollectionTouchDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIView *headBackgroundView;
@property (nonatomic, strong) NSMutableDictionary *userAnnotationDic;
@property (nonatomic, assign) MKCoordinateSpan theSpan;
@property (nonatomic, assign) MKCoordinateRegion theRegion;
@property (nonatomic, assign) BOOL isFirstTimeToLoad;
@property (nonatomic, strong) HeadCollectionView *headCollectionView;
@end

@implementation RealTimeLocationViewController
MBProgressHUD *hud;
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    _isFirstTimeToLoad = YES;
    [self addSubviews];

    CLLocation *currentLocation =
        [self.realTimeLocationProxy getLocation:[RCIMClient sharedRCIMClient].currentUserInfo.userId];
    if (currentLocation) {
        __weak RealTimeLocationViewController *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf onReceiveLocation:currentLocation
                                   type:RCRealTimeLocationTypeWGS84
                             fromUserId:[RCIMClient sharedRCIMClient].currentUserInfo.userId];
        });
    }

    hud = [MBProgressHUD showHUDAddedTo:self.mapView animated:YES];
    hud.color = [UIColor colorWithHexString:@"343637" alpha:0.5];
    hud.labelText = RCDLocalizedString(@"locating");
    [hud show:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.realTimeLocationProxy addRealTimeLocationObserver:self];
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusDenied) {
        [hud hide:YES];
        UIAlertController *alertController =
            [UIAlertController alertControllerWithTitle:RCDLocalizedString(@"Inaccessible")
                                                message:RCDLocalizedString(@"Location_access_without_permission")
                                         preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:RCDLocalizedString(@"confirm")
                                                            style:UIAlertActionStyleDefault
                                                          handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)viewDidLayoutSubviews {
    self.mapView.frame = CGRectMake(0, 0, RCDScreenWidth, RCDScreenHeight);
    self.headCollectionView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 95);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.realTimeLocationProxy removeRealTimeLocationObserver:self];
}

- (void)dealloc {
    //  [self.realTimeLocationProxy removeRealTimeLocationObserver:self];
    NSLog(@"dealloc");
}

#pragma mark - HeadCollectionTouchDelegate
- (BOOL)quitButtonPressed {
    UIAlertAction *cancelAction =
        [UIAlertAction actionWithTitle:RCDLocalizedString(@"cancel") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *endAction =
        [UIAlertAction actionWithTitle:RCDLocalizedString(@"end")
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *_Nonnull action) {
                                   __weak typeof(self) __weakself = self;
                                   [self dismissViewControllerAnimated:YES
                                                            completion:^{
                                                                [__weakself.realTimeLocationProxy quitRealTimeLocation];
                                                            }];
                               }];
    [RCKitUtility showAlertController:RCDLocalizedString(@"end_share_location_alert")
                              message:nil
                       preferredStyle:UIAlertControllerStyleActionSheet
                              actions:@[ cancelAction, endAction ]
                     inViewController:self];
    return YES;
}

- (BOOL)backButtonPressed {
    [self dismissViewControllerAnimated:YES
                             completion:^{
                             }];
    return YES;
}

- (void)setRealTimeLocationProxy:(id<RCRealTimeLocationProxy>)realTimeLocationProxy {
    _realTimeLocationProxy = realTimeLocationProxy;
    [_realTimeLocationProxy addRealTimeLocationObserver:self];
}

#pragma mark - RCRealTimeLocationObserver
- (void)onRealTimeLocationStatusChange:(RCRealTimeLocationStatus)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.realTimeLocationProxy getStatus] == RC_REAL_TIME_LOCATION_STATUS_INCOMING ||
            [self.realTimeLocationProxy getStatus] == RC_REAL_TIME_LOCATION_STATUS_IDLE) {
            [self dismissViewControllerAnimated:YES
                                     completion:^{
                                     }];
        }
    });
}
- (void)onReceiveLocation:(CLLocation *)location type:(RCRealTimeLocationType)type fromUserId:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        __weak typeof(self) __weakself = self;
        if (self.isFirstTimeToLoad) {
            if (-90.0f <= location.coordinate.latitude && location.coordinate.latitude <= 90.0f &&
                -180.0f <= location.coordinate.longitude && location.coordinate.longitude <= 180.0f) {
                CLLocationCoordinate2D center;
                center.latitude = location.coordinate.latitude;
                center.longitude = location.coordinate.longitude;
                MKCoordinateSpan span;
                span.latitudeDelta = 0.1;
                span.longitudeDelta = 0.1;
                MKCoordinateRegion region = {center, span};
                self.theSpan = span;
                self.theRegion = region;
                [self.mapView setCenterCoordinate:center animated:YES];
                [self.mapView setRegion:self.theRegion];
            }
        }
        self.isFirstTimeToLoad = NO;
        CLLocation *cll = [self.realTimeLocationProxy getLocation:userId];
        if ([userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
            [hud hide:YES];
        }
        RCAnnotation *annotaton = [self.userAnnotationDic objectForKey:userId];
        if (annotaton == nil) {
            RCLocationView *annotatonView = [[RCLocationView alloc] init];
            // annotatonView.imageUrl = [UIImage imageNamed:@"apple.jpg"];
            annotatonView.userId = userId;
            if (type == RCRealTimeLocationTypeWGS84) {
                annotatonView.coordinate = [RCLocationConvert wgs84ToGcj02:cll.coordinate];
            } else {
                annotatonView.coordinate = cll.coordinate;
            }
            RCAnnotation *ann = [[RCAnnotation alloc] initWithThumbnail:annotatonView];
            [self.mapView addAnnotation:ann];
            [self.userAnnotationDic setObject:ann forKey:userId];

            if ([RCIM sharedRCIM].userInfoDataSource &&
                [[RCIM sharedRCIM]
                        .userInfoDataSource respondsToSelector:@selector(getUserInfoWithUserId:completion:)]) {
                [[RCIM sharedRCIM]
                        .userInfoDataSource
                    getUserInfoWithUserId:userId
                               completion:^(RCUserInfo *user) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       RCUserInfo *userInfo = user;
                                       if (!userInfo) {
                                           userInfo = [[RCUserInfo alloc]
                                               initWithUserId:userId
                                                         name:[NSString stringWithFormat:@"user<%@>", userId]
                                                     portrait:nil];
                                       }

                                       RCAnnotation *annotaton =
                                           [__weakself.userAnnotationDic objectForKey:userInfo.userId];
                                       annotatonView.isMyLocation = NO;
                                       if ([userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
                                           annotatonView.isMyLocation = YES;
                                       }
                                       annotaton.thumbnail.imageurl = userInfo.portraitUri;
                                       [annotaton updateThumbnail:annotaton.thumbnail animated:YES];
                                   });
                               }];
            }

        } else {
            if (type == RCRealTimeLocationTypeWGS84) {
                annotaton.coordinate = [RCLocationConvert wgs84ToGcj02:cll.coordinate];
                annotaton.thumbnail.coordinate = [RCLocationConvert wgs84ToGcj02:cll.coordinate];
            } else {
                annotaton.coordinate = cll.coordinate;
                annotaton.thumbnail.coordinate = cll.coordinate;
            }
            annotaton.thumbnail.isMyLocation = NO;
            if ([userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
                annotaton.thumbnail.isMyLocation = YES;
            }
            [__weakself.mapView removeAnnotation:annotaton];
            [__weakself.mapView addAnnotation:annotaton];
            [annotaton updateThumbnail:annotaton.thumbnail animated:YES];
        }
    });
}

- (void)onParticipantsJoin:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        RCAnnotation *annotaton = [self.userAnnotationDic objectForKey:userId];
        __weak typeof(self) __weakself = self;
        if (annotaton == nil) {
            RCLocationView *annotatonView = [[RCLocationView alloc] init];
            annotatonView.userId = userId;
            RCAnnotation *ann = [[RCAnnotation alloc] initWithThumbnail:annotatonView];
            annotatonView.isMyLocation = NO;
            if ([userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
                annotatonView.isMyLocation = YES;
            }
            [self.mapView addAnnotation:ann];
            [self.userAnnotationDic setObject:ann forKey:userId];

            if ([RCIM sharedRCIM].userInfoDataSource &&
                [[RCIM sharedRCIM]
                        .userInfoDataSource respondsToSelector:@selector(getUserInfoWithUserId:completion:)]) {
                [[RCIM sharedRCIM]
                        .userInfoDataSource
                    getUserInfoWithUserId:userId
                               completion:^(RCUserInfo *userInfo) {
                                   if (!userInfo) {
                                       userInfo = [[RCUserInfo alloc]
                                           initWithUserId:userId
                                                     name:[NSString stringWithFormat:@"user<%@>", userId]
                                                 portrait:nil];
                                   }
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       RCAnnotation *annotaton =
                                           [__weakself.userAnnotationDic objectForKey:userInfo.userId];
                                       annotaton.thumbnail.imageurl = userInfo.portraitUri;
                                       [annotaton updateThumbnail:annotaton.thumbnail animated:YES];

                                   });
                               }];
            }
        }

        if (self.headCollectionView) {
            [__weakself.headCollectionView participantJoin:userId];
        }
    });
}

- (void)onParticipantsQuit:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        __weak typeof(self) __weakself = self;
        if (self.headCollectionView) {
            [__weakself.headCollectionView participantQuit:userId];
        }

        RCAnnotation *annotaton = [self.userAnnotationDic objectForKey:userId];
        if (annotaton) {
            [__weakself.userAnnotationDic removeObjectForKey:userId];
            [__weakself.mapView removeAnnotation:annotaton];
        }

        if ([self.realTimeLocationProxy getStatus] == RC_REAL_TIME_LOCATION_STATUS_INCOMING ||
            [self.realTimeLocationProxy getStatus] == RC_REAL_TIME_LOCATION_STATUS_IDLE) {
            [__weakself dismissViewControllerAnimated:YES
                                           completion:^{
                                           }];
        }
    });
}

- (void)onFailUpdateLocation:(NSString *)description {
    dispatch_async(dispatch_get_main_queue(), ^{
        [hud hide:YES];
    });
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view conformsToProtocol:@protocol(RCAnnotationViewProtocol)]) {
        [((NSObject<RCAnnotationViewProtocol> *)view) didSelectAnnotationViewInMap:mapView];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([view conformsToProtocol:@protocol(RCAnnotationViewProtocol)]) {
        [((NSObject<RCAnnotationViewProtocol> *)view) didDeselectAnnotationViewInMap:mapView];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation conformsToProtocol:@protocol(RCAnnotationProtocol)]) {
        MKAnnotationView *view = [((NSObject<RCAnnotationProtocol> *)annotation) annotationViewInMap:mapView];
        return view;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    self.theRegion = mapView.region;
}

#pragma mark - target action
- (void)tapGpsImgEvent:(UIGestureRecognizer *)gestureRecognizer {
    [self onSelectUserLocationWithUserId:[RCIM sharedRCIM].currentUserInfo.userId];
}

- (void)onUserSelected:(RCUserInfo *)user atIndex:(NSUInteger)index {
    [self onSelectUserLocationWithUserId:user.userId];
}

#pragma mark - helper
//选择用户时以用户坐标为中心
- (void)onSelectUserLocationWithUserId:(NSString *)userId {
    __weak typeof(self) __weakself = self;
    RCAnnotation *annotaton = [self.userAnnotationDic objectForKey:userId];
    if (annotaton) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [__weakself.mapView removeAnnotation:annotaton];
            [__weakself.mapView addAnnotation:annotaton];
            [__weakself.mapView setCenterCoordinate:annotaton.coordinate animated:YES];
            [__weakself.mapView selectAnnotation:annotaton animated:YES];

        });
    }
}

- (void)addSubviews {
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.headCollectionView];
    UIImageView *gpsImg = [[UIImageView alloc] initWithFrame:CGRectMake(18, RCDScreenHeight - 80, 50, 50)];
    gpsImg.image = [UIImage imageNamed:@"gps.png"];
    [self.view addSubview:gpsImg];
    gpsImg.userInteractionEnabled = YES;
    UITapGestureRecognizer *gpsImgTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGpsImgEvent:)];

    [gpsImg addGestureRecognizer:gpsImgTap];
}
#pragma mark - getter
- (MKMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, RCDScreenWidth, RCDScreenHeight)];
        [_mapView setMapType:MKMapTypeStandard];
        _mapView.showsUserLocation = YES;
        _mapView.delegate = self;
        _mapView.showsUserLocation = NO;
    }
    return _mapView;
}

- (NSMutableDictionary *)userAnnotationDic {
    if (!_userAnnotationDic) {
        _userAnnotationDic = [[NSMutableDictionary alloc] init];
    }
    return _userAnnotationDic;
}

- (HeadCollectionView *)headCollectionView {
    if (!_headCollectionView) {
        _headCollectionView =
            [[HeadCollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 95)
                                         participants:[self.realTimeLocationProxy getParticipants]
                                        touchDelegate:self];
        _headCollectionView.touchDelegate = self;
    }
    return _headCollectionView;
}
@end
