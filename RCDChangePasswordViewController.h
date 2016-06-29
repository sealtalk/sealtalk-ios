//
//  RCDChangePasswordViewController.h
//  RCloudMessage
//
//  Created by Jue on 16/2/29.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCDChangePasswordViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *DoneButton;

@property (weak, nonatomic) IBOutlet UIView *OldPasswordView;

@property (weak, nonatomic) IBOutlet UIView *NewPasswordView;

@property (weak, nonatomic) IBOutlet UIView *ConfirmPasswordView;

@end
