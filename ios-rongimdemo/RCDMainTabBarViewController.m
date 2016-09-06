//
//  RCDMainTabBarViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/7/30.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDMainTabBarViewController.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDSquareTableViewController.h"
#import "RCDChatListViewController.h"
#import "RCDContactViewController.h"
#import "RCDMeTableViewController.h"

@interface RCDMainTabBarViewController ()

@property NSUInteger previousIndex;

@end

@implementation RCDMainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  [self setTabBarItems];
  self.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[RCDChatListViewController class]]) {
            RCDChatListViewController *chatListVC = (RCDChatListViewController *)obj;
            [chatListVC updateBadgeValueForTabBarItem];
        }
    }];
}

-(void)setTabBarItems {
  [self.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    if ([obj isKindOfClass:[RCDChatListViewController class]]) {
      obj.tabBarItem.image = [[UIImage imageNamed:@"icon_chat"]
                                       imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
      obj.tabBarItem.selectedImage = [[UIImage imageNamed:@"icon_chat_hover"]
                                               imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    } else if ([obj isKindOfClass:[RCDContactViewController class]]) {
      obj.tabBarItem.image = [[UIImage imageNamed:@"contact_icon"]
                              imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
      obj.tabBarItem.selectedImage = [[UIImage imageNamed:@"contact_icon_hover"]
                                      imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    } else if ([obj isKindOfClass:[RCDSquareTableViewController class]]) {
      obj.tabBarItem.image = [[UIImage imageNamed:@"square"]
                              imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
      obj.tabBarItem.selectedImage = [[UIImage imageNamed:@"square_hover"]
                                      imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    } else if ([obj isKindOfClass:[RCDMeTableViewController class]]){
      obj.tabBarItem.image = [[UIImage imageNamed:@"icon_me"]
                              imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
      obj.tabBarItem.selectedImage = [[UIImage imageNamed:@"icon_me_hover"]
                                      imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    } else {
      NSLog(@"Unknown TabBarController");
    }
  }];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
  NSUInteger index = tabBarController.selectedIndex;
  switch (index) {
    case 0:
    {
      if (self.previousIndex == index) {
        //判断如果有未读数存在，发出定位到未读数会话的通知
        if ([[RCIMClient sharedRCIMClient] getTotalUnreadCount] > 0) {
          [[NSNotificationCenter defaultCenter] postNotificationName:@"GotoNextCoversation" object:nil]; 
        }
        self.previousIndex = index;
      }
      self.previousIndex = index;
    }
      break;
      
    case 1:
      self.previousIndex = index;
      break;
      
    case 2:
      self.previousIndex = index;
      break;
      
    case 3:
      self.previousIndex = index;
      break;
      
    default:
      break;
  }
}
@end
