//
//  RCDEditGroupNameViewController.h
//  RCloudMessage
//
//  Created by Jue on 16/3/28.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCDGroupInfo.h"

@interface RCDEditGroupNameViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *GroupNameLabel;

@property (nonatomic, strong) RCDGroupInfo *Group;

@end
