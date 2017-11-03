//
//  LoginViewController.h
//  RongCloud
//
//  Created by Liv on 14/11/5.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCAnimatedImagesView.h"
#import <UIKit/UIKit.h>
@interface RCDLoginViewController : UIViewController <RCAnimatedImagesViewDelegate>

//-(void) defaultLogin;
- (void)login:(NSString *)userName password:(NSString *)password;
@end
