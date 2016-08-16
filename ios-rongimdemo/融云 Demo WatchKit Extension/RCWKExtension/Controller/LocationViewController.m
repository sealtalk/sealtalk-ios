//
//  LocationViewController.m
//  RongIMDemo
//
//  Created by litao on 15/3/31.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "LocationViewController.h"
#import <RongIMLib/RongIMLib.h>

@implementation LocationViewController
- (instancetype)init {
    self = [super init];
    if (self) {
        // Initialize variables here.
        // Configure interface objects here.
        
        
    }
    return self;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    RCLocationMessage *locMsg = context;
    MKCoordinateRegion coordinateRegion;
    coordinateRegion.center = locMsg.location;
    coordinateRegion.span.latitudeDelta = 0.01;
    coordinateRegion.span.longitudeDelta = 0.01;
    [self.mapView setRegion:coordinateRegion];
   // [self.mapView selectAnnotation:self.annotation animated:YES];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
}

@end
