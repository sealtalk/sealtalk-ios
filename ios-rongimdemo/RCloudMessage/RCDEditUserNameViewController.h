//
//  RCDEditUserNameViewController.h
//  RCloudMessage
//
//  Created by litao on 15/11/4.
//  Copyright © 2015年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCDEditUserNameViewController : UIViewController <UITextFieldDelegate>
@property(nonatomic, strong) UITextField *userName;
@property(nonatomic, strong) UIView *BGView;

@end
