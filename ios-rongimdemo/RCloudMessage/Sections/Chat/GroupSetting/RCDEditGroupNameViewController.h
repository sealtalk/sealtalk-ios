//
//  RCDEditGroupNameViewController.h
//  RCloudMessage
//
//  Created by Jue on 16/3/28.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RCDGroupInfo;
@interface RCDEditGroupNameViewController : UIViewController <UITextFieldDelegate>
/**
 *  用户信息
 */
@property (nonatomic, strong) RCDGroupInfo *groupInfo;

@end
