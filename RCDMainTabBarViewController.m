//
//  RCDMainTabBarViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/7/30.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDMainTabBarViewController.h"
#import <RongIMKit/RongIMKit.h>

@interface RCDMainTabBarViewController ()

@property NSUInteger previousIndex;

@end

@implementation RCDMainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  self.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
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
