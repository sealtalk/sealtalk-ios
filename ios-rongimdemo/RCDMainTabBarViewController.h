//
//  RCDMainTabBarViewController.h
//  RCloudMessage
//
//  Created by Jue on 16/7/30.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCDMainTabBarViewController : UITabBarController <UITabBarControllerDelegate>

+ (RCDMainTabBarViewController *)shareInstance;

@property(nonatomic, assign) NSUInteger selectedTabBarIndex;

@end
