//
//  ImageViewController.h
//  RongIMDemo
//
//  Created by litao on 15/3/31.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <WatchKit/WatchKit.h>


@interface ImageViewController : WKInterfaceController
@property (weak, nonatomic) IBOutlet WKInterfaceImage *image;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *loadingLabel;
@end
